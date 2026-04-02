import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/data/protspace_api.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/plugins/embeddings/domain/projections_repository.dart';
import 'package:biocentral/plugins/embeddings/model/projection.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:cross_file/cross_file.dart';

final class LoadEmbeddingsFromFileCommand extends BiocentralCommand<EmbeddingsFile> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralPythonCompanion _pythonCompanion;
  final EmbeddingsRepository _embeddingsRepository;

  final XFile _xFile;
  final EmbeddingsFile _preloadedFile;
  final EmbeddingsFileLoadMode _loadMode; // Load file into project or sync externally?
  final DatabaseImportMode _importMode; // Overwrite existing embeddings?

  LoadEmbeddingsFromFileCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralPythonCompanion pythonCompanion,
    required EmbeddingsRepository embeddingsRepository,
    required XFile xFile,
    required EmbeddingsFile preloadedFile, // Pre-Loaded in UI
    required EmbeddingsFileLoadMode loadMode,
    required DatabaseImportMode importMode,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _pythonCompanion = pythonCompanion,
        _embeddingsRepository = embeddingsRepository,
        _xFile = xFile,
        _preloadedFile = preloadedFile,
        _loadMode = loadMode,
        _importMode = importMode;

  @override
  Stream<BiocentralCommandLog<EmbeddingsFile>> execute() async* {
    BiocentralCommandLog<EmbeddingsFile> log = initLog();
    yield log = log.logInfo(information: 'Loading embeddings file..');

    switch (_loadMode) {
      case EmbeddingsFileLoadMode.external:
        yield* syncExternal(log);
      case EmbeddingsFileLoadMode.internal:
        yield* syncInternal(log);
    }
  }

  Stream<BiocentralCommandLog<EmbeddingsFile>> syncExternal(BiocentralCommandLog<EmbeddingsFile> log) async* {
    final syncedKeys = _preloadedFile.fileInformation.metadata.keys.length;
    yield log.finish(
      result: BiocentralCommandResult(_preloadedFile, _preloadedFile.serialize()),
      finalProgress: BiocentralCommandProgress(
        information: 'Finished syncing external embeddings file!',
        current: syncedKeys,
        total: syncedKeys,
      ),
    );
  }

  /// Import external h5 file to internal h5 files and save
  Stream<BiocentralCommandLog<EmbeddingsFile>> syncInternal(BiocentralCommandLog<EmbeddingsFile> log) async* {
    /*
    OLD IMPLEMENTATION
        final embeddingsFileBytesEither = await _biocentralProjectRepository.handleBytesLoad(xFile: _xFile);

    yield* embeddingsFileBytesEither.match((error) async* {
      yield left(state.setErrored(information: 'Embeddings file could not be parsed! Error: ${error.message}'));
    }, (embeddingsFileBytes) async* {
      if (embeddingsFileBytes == null) {
        yield left(state.setErrored(information: 'Embeddings file could not be parsed!'));
        return;
      }
      final embeddingsData = await _pythonCompanion.loadH5File(
        embeddingsFileBytes,
        _xFile.name.split('.').firstOrNull ?? 'loaded_embeddings',
      );
      yield* embeddingsData.match((error) async* {
        yield left(state.setErrored(information: 'Embeddings file could not be parsed! Error: ${error.message}'));
      }, (embeddingsMap) async* {
        final entities = _biocentralDatabase.updateEmbeddings(embeddingsMap);
        yield right(entities);
        yield left(
          state.setFinished(
            information: 'Finished loading embeddings from file!',
            commandProgress:
                BiocentralCommandProgress(current: embeddingsMap.values.length, total: embeddingsMap.values.length),
          ),
        );
      });
    });
     */
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'fileName': _xFile.name,
      'fileExtension': _xFile.extension,
      'loadMode': _loadMode.name,
      'importMode': _importMode.name,
    }..addAll(_preloadedFile.serialize());
  }

  @override
  String get typeName => 'LoadEmbeddingsFromFileCommand';

  @override
  void acceptResult(BiocentralCommandLog<dynamic>? resultLog) {
    if (resultLog != null && resultLog.result?.result is EmbeddingsFile) {
      final file = resultLog.result!.result;
      _embeddingsRepository.addFile(file);
    }
  }
}

