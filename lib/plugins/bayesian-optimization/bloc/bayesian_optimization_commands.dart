import 'package:biocentral/plugins/bayesian-optimization/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

class TransferBOTrainingConfigCommand extends BiocentralCommand<BayesianOptimizationTrainingResult> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabase _biocentralDatabase;
  final BayesianOptimizationClient _boClient;
  final Map<String, dynamic?> _trainingConfiguration;

  TransferBOTrainingConfigCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralDatabase biocentralDatabase,
    required BayesianOptimizationClient client,
    required Map<String, dynamic?> trainingConfiguration,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _biocentralDatabase = biocentralDatabase,
        _boClient = client,
        _trainingConfiguration = trainingConfiguration;

  @override
  Stream<Either<T, BayesianOptimizationTrainingResult>> execute<T extends BiocentralCommandState<T>>(
    T state,
  ) async* {
    yield left(state.setOperating(information: 'Training new model!'));

    final String configFile = BiotrainerFileHandler.biotrainerConfigurationToConfigFile(
      _trainingConfiguration,
    );

    final Map<String, dynamic> entryMap = _biocentralDatabase.databaseToMap();
    final String databaseHash = await _biocentralDatabase.getHash();

    final String? modelArchitecture = _trainingConfiguration['model'];
    final String? targetFeature = _trainingConfiguration['feature'];

    if (modelArchitecture == null || targetFeature == null) {
      yield left(
        state.setErrored(
          information: 'Invalid training configuration: $modelArchitecture, $targetFeature',
        ),
      );
      return;
    }

    final fileRecord = await BiotrainerFileHandler.getBiotrainerInputFiles(
      _biocentralDatabase.getType(),
      entryMap,
      targetFeature,
      '',
    );

    // TODO Error handling

    final transferEitherSequences = await _boClient.transferFile(
      databaseHash,
      StorageFileType.sequences,
      () async => fileRecord.$1,
    );
    final transferEitherLabels = await _boClient.transferFile(
      databaseHash,
      StorageFileType.labels,
      () async => fileRecord.$2,
    );
    final transferEitherMasks = await _boClient.transferFile(
      databaseHash,
      StorageFileType.masks,
      () async => fileRecord.$3,
    );

    if (transferEitherSequences.isLeft() || transferEitherLabels.isLeft() || transferEitherMasks.isLeft()) {
      yield left(
        state.setErrored(
          information: 'Error transferring training files to server!',
        ),
      );
      return;
    }

    final taskIDEither = await _boClient.startTraining(configFile, databaseHash);
    yield* taskIDEither.match((error) async* {
      yield left(
        state.setErrored(
          information: 'Training could not be started! Error: ${error.message}',
        ),
      );
      return;
    }, (taskID) async* {
      final initialModel = BiotrainerFileHandler.parsePredictionModel(
        biotrainerConfig: _trainingConfiguration,
        failOnConflict: false,
      )..setTraining();
      T trainingState =
          state.setOperating(information: 'Training model..').copyWith(copyMap: {'trainingModel': initialModel});
      yield left(trainingState);

      await for (PredictionModel? currentModel in _boClient.biotrainerTrainingTaskStream(taskID, initialModel)) {
        if (currentModel == null) {
          continue;
        }
        final int? currentEpoch = currentModel.biotrainerTrainingResult?.getLastEpoch();
        final commandProgress =
            currentEpoch != null ? BiocentralCommandProgress(current: currentEpoch, hint: 'Epoch') : null;
        trainingState = trainingState
            .setOperating(
          information: 'Training model..',
          commandProgress: commandProgress,
        )
            .copyWith(
          copyMap: {
            'trainingModel': currentModel,
          },
        );
        yield left(trainingState);
      }

      state.setFinished(information: 'Training finished');
      //TODO: Yield the result
      yield right(dummyData);
    });
  }

  String _configToString(Map<String, dynamic> config) {
    return config.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'databaseType': _biocentralDatabase.getType(),
    }..addAll(_trainingConfiguration);
  }

  // EXAMPLE DATA
  final BayesianOptimizationTrainingResult dummyData = const BayesianOptimizationTrainingResult(
    results: [
      BayesianOptimizationTrainingResultData(proteinId: '1', prediction: 32, uncertainty: -1.4, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '2', prediction: 35, uncertainty: -1.0, utility: -1.2),
      BayesianOptimizationTrainingResultData(proteinId: '3', prediction: 37, uncertainty: -0.8, utility: -0.5),
      BayesianOptimizationTrainingResultData(proteinId: '4', prediction: 40, uncertainty: -0.5, utility: -0.2),
      BayesianOptimizationTrainingResultData(proteinId: '5', prediction: 42, uncertainty: -0.2, utility: 0.0),
      BayesianOptimizationTrainingResultData(proteinId: '6', prediction: 45, uncertainty: 0.0, utility: 0.2),
      BayesianOptimizationTrainingResultData(proteinId: '7', prediction: 47, uncertainty: 0.2, utility: 0.5),
      BayesianOptimizationTrainingResultData(proteinId: '8', prediction: 50, uncertainty: 0.5, utility: 0.8),
      BayesianOptimizationTrainingResultData(proteinId: '9', prediction: 52, uncertainty: 0.8, utility: 1.0),
      BayesianOptimizationTrainingResultData(proteinId: '10', prediction: 55, uncertainty: 1.0, utility: 1.5),
      BayesianOptimizationTrainingResultData(proteinId: '11', prediction: 32, uncertainty: -1.5, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '12', prediction: 35, uncertainty: -1.1, utility: -1.2),
      BayesianOptimizationTrainingResultData(proteinId: '13', prediction: 37, uncertainty: -0.1, utility: -0.5),
      BayesianOptimizationTrainingResultData(proteinId: '14', prediction: 40, uncertainty: -0.2, utility: -0.2),
      BayesianOptimizationTrainingResultData(proteinId: '15', prediction: 42, uncertainty: -0.5, utility: 1.0),
      BayesianOptimizationTrainingResultData(proteinId: '16', prediction: 45, uncertainty: 0.5, utility: 1.2),
      BayesianOptimizationTrainingResultData(proteinId: '17', prediction: 47, uncertainty: 0.6, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '18', prediction: 50, uncertainty: 0.1, utility: 0.8),
    ],
  );
}
