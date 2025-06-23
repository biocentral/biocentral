import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bay_opt/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_training_result.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

/// A command to transfer Bayesian Optimization training configuration and manage the training process.
///
/// This command handles the following:
/// - Transfers training files (sequences, labels, masks) to the server.
/// - Starts the training process on the server.
/// - Monitors the training process and retrieves the results.
///
/// Returns a [BayesianOptimizationTrainingResult] upon successful completion.
class TransferBOTrainingConfigCommand extends BiocentralCommand<BayesianOptimizationTrainingResult> {
  final BiocentralDatabase _biocentralDatabase;
  final BayesianOptimizationClient _boClient;
  final Map<String, dynamic> _trainingConfiguration;
  final String _targetFeature;

  /// Constructor for [TransferBOTrainingConfigCommand].
  ///
  /// - [biocentralDatabase]: The database containing the training data.
  /// - [client]: The Bayesian Optimization client for server communication.
  /// - [trainingConfiguration]: The configuration for the training process.
  /// - [targetFeature]: The feature to optimize during training.
  TransferBOTrainingConfigCommand({
    required BiocentralDatabase biocentralDatabase,
    required BayesianOptimizationClient client,
    required Map<String, dynamic> trainingConfiguration,
    required String targetFeature,
  })  : _biocentralDatabase = biocentralDatabase,
        _boClient = client,
        _trainingConfiguration = trainingConfiguration,
        _targetFeature = targetFeature;

  /// Executes the command to transfer training configuration and manage the training process.
  ///
  /// - [state]: The current state of the command.
  ///
  /// Returns a stream of [Either] objects:
  /// - [Left]: Indicates an error or intermediate state.
  /// - [Right]: Contains the [BayesianOptimizationTrainingResult] upon successful completion.
  @override
  Stream<Either<T, BayesianOptimizationTrainingResult>> execute<T extends BiocentralCommandState<T>>(
    T state,
  ) async* {
    yield left(state.setOperating(information: 'Training new model!'));

    final Map<String, dynamic> entryMap = _biocentralDatabase.databaseToMap();
    final String databaseHash = await _biocentralDatabase.getHash();

    final inputFile = await BiotrainerFileHandler.getBiotrainerInputFile(
      _biocentralDatabase.getType(),
      entryMap,
      _targetFeature,
      '',
    );

    // Transfer training files to the server
    final transferResults = await _transferTrainingFiles(databaseHash, inputFile);
    if (transferResults.isLeft()) {
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
      final initialModel =
          PredictionModel.fromTrainingConfig(_trainingConfiguration).updateStatus(BiocentralTaskStatus.running);

      final T trainingState =
          state.setOperating(information: 'Training model..').copyWith(copyMap: {'trainingModel': initialModel});
      yield left(trainingState);

      //         final actualValues = await _extractActualValues(modelResults);
      var trainingResult =
          BayesianOptimizationTrainingResult(results: [], trainingConfig: _trainingConfiguration, taskID: taskID);
      await for (final (dto, currentResult) in _boClient.boTrainingTaskStream(taskID, trainingResult)) {
        if (currentResult != null) {
          trainingResult = currentResult;
        }
      }

      yield right(trainingResult);
      yield left(state.setFinished(information: 'Finished training model!'));
    });
  }

  /// Transfers training files to the server.
  Future<Either<BiocentralException, Unit>> _transferTrainingFiles(
    String databaseHash,
    String inputFile,
  ) async {
    final transferInputEither = await _boClient.transferFile(
      databaseHash,
      StorageFileType.input,
      () async => inputFile,
    );

    if (transferInputEither.isLeft()) {
      return left(BiocentralNetworkException(message: 'Failed to transfer training files'));
    }
    return right(unit);
  }

  /// Extracts actual values from model results.
  /// TODO Delete or move to another place
  Future<List<double>> _extractActualValues(BayesianOptimizationTrainingResult modelResults) async {
    final List<double> actualValues = [];
    final featureName = _trainingConfiguration['feature_name'];
    final actualFeatureName = 'ACTUAL_$featureName';

    for (var result in modelResults.results!) {
      if (result.id != null) {
        final protein = _biocentralDatabase.getEntityById(result.id!) as Protein?;
        final actualValue = protein?.attributes[actualFeatureName];
        actualValues.add(actualValue != null && actualValue.isNotEmpty ? (double.tryParse(actualValue) ?? -99) : -99);
      } else {
        actualValues.add(-99);
      }
    }
    return actualValues;
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'databaseType': _biocentralDatabase.getEntityTypeName(),
    }..addAll(_trainingConfiguration);
  }

  @override
  String get typeName => 'TransferBOTrainingConfigCommand';
}
