import 'dart:async';
import 'dart:typed_data';

import 'package:biocentral/plugins/embeddings/data/embeddings_dto.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_client.dart';
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

    await for (final (dto, currentModel)
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
      if (currentModel == null) {
        continue;
      }
      // TODO Support Cross Validation properly
      final int? currentEpoch = currentModel.holdOutResult?.getLastEpoch();
      final commandProgress =
          currentEpoch != null ? BiocentralCommandProgress(current: currentEpoch, hint: 'Epoch') : null;
      trainingState =
          trainingState.setOperating(information: 'Training model..', commandProgress: commandProgress).copyWith(
        copyMap: {
          'trainingModel': currentModel,
        },
      );
      yield left(trainingState);
    }

    // Receive files after training has finished
    // TODO Handle case that training was interrupted/failed
    final modelFilesEither = await _predictionModelsClient.getModelFiles(taskID);
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
