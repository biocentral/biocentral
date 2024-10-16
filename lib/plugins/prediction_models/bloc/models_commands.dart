import 'dart:async';

import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

import '../data/biotrainer_file_handler.dart';
import '../data/prediction_models_client.dart';
import '../domain/prediction_model_repository.dart';
import '../model/prediction_model.dart';

final class TrainBiotrainerModelCommand extends BiocentralCommand<PredictionModel> {
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
    yield left(state.setOperating(information: "Training new model!"));

    String configFile = BiotrainerFileHandler.biotrainerConfigurationToConfigFile(_trainingConfiguration);

    Map<String, dynamic> entryMap = _biocentralDatabase.databaseToMap();
    String databaseHash = await _biocentralDatabase.getHash();

    String? modelArchitecture = _trainingConfiguration["model_choice"];
    String? targetColumn = _trainingConfiguration["target_column"];
    String? setColumn = _trainingConfiguration["set_column"];

    if (modelArchitecture == null || targetColumn == null || setColumn == null) {
      yield left(state.setErrored(
          information: "Invalid training configuration: $modelArchitecture, $targetColumn, $setColumn"));
    } else {
      var fileRecord = await BiotrainerFileHandler.getBiotrainerInputFiles(
          _biocentralDatabase.getType(), entryMap, targetColumn, setColumn);

      // TODO Error handling

      final transferEitherSequences = await _predictionModelsClient.transferFile(
          databaseHash, StorageFileType.sequences, () async => fileRecord.$1);
      final transferEitherLabels =
          await _predictionModelsClient.transferFile(databaseHash, StorageFileType.labels, () async => fileRecord.$2);
      final transferEitherMasks =
          await _predictionModelsClient.transferFile(databaseHash, StorageFileType.masks, () async => fileRecord.$3);

      if (transferEitherSequences.isLeft() || transferEitherLabels.isLeft() || transferEitherMasks.isLeft()) {
        yield left(state.setErrored(information: "Error transferring training files to server!"));
      } else {
        final modelHashEither = await _predictionModelsClient.startTraining(configFile, databaseHash);
        yield* modelHashEither.match((error) async* {
          yield left(state.setErrored(information: "Training could not be started! Error: ${error.message}"));
        }, (modelHash) async* {
          T trainingState = state
              .setOperating(information: "Training model..")
              .copyWith(copyMap: {"modelArchitecture": modelArchitecture});
          yield left(trainingState);

          await for (String data in _predictionModelsClient.biotrainerTrainingStatusStream(modelHash)) {
            trainingState = trainingState
                .setOperating(information: "Training model..")
                .copyWith(copyMap: {"trainingOutput": data.split("\n")});
            yield left(trainingState);
          }

          // Receive files after training has finished
          // TODO Handle case that training was interrupted/failed
          final modelFilesEither = await _predictionModelsClient.getModelFiles(databaseHash, modelHash);
          yield* modelFilesEither.match((error) async* {
            yield left(state.setErrored(information: "Could not retrieve model files! Error: ${error.message}"));
          }, (modelFiles) async* {
            PredictionModel predictionModel = BiotrainerFileHandler.parsePredictionModelFromRawFiles(
                biotrainerConfig: modelFiles[StorageFileType.biotrainer_config],
                biotrainerOutput: modelFiles[StorageFileType.biotrainer_result],
                // TODO Might be a good idea to optimize this not to transfer logs twice
                biotrainerTrainingLog: modelFiles[StorageFileType.biotrainer_logging],
                biotrainerCheckpoints: modelFiles[StorageFileType.biotrainer_checkpoint],
                failOnConflict: true);

            // Save files
            for (MapEntry<StorageFileType, dynamic> fileEntry in modelFiles.entries) {
              await _biocentralProjectRepository.handleSave(
                  fileName: fileEntry.key.name, content: fileEntry.value.toString());
            }

            _predictionModelRepository.addModel(predictionModel);
            yield right(predictionModel);
            yield left(state.setFinished(information: "Finished training model!"));
          });
        });
      }
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      "databaseType": _biocentralDatabase.getType(),
    }..addAll(_trainingConfiguration);
  }
}
