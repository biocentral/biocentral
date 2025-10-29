import 'dart:async';
import 'dart:typed_data';

import 'package:biocentral/plugins/embeddings/data/embeddings_dto.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_client.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_dto.dart';
import 'package:biocentral/plugins/prediction_models/domain/prediction_model_repository.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

final class TrainBiotrainerModelCommand extends BiocentralResumableCommand<PredictionModel> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabase _biocentralDatabase;
  final PredictionModelRepository _predictionModelRepository;
  final PredictionModelsClient _predictionModelsClient;

  final Map<String, String> _trainingConfiguration;

  TrainBiotrainerModelCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralDatabase biocentralDatabase,
    required PredictionModelRepository predictionModelRepository,
    required PredictionModelsClient predictionModelsClient,
    required Map<String, String> trainingConfiguration,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _biocentralDatabase = biocentralDatabase,
        _predictionModelRepository = predictionModelRepository,
        _predictionModelsClient = predictionModelsClient,
        _trainingConfiguration = trainingConfiguration;

  @override
  Stream<Either<T, PredictionModel>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Training new model!'));

    final String configFile = BiotrainerFileHandler.biotrainerConfigurationToConfigFile(_trainingConfiguration);

    final Map<String, dynamic> entryMap = _biocentralDatabase.databaseToMap();
    final String databaseHash = await _biocentralDatabase.getHash();

    final String? modelArchitecture = _trainingConfiguration['model_choice'];
    final String? targetColumn = _trainingConfiguration['target_column'];
    final String? setColumn = _trainingConfiguration['set_column'];

    if (modelArchitecture == null || targetColumn == null || setColumn == null) {
      yield left(
        state.setErrored(
          information: 'Invalid training configuration: $modelArchitecture, $targetColumn, $setColumn',
        ),
      );
      return;
    }

    final inputFile = await BiotrainerFileHandler.getBiotrainerInputFile(
      _biocentralDatabase.getType(),
      entryMap,
      targetColumn,
      setColumn,
    );

    final transferEitherSequences = await _predictionModelsClient.transferFile(
      databaseHash,
      StorageFileType.input,
      () async => inputFile,
    );

    if (transferEitherSequences.isLeft()) {
      yield left(state.setErrored(information: 'Error transferring training files to server!'));
      return;
    }

    final taskIDEither = await _predictionModelsClient.startTraining(configFile, databaseHash);
    yield* taskIDEither.match((error) async* {
      yield left(state.setErrored(information: 'Training could not be started! Error: ${error.message}'));
      return;
    }, (taskID) async* {
      yield left(state.setTaskID(taskID));

      final initialModel = _getInitialModel();

      yield* doTraining(taskID, state, initialModel);
    });
  }

  @override
  Stream<Either<T, PredictionModel>> resumeExecution<T extends BiocentralCommandState<T>>(
      String taskID, T state) async* {
    yield left(state.setOperating(information: 'Trying to resume training..'));
    final initialModel = _getInitialModel();
    final resumedModelEither = await _predictionModelsClient.resumeTraining(taskID, initialModel);
    yield* resumedModelEither.match((error) async* {
      yield left(state.setErrored(information: 'Training could not be resumed! Error: ${error.message}'));
      return;
    }, (resumedModel) async* {
      yield* doTraining(taskID, state, resumedModel);
    });
  }

  Stream<Either<T, PredictionModel>> doTraining<T extends BiocentralCommandState<T>>(
      String taskID, T state, PredictionModel initialModel) async* {
    T trainingState =
        state.setOperating(information: 'Starting training..').copyWith(copyMap: {'trainingModel': initialModel});
    yield left(trainingState);

    PredictionModel? currentModel;
    await for (final (dto, updatedModel)
        in _predictionModelsClient.biotrainerTrainingTaskStream(taskID, initialModel)) {
      if (dto.embeddingProgress != null) {
        final (current, total) = dto.embeddingProgress!;
        yield left(
          trainingState.setOperating(
            information: 'Embedding..',
            commandProgress: BiocentralCommandProgress(current: current, total: total),
          ),
        );
        continue;
      }
      if (updatedModel == null) {
        continue;
      }
      // TODO Support Cross Validation properly
      final int? currentEpoch = updatedModel.holdOutResult?.getLastEpoch();
      final commandProgress =
          currentEpoch != null ? BiocentralCommandProgress(current: currentEpoch, hint: 'Epoch') : null;
      trainingState =
          trainingState.setOperating(information: 'Training model..', commandProgress: commandProgress).copyWith(
        copyMap: {
          'trainingModel': updatedModel,
        },
      );
      currentModel = updatedModel;
      yield left(trainingState);
    }

    // Receive files after training has finished
    // TODO Handle case that training was interrupted/failed / no hash
    final modelFilesEither = await _predictionModelsClient.getModelFiles(currentModel!.modelHash!);
    yield* modelFilesEither.match((error) async* {
      yield left(state.setErrored(information: 'Could not retrieve model files! Error: ${error.message}'));
      return;
    }, (modelFiles) async* {
      Map<String, Uint8List> checkpoints = {};
      if (modelFiles[StorageFileType.biotrainer_checkpoint]?.isNotEmpty ?? false) {
        checkpoints = modelFiles[StorageFileType.biotrainer_checkpoint];
      }
      final updatedModels = await _predictionModelRepository.addModelFromBiotrainerFiles(
        configFile: modelFiles[StorageFileType.biotrainer_config],
        outputFile: modelFiles[StorageFileType.biotrainer_result],
        loggingFile: modelFiles[StorageFileType.biotrainer_logging],
        checkpointFiles: checkpoints,
      );

      final modelResult = updatedModels.last;

      yield right(modelResult);
      yield left(state.setFinished(information: 'Finished training model!'));
    });
  }

  PredictionModel _getInitialModel() {
    return PredictionModel.fromTrainingConfig(_trainingConfiguration)
        .copyWith(trainingStatus: BiocentralTaskStatus.running);
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {'databaseType': _biocentralDatabase.getEntityTypeName(), 'trainingConfiguration': _trainingConfiguration};
  }

  @override
  String get typeName => 'TrainBiotrainerModelCommand';
}

