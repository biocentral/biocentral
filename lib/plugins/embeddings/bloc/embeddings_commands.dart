import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_client.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_python_companion.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';

final class LoadEmbeddingsFromFileCommand extends BiocentralCommand<Map<String, BioEntity>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabase _biocentralDatabase;
  final BiocentralPythonCompanion _pythonCompanion;

  final PlatformFile? _platformFile;
  final FileData? _fileData;
  final DatabaseImportMode _importMode;

  LoadEmbeddingsFromFileCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralDatabase biocentralDatabase,
    required BiocentralPythonCompanion pythonCompanion,
    required PlatformFile? platformFile,
    required FileData? fileData,
    required DatabaseImportMode importMode,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _biocentralDatabase = biocentralDatabase,
        _pythonCompanion = pythonCompanion,
        _platformFile = platformFile,
        _fileData = fileData,
        _importMode = importMode;

  @override
  Stream<Either<T, Map<String, BioEntity>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Loading embeddings from file..'));

    if (_platformFile == null && _fileData == null) {
      yield left(state.setErrored(information: 'Did not receive any data to load!'));
    } else {
      final embeddingsData = await _pythonCompanion.loadH5File(_platformFile!);
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
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'fileName': _fileData?.name ?? _platformFile?.name,
      'fileExtension': _fileData?.extension ?? _platformFile?.extension,
      'importMode': _importMode.name,
    };
  }
}

final class CalculateEmbeddingsCommand extends BiocentralCommand<Map<String, Embedding>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabase _biocentralDatabase;
  final EmbeddingsClient _embeddingClient;
  final EmbeddingType _embeddingType;
  final String _embedderName;
  final String _biotrainerName;

  CalculateEmbeddingsCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralDatabase biocentralDatabase,
    required EmbeddingsClient embeddingClient,
    required EmbeddingType embeddingType,
    required String embedderName,
    String? biotrainerName,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _biocentralDatabase = biocentralDatabase,
        _embeddingClient = embeddingClient,
        _embeddingType = embeddingType,
        _embedderName = embedderName,
        _biotrainerName = biotrainerName ?? '';

  @override
  Stream<Either<T, Map<String, Embedding>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Calculating embeddings..'));

    final String databaseHash = await _biocentralDatabase.getHash();
    final transferEither = await _embeddingClient.transferFile(
      databaseHash,
      StorageFileType.sequences,
      () async => _biocentralDatabase.convertToString('fasta'),
    );
    yield* transferEither.match((error) async* {
      yield left(state.setErrored(information: 'Dataset hash could not be transferred! Error: ${error.message}'));
    }, (u) async* {
      // TODO USE HALF PRECISION
      final bool reduce = _embeddingType == EmbeddingType.perSequence;
      const bool useHalfPrecision = false;
      final taskIDEither =
          await _embeddingClient.startEmbedding(_embedderName, _biotrainerName, databaseHash, reduce, useHalfPrecision);

      yield* taskIDEither.match((error) async* {
        yield left(state.setErrored(information: 'Embedding could not be started! Error: ${error.message}'));
        return;
      }, (taskID) async* {
        String? embeddingsFile;
        await for (String? embFileResponse in _embeddingClient.embeddingsTaskStream(taskID)) {
          if (embFileResponse != null) {
            embeddingsFile = embFileResponse;
            break;
          }
        }
        if (embeddingsFile == null) {
          yield left(state.setErrored(information: 'Embeddings could not be calculated, no embeddings file received!'));
          return;
        }
        yield* _handleEmbeddingsFile(state, embeddingsFile, reduce);
      });
    });
  }

  Stream<Either<T, Map<String, Embedding>>> _handleEmbeddingsFile<T extends BiocentralCommandState<T>>(
    T state,
    String embeddingsFile,
    bool reduce,
  ) async* {
    // Save
    final String embeddingsFileName = (_biotrainerName ?? 'custom_embedder_') + (reduce ? '_reduced.json' : '.json');
    _biocentralProjectRepository.handleSave(fileName: embeddingsFileName, content: embeddingsFile);
    // Load
    final BioFileHandlerContext<Embedding> handler = BioFileHandler<Embedding>().create('json');
    final Map<String, Embedding>? embeddings = await handler.readFromString(embeddingsFile);
    if (embeddings == null) {
      yield left(state.setErrored(information: 'Error calculating embeddings: no values returned!'));
      return;
    }
    yield right(embeddings);
    yield left(
      state.setFinished(
        information: 'Finished calculating embeddings',
        commandProgress: BiocentralCommandProgress(current: embeddings.length, total: embeddings.length),
      ),
    );
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'embeddingType': _embeddingType.name,
      'embedderName': _embedderName,
      'embedderNameInBiotrainer': _biotrainerName,
    };
  }
}

final class CalculateUMAPCommand extends BiocentralCommand<UMAPData> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final EmbeddingsRepository _embeddingsRepository;
  final EmbeddingsClient _embeddingsClient;
  final List<PerSequenceEmbedding> _embeddings;
  final String? _embedderName;

  CalculateUMAPCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralDatabaseRepository biocentralDatabaseRepository,
    required EmbeddingsRepository embeddingsRepository,
    required EmbeddingsClient embeddingsClient,
    required List<PerSequenceEmbedding> embeddings,
    required String? embedderName,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _biocentralDatabaseRepository = biocentralDatabaseRepository,
        _embeddingsRepository = embeddingsRepository,
        _embeddings = embeddings,
        _embeddingsClient = embeddingsClient,
        _embedderName = embedderName;

  @override
  Stream<Either<T, UMAPData>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Calculating UMAP..'));

    if (_embedderName == null || _embedderName.isEmpty) {
      yield left(state.setErrored(information: 'No embedder name selected for UMAP!'));
    } else {
      if (_embeddings.contains(null)) {
        yield left(state.setErrored(information: 'Some proteins do not have embeddings!'));
      } else {
        final umapDataEither = await _embeddingsClient.umap(_embedderName, _embeddings);
        yield* umapDataEither.match((error) async* {
          yield left(state.setErrored(information: error.message));
        }, (umapData) async* {
          // TODO Improve Point Data with type of embeddings
          final BiocentralDatabase? database = _biocentralDatabaseRepository.getFromType(Protein);
          if (database == null) {
            yield left(state.setErrored(information: 'Could not find database for UMAP point data!'));
          } else {
            final Map<UMAPData, List<Map<String, String>>> updatedUMAPData = _embeddingsRepository.updateUMAPData(
              _embedderName,
              umapData,
              database
                  .databaseToList()
                  .map((entity) => entity.toMap().map((k, v) => MapEntry(k, v.toString())))
                  .toList(),
            );
            yield right(umapData);
            yield left(
              state.setFinished(information: 'Calculated UMAP data!').copyWith(copyMap: {'umapData': updatedUMAPData}),
            );
          }
        });
      }
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {'embedderName': _embedderName};
  }
}
