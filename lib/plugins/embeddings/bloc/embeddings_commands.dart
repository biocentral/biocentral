import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_service_api.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/model/biocentral_config_option.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:fpdart/fpdart.dart';

final class LoadEmbeddingsFromFileCommand extends BiocentralCommand<Map<String, BioEntity>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabase _biocentralDatabase;
  final BiocentralPythonCompanion _pythonCompanion;

  final XFile _xFile;
  final DatabaseImportMode _importMode;

  LoadEmbeddingsFromFileCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralDatabase biocentralDatabase,
    required BiocentralPythonCompanion pythonCompanion,
    required XFile xFile,
    required DatabaseImportMode importMode,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _biocentralDatabase = biocentralDatabase,
        _pythonCompanion = pythonCompanion,
        _xFile = xFile,
        _importMode = importMode;

  @override
  Stream<Either<T, Map<String, BioEntity>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Loading embeddings from file..'));

    final embeddingsFileBytesEither = await _biocentralProjectRepository.handleBytesLoad(xFile: _xFile);

    yield* embeddingsFileBytesEither.match((error) async* {
      yield left(state.setErrored(information: 'Embeddings file could not be parsed! Error: ${error.message}'));
    }, (embeddingsFileBytes) async* {
      if (embeddingsFileBytes == null) {
        yield left(state.setErrored(information: 'Embeddings file could not be parsed!'));
        return;
      }
      final embeddingsData = await _pythonCompanion.loadH5File(
          embeddingsFileBytes, _xFile.name.split('.').firstOrNull ?? 'loaded_embeddings',);
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
  String get typeName => 'LoadEmbeddingsFromFileCommand';
}

final class CalculateEmbeddingsCommand extends BiocentralCommand<Map<String, Embedding>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralAPIRepository _apiRepository;
  final BiocentralDatabase _biocentralDatabase;
  final BiocentralPythonCompanion _pythonCompanion;
  final EmbeddingType _embeddingType;
  final String _embedderName;
  final String _biotrainerName;

  CalculateEmbeddingsCommand(
      {required BiocentralProjectRepository biocentralProjectRepository,
      required BiocentralAPIRepository apiRepository,
      required BiocentralDatabase biocentralDatabase,
      required BiocentralPythonCompanion pythonCompanion,
      required EmbeddingType embeddingType,
      required String embedderName,
      required String biotrainerName,})
      : _biocentralProjectRepository = biocentralProjectRepository,
        _apiRepository = apiRepository,
        _biocentralDatabase = biocentralDatabase,
        _pythonCompanion = pythonCompanion,
        _embeddingType = embeddingType,
        _embedderName = embedderName,
        _biotrainerName = biotrainerName;

  @override
  Stream<Either<T, Map<String, Embedding>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Calculating embeddings..'));

    final Map<String, String>? sequenceData = _biocentralDatabase.getSequences();
    if (sequenceData == null || sequenceData.isEmpty) {
      yield left(state.setErrored(information: 'Could not find any sequence data in the provided database!'));
      return;
    }

    final bool reduce = _embeddingType == EmbeddingType.perSequence;
    const bool useHalfPrecision = false;

    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final biocentralTask = await biocentralAPI.embed(
        embedderName: _biotrainerName, sequenceData: sequenceData, reduce: reduce,);

    String? embeddingsFile;
    int embeddingCurrent = 0;
    int embeddingTotal = 0;
    await for (final (dto, receivedEmbeddingsFile) in biocentralTask.run()) {
      if (dto != null) {
        if (dto.status == TaskStatus.RUNNING) {
          embeddingCurrent = dto.embeddingProgress?.current ?? embeddingCurrent;
          embeddingTotal = dto.embeddingProgress?.total ?? embeddingTotal;
          yield left(
            state.setOperating(
              information: 'Embedding..',
              commandProgress: BiocentralCommandProgress(current: embeddingCurrent, total: embeddingTotal),
            ),
          );
        }
      }
      embeddingsFile = receivedEmbeddingsFile;
      if (embeddingsFile != null) {
        break;
      }
    }
    if (embeddingsFile == null) {
      yield left(state.setErrored(information: 'Embeddings could not be calculated, no embeddings file received!'));
    } else {
      yield* _handleEmbeddingsFile(state, embeddingsFile, reduce);
    }
  }

  Stream<Either<T, Map<String, Embedding>>> _handleEmbeddingsFile<T extends BiocentralCommandState<T>>(
    T state,
    String embeddingsFile,
    bool reduce,
  ) async* {
    // Save
    final embeddingsName = _biotrainerName.contains('/') ? _biotrainerName.split('/').last : _biotrainerName;
    final String embeddingsFileName = '$embeddingsName.h5';
    final embeddingBytes = base64Decode(embeddingsFile);
    // TODO [Error Handling] Handle save errors
    await _biocentralProjectRepository.handleProjectInternalSave(
      fileName: embeddingsFileName,
      type: Embedding,
      bytesFunction: () async => embeddingBytes,
    );
    // Load
    final embeddingsEither = await _pythonCompanion.loadH5File(embeddingBytes, embeddingsName);
    yield* embeddingsEither.match((error) async* {
      yield left(
        state.setErrored(
          information: 'Could not load embeddings from received file! Error: $error',
        ),
      );
    }, (embeddings) async* {
      yield right(embeddings);
      yield left(
        state.setFinished(
          information: 'Finished calculating embeddings',
          commandProgress: BiocentralCommandProgress(current: embeddings.length, total: embeddings.length),
        ),
      );
    });
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'embeddingType': _embeddingType.name,
      'embedderName': _embedderName,
      'embedderNameInBiotrainer': _biotrainerName,
    };
  }

  @override
  String get typeName => 'CalculateEmbeddingsCommand';
}