final class CalculateEmbeddingsCommand extends BiocentralCommand<EmbeddingsFile> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralAPIRepository _apiRepository;
  final BiocentralDatabase _biocentralDatabase;
  final BiocentralPythonCompanion _pythonCompanion;
  final EmbeddingsRepository _embeddingsRepository;
  final EmbeddingType _embeddingType;
  final String _embedderName;

  CalculateEmbeddingsCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralAPIRepository apiRepository,
    required BiocentralDatabase biocentralDatabase,
    required BiocentralPythonCompanion pythonCompanion,
    required EmbeddingsRepository embeddingsRepository,
    required EmbeddingType embeddingType,
    required String embedderName,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _apiRepository = apiRepository,
        _biocentralDatabase = biocentralDatabase,
        _pythonCompanion = pythonCompanion,
        _embeddingsRepository = embeddingsRepository,
        _embeddingType = embeddingType,
        _embedderName = embedderName;

  @override
  Stream<BiocentralCommandLog<EmbeddingsFile>> execute() async* {
    BiocentralCommandLog<EmbeddingsFile> log = initLog();
    yield log = log.logInfo(information: 'Calculating embeddings..');

    final Map<String, String>? sequenceData = _biocentralDatabase.getSequences();
    if (sequenceData == null || sequenceData.isEmpty) {
      yield log.errored(error: 'Could not find any sequence data in the provided database!');
      return;
    }

    final bool reduce = _embeddingType == EmbeddingType.perSequence;
    // TODO useHalfPrecision
    const bool useHalfPrecision = false;

    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final biocentralTask = await biocentralAPI.embed(
      embedderName: _embedderName,
      sequenceData: sequenceData,
      reduce: reduce,
    );

    String? embeddingsFile;
    int embeddingCurrent = 0;
    int embeddingTotal = 0;
    await for (final (dto, receivedEmbeddingsFile) in biocentralTask.run()) {
      if (dto != null) {
        if (dto.status == TaskStatus.RUNNING) {
          embeddingCurrent = dto.embeddingProgress?.current ?? embeddingCurrent;
          embeddingTotal = dto.embeddingProgress?.total ?? embeddingTotal;
          yield log = log.logProgress(
              progress: BiocentralCommandProgress(
                  information: 'Embedding..', current: embeddingCurrent, total: embeddingTotal));
        }
      }
      embeddingsFile = receivedEmbeddingsFile;
      if (embeddingsFile != null) {
        break;
      }
    }
    if (embeddingsFile == null) {
      yield log.errored(error: 'Embeddings could not be calculated, no embeddings file received!');
      return;
    }
    yield* _handleEmbeddingsFile(log, embeddingsFile, reduce);
  }

  Stream<BiocentralCommandLog<EmbeddingsFile>> _handleEmbeddingsFile(
    BiocentralCommandLog<EmbeddingsFile> log,
    String embeddingsFile,
    bool reduce,
  ) async* {
    // Save
    final embeddingsName = _embedderName.contains('/') ? _embedderName.split('/').last : _embedderName;
    final String embeddingsFileName = '$embeddingsName.h5';
    final embeddingBytes = base64Decode(embeddingsFile);
    // TODO [Error Handling] Handle save errors
    // TODO Sync to existing database
    final saveEither = await _biocentralProjectRepository.handleProjectInternalSave(
      fileName: embeddingsFileName,
      type: Embedding,
      bytesFunction: () async => embeddingBytes,
    );
    // Load
    yield* saveEither.match((error) async* {
      yield log.errored(error: 'Could not save embeddings to file! Error: $error');
    }, (path) async* {
      final embeddingsFileInformationEither = await _pythonCompanion.getH5Info(path);
      yield* embeddingsFileInformationEither.match((error) async* {
        yield log.errored(error: 'Could not load embeddings from received file! Error: $error');
      }, (embeddingsFileInformation) async* {
        final EmbeddingsFile embeddingsFile =
            EmbeddingsFile(path: path, embedderName: _embedderName, fileInformation: embeddingsFileInformation);
        yield log.finish(
          result: BiocentralCommandResult(embeddingsFile, embeddingsFile.serialize()),
          finalProgress: BiocentralCommandProgress(
            information: 'Finished calculating embeddings!',
            current: embeddingsFileInformation.length(),
            total: embeddingsFileInformation.length(),
          ),
        );
      });
    });
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'embeddingType': _embeddingType.name,
      'embedderName': _embedderName,
    };
  }

  @override
  String get typeName => 'CalculateEmbeddingsCommand';

  @override
  void acceptResult(BiocentralCommandLog<dynamic>? resultLog) {
    if (resultLog != null && resultLog.result?.result is EmbeddingsFile) {
      final file = resultLog.result!.result;
      _embeddingsRepository.addFile(file);
    }
  }
}

final class LoadProjectionsCommand extends BiocentralCommand<List<Projection>> {
  final BiocentralProjectRepository _projectRepository;
  final ProjectionsRepository _projectionsRepository;
  final XFile _xFile;
  final DatabaseImportMode _importMode;

  LoadProjectionsCommand({
    required BiocentralProjectRepository projectRepository,
    required ProjectionsRepository projectionsRepository,
    required XFile xFile,
    required DatabaseImportMode importMode,
  })  : _projectRepository = projectRepository,
        _projectionsRepository = projectionsRepository,
        _xFile = xFile,
        _importMode = importMode;

