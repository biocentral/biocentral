import 'package:biocentral/plugins/bayesian-optimization/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

class TransferBOTrainingConfigCommand extends BiocentralCommand<BayesianOptimizationTrainingResult> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabase _biocentralDatabase;
  final BayesianOptimizationClient _boClient;
  final Map<String, dynamic> _trainingConfiguration;
  final String _targetFeature;

  TransferBOTrainingConfigCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralDatabase biocentralDatabase,
    required BayesianOptimizationClient client,
    required Map<String, dynamic> trainingConfiguration,
    required String targetFeature,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _biocentralDatabase = biocentralDatabase,
        _boClient = client,
        _trainingConfiguration = trainingConfiguration,
        _targetFeature = targetFeature;

  @override
  Stream<Either<T, BayesianOptimizationTrainingResult>> execute<T extends BiocentralCommandState<T>>(
    T state,
  ) async* {
    yield left(state.setOperating(information: 'Training new model!'));

    final Map<String, dynamic> entryMap = _biocentralDatabase.databaseToMap();
    final String databaseHash = await _biocentralDatabase.getHash();

    final fileRecord = await BiotrainerFileHandler.getBiotrainerInputFiles(
      _biocentralDatabase.getType(),
      entryMap,
      _targetFeature,
      '',
    );

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

    final taskIDEither = await _boClient.startTraining(_trainingConfiguration, databaseHash);
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

      await for (String? currentModel in _boClient.biotrainerTrainingTaskStream(taskID, '')) {
        if (currentModel == null) {
          continue;
        }
        yield left(trainingState);
      }

      // Receive files after training has finished
      // TODO Handle case that training was interrupted/failed
      final modelResultsEither = await _boClient.getModelResults(databaseHash, taskID);
      yield* modelResultsEither.match((error) async* {
        yield left(state.setErrored(information: 'Could not retrieve model files! Error: ${error.message}'));
        return;
      }, (modelResults) async* {
        yield right(modelResults);
        yield left(state.setFinished(information: 'Finished training model!'));
      });
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

  @override
  String get typeName => 'TransferBOTrainingConfigCommand';
}