final class CalculateProjectionsCommand extends BiocentralCommand<ProjectionData> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralAPIRepository _apiRepository;
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralPythonCompanion _pythonCompanion;

  final EmbeddingsRepository _embeddingsRepository;
  final Map<String, PerSequenceEmbedding> _embeddings;
  final String? _embedderName;
  final String _projectionMethod;
  final Map<BiocentralConfigOption, dynamic> _projectionConfig;

  CalculateProjectionsCommand(
      {required BiocentralProjectRepository biocentralProjectRepository,
      required BiocentralAPIRepository apiRepository,
      required BiocentralDatabaseRepository biocentralDatabaseRepository,
      required BiocentralPythonCompanion pythonCompanion,
      required EmbeddingsRepository embeddingsRepository,
      required Map<String, PerSequenceEmbedding> embeddings,
      required String? embedderName,
      required String projectionMethod,
      required Map<BiocentralConfigOption, dynamic> projectionConfig,})
      : _biocentralProjectRepository = biocentralProjectRepository,
        _apiRepository = apiRepository,
        _biocentralDatabaseRepository = biocentralDatabaseRepository,
        _pythonCompanion = pythonCompanion,
        _embeddingsRepository = embeddingsRepository,
        _embeddings = embeddings,
        _embedderName = embedderName,
        _projectionMethod = projectionMethod,
        _projectionConfig = projectionConfig;

  @override
  Stream<Either<T, ProjectionData>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Calculating $_projectionMethod projection..'));

    if (_embedderName == null || _embedderName.isEmpty) {
      yield left(state.setErrored(information: 'No embedder name selected for projection!'));
    }

    // TODO Make generic
    final proteinRepository = _biocentralDatabaseRepository.getFromType(Protein);
    if (proteinRepository == null) {
      yield left(state.setErrored(information: 'Could not find necessary protein repository!'));
    }
    final Map<String, String>? sequenceData = proteinRepository!.getSequences();
    if (sequenceData == null || sequenceData.isEmpty) {
      yield left(state.setErrored(information: 'Could not find any sequence data in the provided database!'));
      return;
    }

    // TODO Add embeddings transfer flow
    // if (_embedderName != 'one_hot_encoding') {
    //   final missingEmbeddingsEither = await _embeddingsClient.getMissingEmbeddings(sequences, _embedderName!, true);
    //   yield* missingEmbeddingsEither.match((error) async* {
    //     yield left(state.setErrored(information: error.message));
    //   }, (missingEmbeddings) async* {
    //     if (missingEmbeddings.isNotEmpty) {
    //       // TODO Filter _embeddings by missingEmbeddings
    //       final writeH5Either = await _pythonCompanion.writeH5File(_embeddings);
    //       yield* writeH5Either.match((error) async* {
    //         yield left(state.setErrored(information: error.message));
    //       }, (h5Bytes) async* {
    //         // TODO Saving is not necessary here
    //         // final bytesDecoded = base64Decode(h5Bytes);
    //         // final handleSaveEither = await _biocentralProjectRepository.handleProjectInternalSave(
    //         //     fileName: 'saved_embeddings.h5', type: Embedding, bytes: bytesDecoded);
    //         final addEmbeddingsEither = await _embeddingsClient.addEmbeddings(h5Bytes, sequences, _embedderName, true);
    //         if (addEmbeddingsEither.isLeft()) {
    //           yield left(state.setErrored(information: 'Could not add embeddings to server!'));
    //         }
    //       });
    //     }
    //   });
    // }

    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final biocentralTask = await biocentralAPI.project(
        method: _projectionMethod,
        config: _projectionConfig.map((k, v) => MapEntry(k.name, v.toString())),
        embedderName: _embedderName!,
        sequenceData: sequenceData,);
    Map<ProjectionData, List<Map<String, dynamic>>>? projectionData;
    await for (final (dto, projectionDataResponse) in biocentralTask.run()) {
      if (projectionDataResponse != null) {
        projectionData = ProtspaceFileHandler.parse(projectionDataResponse);
      }
      if (projectionData != null) {
        break;
      }
    }
    if (projectionData == null) {
      yield left(state.setErrored(information: 'Projections could not be calculated, no projections file received!'));
    }

    // TODO Improve Point Data with type of embeddings
    final BiocentralDatabase? database = _biocentralDatabaseRepository.getFromType(Protein);
    if (database == null) {
      yield left(state.setErrored(information: 'Could not find database for UMAP point data!'));
    }
    for (final ProjectionData projection in projectionData?.keys ?? []) {
      final Map<ProjectionData, List<Map<String, dynamic>>> updatedProjectionData =
          _embeddingsRepository.updateProjectionData(
        _embedderName,
        projection,
        database!.databaseToList().map((entity) => entity.toMap().map((k, v) => MapEntry(k, v.toString()))).toList(),
      );
      yield right(projection);
      // TODO [Feature] Handle multiple projections at once
      yield left(
        state
            .setOperating(information: 'Calculated projection data!')
            .copyWith(copyMap: {'projectionData': updatedProjectionData}),
      );
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'embedderName': _embedderName,
      'projectionMethod': _projectionMethod,
      'projectionConfig': _projectionConfig.map((option, value) => MapEntry(option.name, value)),
    };
  }

  @override
  String get typeName => 'CalculateProjectionsCommand';
}