  @override
  Stream<BiocentralCommandLog<List<Projection>>> execute() async* {
    BiocentralCommandLog<List<Projection>> log = initLog();
    yield log = log.logInfo(information: 'Loading projections..');

    final fileDataEither = await _projectRepository.handleLoad(xFile: _xFile);
    yield* fileDataEither.match((l) async* {
      yield log.errored(error: l.message);
    }, (fileData) async* {
      if (fileData == null) {
        yield log.errored(error: 'No file data could be loaded!');
        return;
      }
      final protspaceMap = jsonDecode(fileData.content);
      final projections = ProtspaceFileHandler.parse(protspaceMap);
      if (projections.isEmpty) {
        yield log.errored(error: 'Could not find any projections in file!');
        return;
      }
      yield log.finish(
        result: BiocentralCommandResult(
          projections,
          projections
              .map((projection) => projection.serialize())
              .toList()
              .asMap()
              .map((k, v) => MapEntry(k.toString(), v)),
        ),
        finalProgress: BiocentralCommandProgress(
          information: 'Finished loading projections!',
          current: projections.length,
          total: projections.length,
        ),
      );
    });
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'fileName': _xFile.name,
      'fileExtension': _xFile.extension,
      'importMode': _importMode.name,
    };
  }

  @override
  String get typeName => 'LoadProjectionsCommand';

  @override
  void acceptResult(BiocentralCommandLog<dynamic>? resultLog) {
    if (resultLog != null && resultLog.result?.result is List<Projection>) {
      final projections = resultLog.result!.result;
      _projectionsRepository.addProjections(projections);
    }
  }
}

final class CalculateProjectionsCommand extends BiocentralCommand<List<Projection>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralAPIRepository _apiRepository;
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;

  final ProjectionsRepository _projectionsRepository;
  final Map<String, PerSequenceEmbedding> _embeddings;
  final String _embedderName;
  final String _projectionMethod;
  final Map<String, String> _projectionConfig;

  CalculateProjectionsCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralAPIRepository apiRepository,
    required BiocentralDatabaseRepository biocentralDatabaseRepository,
    required ProjectionsRepository projectionsRepository,
    required String embedderName,
    required String projectionMethod,
    required Map<String, String> projectionConfig,
    Map<String, PerSequenceEmbedding> embeddings = const {}, // TODO Add existing embeddings
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _apiRepository = apiRepository,
        _biocentralDatabaseRepository = biocentralDatabaseRepository,
        _projectionsRepository = projectionsRepository,
        _embeddings = embeddings,
        _embedderName = embedderName,
        _projectionMethod = projectionMethod,
        _projectionConfig = projectionConfig;

  @override
  Stream<BiocentralCommandLog<List<Projection>>> execute() async* {
    BiocentralCommandLog<List<Projection>> log = initLog();
    yield log = log.logInfo(information: 'Calculating $_projectionMethod projection..');

    // TODO Make generic
    final proteinRepository = _biocentralDatabaseRepository.getFromType(Protein);
    if (proteinRepository == null) {
      yield log.errored(error: 'Could not find necessary protein repository!');
      return;
    }
    final Map<String, String>? sequenceData = proteinRepository.getSequences();
    if (sequenceData == null || sequenceData.isEmpty) {
      yield log.errored(error: 'Could not find any sequence data in the provided database!');
      return;
    }

    // TODO [Optimization] Allow usage of local embeddings for projection

    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final biocentralTask = await biocentralAPI.project(
      method: _projectionMethod,
      config: _projectionConfig,
      embedderName: _embedderName,
      sequenceData: sequenceData,
    );
    List<Projection>? projections;
    await for (final (dto, projectionDataResponse) in biocentralTask.run()) {
      if (projectionDataResponse != null) {
        // TODO Projection.fromProstspace()
        projections = ProtspaceFileHandler.parse(projectionDataResponse);
      }
      if (projections != null) {
        break;
      }
    }
    if (projections == null) {
      yield log.errored(error: 'Projections could not be calculated, no projections file received!');
      return;
    }

    if (projections.isEmpty) {
      yield log.errored(error: 'No projection found after parsing result!');
      return;
    }
    // TODO Maybe necessary: Remapping projections to better internal representation
    //final projection =
    //    Projection(id: 'proteins-$_embedderName-$_projectionMethod', config: _projectionConfig, data: firstProjection);
    yield log.finish(
      result: BiocentralCommandResult(
        projections,
        projections
            .map((projection) => projection.serialize())
            .toList()
            .asMap()
            .map((k, v) => MapEntry(k.toString(), v)),
      ),
      finalProgress: BiocentralCommandProgress(
        information: 'Finished calculating $_projectionMethod projection!',
        current: projections.length,
        total: projections.length,
      ),
    );
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'embedderName': _embedderName,
      'projectionMethod': _projectionMethod,
      'projectionConfig': _projectionConfig,
    };
  }

  @override
  String get typeName => 'CalculateProjectionsCommand';

  @override
  void acceptResult(BiocentralCommandLog<dynamic>? resultLog) {
    if (resultLog != null && resultLog.result?.result is List<Projection>) {
      final projections = resultLog.result!.result;
      _projectionsRepository.addProjections(projections);
    }
  }
}
