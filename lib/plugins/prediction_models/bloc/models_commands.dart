import 'dart:async';

import 'package:biocentral/plugins/prediction_models/domain/prediction_model_repository.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:fpdart/fpdart.dart';

final class TrainBiotrainerModelCommand extends BiocentralResumableCommand<PredictionModel> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralAPIRepository _apiRepository;
  final BiocentralDatabase _biocentralDatabase;
  final PredictionModelRepository _predictionModelRepository;

  final Map<String, String> _trainingConfiguration;

  TrainBiotrainerModelCommand(
      {required BiocentralProjectRepository biocentralProjectRepository, required BiocentralAPIRepository apiRepository, required BiocentralDatabase biocentralDatabase, required PredictionModelRepository predictionModelRepository, required Map<
          String,
          String> trainingConfiguration})
      : _biocentralProjectRepository = biocentralProjectRepository,
        _apiRepository = apiRepository,
        _biocentralDatabase = biocentralDatabase,
        _predictionModelRepository = predictionModelRepository,
        _trainingConfiguration = trainingConfiguration;


  @override
  Stream<Either<T, PredictionModel>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Training new model!'));

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

    // TODO [Feature] Mask Column
    final trainingData = _biocentralDatabase.getTrainingData(targetColumn: targetColumn, setColumn: setColumn);

    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final biocentralTask = await biocentralAPI.train(config: _trainingConfiguration, trainingData: trainingData);
    final initialModel = _getInitialModel();

    yield* doTraining(biocentralTask, state, initialModel);
  }

  @override
  Stream<Either<T, PredictionModel>> resumeExecution<T extends BiocentralCommandState<T>>(String taskID,
      T state) async* {
    // TODO Resuming needs to be changed
    // yield left(state.setOperating(information: 'Trying to resume training..'));
    // final initialModel = _getInitialModel();
    // final resumedModelEither = await _predictionModelsClient.resumeTraining(taskID, initialModel);
    // yield* resumedModelEither.match((error) async* {
    //   yield left(state.setErrored(information: 'Training could not be resumed! Error: ${error.message}'));
    //   return;
    // }, (resumedModel) async* {
    //   yield* doTraining(taskID, state, resumedModel);
    // });
  }

  Stream<Either<T, PredictionModel>> doTraining<T extends BiocentralCommandState<T>>(
      BiocentralServerTask<Map<String, dynamic>?> task,
      T state,
      PredictionModel initialModel,) async* {
    T trainingState =
    state.setOperating(information: 'Starting training..').copyWith(copyMap: {'trainingModel': initialModel});
    yield left(trainingState);

    PredictionModel currentModel = initialModel;
    int embeddingCurrent = 0;
    int embeddingTotal = 0;
    await for (final (dto, biotrainerResult) in task.run()) {
      if (dto != null) {
        if (dto.status == TaskStatus.RUNNING) {
          if (dto.biotrainerUpdate == null) {
            // Check embedding progress
            embeddingCurrent = dto.embeddingCurrent ?? embeddingCurrent;
            embeddingTotal = dto.embeddingTotal ?? embeddingTotal;
            yield left(
              state.setOperating(
                information: 'Embedding..',
                commandProgress: BiocentralCommandProgress(current: embeddingCurrent, total: embeddingTotal),
              ),
            );
          } else {
            currentModel = currentModel.updateFromDTO(dto);
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
        }
      } else if (biotrainerResult != null) {
        currentModel = PredictionModel.fromMap(biotrainerResult) ?? currentModel;
        _predictionModelRepository.addModel(currentModel);
        yield right(currentModel);
        yield left(state.setFinished(information: 'Finished training model!'));
        return;
      }
    }
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
  final BiocentralAPIRepository _apiRepository;
  final PredictionModel _predictionModel;
  final Set<String> _selectedEntityIDs;

  BiotrainerInferenceCommand({required BiocentralDatabase biocentralDatabase,
    required BiocentralAPIRepository apiRepository,
    required PredictionModel predictionModel,
    required Set<String> selectedEntityIDs})
      : _biocentralDatabase = biocentralDatabase,
        _apiRepository = apiRepository,
        _predictionModel = predictionModel,
        _selectedEntityIDs = selectedEntityIDs;

  @override
  Stream<Either<T, Map<String, dynamic>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Inferencing from trained model..'));

    final Map<String, String> sequenceData = _biocentralDatabase.getSequences()?.filterWithKey((k, v) =>
        _selectedEntityIDs.contains(k)) ?? {};

    if (sequenceData.isEmpty) {
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
    yield left(state.copyWith(copyMap: {'predictions': sequenceData.map((k, v) => MapEntry(k, null))}));

    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final biocentralTask = await biocentralAPI.inference(modelHash: _predictionModel.modelHash!, sequenceData: sequenceData);

    Map<String, dynamic> allPredictions = {};
    int embeddingCurrent = 0;
    int embeddingTotal = 0;
    await for (final (dto, predictions) in biocentralTask.run()) {
      if (dto != null) {
        if (dto.status == TaskStatus.RUNNING) {
          if (dto.embeddingTotal != null || dto.embeddingCurrent != null) {
            // Check embedding progress
            embeddingCurrent = dto.embeddingCurrent ?? embeddingCurrent;
            embeddingTotal = dto.embeddingTotal ?? embeddingTotal;
            yield left(
              state.setOperating(
                information: 'Embedding..',
                commandProgress: BiocentralCommandProgress(current: embeddingCurrent, total: embeddingTotal),
              ),
            );
          } else {
            // TODO Handle prediction progress
          }
        }
      } else if (predictions != null) {
        // TODO Can be simplified
        allPredictions = Map.from(predictions);
        final commandProgress = BiocentralCommandProgress(current: predictions.length ?? 0, hint: 'Predictions');
        state = state
            .setOperating(information: 'Inferencing from trained model..', commandProgress: commandProgress)
            .copyWith(copyMap: {'predictions': allPredictions});

        yield left(state);
      }
    }

    yield right(allPredictions);
    yield left(state.setFinished(information: 'Finished inference!'));
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
