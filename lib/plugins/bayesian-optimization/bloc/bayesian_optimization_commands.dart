import 'package:biocentral/plugins/bayesian-optimization/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

class TransferBOTrainingConfigCommand extends BiocentralCommand<void> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabase _biocentralDatabase;
  final BayesianOptimizationClient _boClient;
  final Map<String, String?> _trainingConfiguration;

  TransferBOTrainingConfigCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralDatabase biocentralDatabase,
    required BayesianOptimizationClient client,
    required Map<String, String?> trainingConfiguration,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _biocentralDatabase = biocentralDatabase,
        _boClient = client,
        _trainingConfiguration = trainingConfiguration;

  @override
  Stream<Either<T, void>> execute<T extends BiocentralCommandState<T>>(
    T state,
  ) async* {
    yield left(state.setOperating(information: 'Training new model!'));

    final String configFile =
        BiotrainerFileHandler.biotrainerConfigurationToConfigFile(
      _trainingConfiguration,
    );

    final Map<String, dynamic> entryMap = _biocentralDatabase.databaseToMap();
    final String databaseHash = await _biocentralDatabase.getHash();

    final String? modelArchitecture = _trainingConfiguration['model'];
    final String? targetFeature = _trainingConfiguration['feature'];

    if (modelArchitecture == null || targetFeature == null) {
      yield left(
        state.setErrored(
          information:
              'Invalid training configuration: $modelArchitecture, $targetFeature',
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

    if (transferEitherSequences.isLeft() ||
        transferEitherLabels.isLeft() ||
        transferEitherMasks.isLeft()) {
      yield left(
        state.setErrored(
          information: 'Error transferring training files to server!',
        ),
      );
      return;
    }

    final taskIDEither =
        await _boClient.startTraining(configFile, databaseHash);
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
      T trainingState = state
          .setOperating(information: 'Training model..')
          .copyWith(copyMap: {'trainingModel': initialModel});
      yield left(trainingState);

      await for (PredictionModel? currentModel
          in _boClient.biotrainerTrainingTaskStream(taskID, initialModel)) {
        if (currentModel == null) {
          continue;
        }
        final int? currentEpoch =
            currentModel.biotrainerTrainingResult?.getLastEpoch();
        final commandProgress = currentEpoch != null
            ? BiocentralCommandProgress(current: currentEpoch, hint: 'Epoch')
            : null;
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
}
