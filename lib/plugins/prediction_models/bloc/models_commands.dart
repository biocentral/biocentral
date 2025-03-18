import 'dart:async';
import 'dart:typed_data';

import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_client.dart';
import 'package:biocentral/plugins/prediction_models/domain/prediction_model_repository.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
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

    final fileRecord = await BiotrainerFileHandler.getBiotrainerInputFiles(
      _biocentralDatabase.getType(),
      entryMap,
      targetColumn,
      setColumn,
    );

    // TODO Error handling

    final transferEitherSequences = await _predictionModelsClient.transferFile(
      databaseHash,
      StorageFileType.sequences,
      () async => fileRecord.$1,
    );
    final transferEitherLabels =
        await _predictionModelsClient.transferFile(databaseHash, StorageFileType.labels, () async => fileRecord.$2);
    final transferEitherMasks =
        await _predictionModelsClient.transferFile(databaseHash, StorageFileType.masks, () async => fileRecord.$3);

    if (transferEitherSequences.isLeft() || transferEitherLabels.isLeft() || transferEitherMasks.isLeft()) {
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
        state.setOperating(information: 'Training model..').copyWith(copyMap: {'trainingModel': initialModel});
    yield left(trainingState);

    await for (PredictionModel? currentModel
        in _predictionModelsClient.biotrainerTrainingTaskStream(taskID, initialModel)) {
      if (currentModel == null) {
        continue;
      }
      final int? currentEpoch = currentModel.biotrainerTrainingResult?.getLastEpoch();
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
        // TODO [Optimization] Might be a good idea to optimize this not to transfer logs twice
        loggingFile: modelFiles[StorageFileType.biotrainer_logging],
        checkpointFiles: checkpoints,
      );

      final modelResult = updatedModels.last;

      yield right(modelResult);
      yield left(state.setFinished(information: 'Finished training model!'));
    });
  }

  PredictionModel _getInitialModel() {
    return BiotrainerFileHandler.parsePredictionModel(
      biotrainerConfig: _trainingConfiguration,
      failOnConflict: false,
    )..setTraining();
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {'databaseType': _biocentralDatabase.getEntityTypeName(), 'trainingConfiguration': _trainingConfiguration};
  }

  @override
  String get typeName => 'TrainBiotrainerModelCommand';
}