final class BiotrainerInferenceCommand extends BiocentralCommand<Map<String, dynamic>> {
  final BiocentralDatabase _biocentralDatabase;
  final PredictionModelsClient _predictionModelsClient;

  final PredictionModel _predictionModel;
  final Set<String> _selectedEntityIDs;

  BiotrainerInferenceCommand(
      {required BiocentralDatabase biocentralDatabase,
      required PredictionModelsClient predictionModelsClient,
      required PredictionModel predictionModel,
      required Set<String> selectedEntityIDs})
      : _biocentralDatabase = biocentralDatabase,
        _predictionModelsClient = predictionModelsClient,
        _predictionModel = predictionModel,
        _selectedEntityIDs = selectedEntityIDs;

  @override
  Stream<Either<T, Map<String, dynamic>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Inferencing from trained model..'));

    final Map<String, String> sequenceMap = _biocentralDatabase
        .databaseToMap()
        .filterWithKey((k, v) => _selectedEntityIDs.contains(k))
        .map((k, v) => MapEntry(k, v.toMap()['sequence'].toString())); // TODO This should be handled more generic

    if (sequenceMap.isEmpty) {
      yield left(
        state.setErrored(
          information: 'Could not find any entities for inference!',
        ),
      );
      return;
    }

    if (_predictionModel.modelHash == null) {
      yield left(
        state.setErrored(
          information: 'Could not find model hash for inference!',
        ),
      );
      return;
    }

    // Populate predictions in state with empty predictions
    yield left(state.copyWith(copyMap: {'predictions': sequenceMap.map((k, v) => MapEntry(k, null))}));

    final taskIDEither = await _predictionModelsClient.startInference(_predictionModel.modelHash!, sequenceMap);
    yield* taskIDEither.match((error) async* {
      yield left(state.setErrored(information: 'Training could not be started! Error: ${error.message}'));
      return;
    }, (taskID) async* {
      yield left(state.setTaskID(taskID));

      Map<String, dynamic> allPredictions = {};
      await for (final (dto, predictions) in _predictionModelsClient.biotrainerInferenceTaskStream(taskID)) {
        if (dto.embeddingProgress != null) {
          final (current, total) = dto.embeddingProgress!;
          yield left(
            state.setOperating(
              information: 'Embedding..',
              commandProgress: BiocentralCommandProgress(current: current, total: total),
            ),
          );
          continue;
        }
        if (dto.predictions == null || dto.predictions!.isEmpty) {
          continue;
        }
        allPredictions = Map.from(predictions ?? {});
        final commandProgress = BiocentralCommandProgress(current: predictions?.length ?? 0, hint: 'Predictions');
        state = state
            .setOperating(information: 'Inferencing from trained model..', commandProgress: commandProgress)
            .copyWith(copyMap: {'predictions': allPredictions});

        yield left(state);
      }

      yield right(allPredictions);
      yield left(state.setFinished(information: 'Finished inference!'));
    });
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'databaseType': _biocentralDatabase.getEntityTypeName(),
      'predictionModel': _predictionModel.getReadableModelID(),
      'selectedEntityIDs': _selectedEntityIDs.toList(),
    };
  }

  @override
  String get typeName => 'BiotrainerInferenceCommand';
}
