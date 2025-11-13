import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_training_result.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

/// A command to transfer Bayesian Optimization training configuration and manage the training process.
///
/// This command handles the following:
/// - Transfers training files (sequences, labels, masks) to the server.
/// - Starts the training process on the server.
/// - Monitors the training process and retrieves the results.
///
/// Returns a [BayOptTrainingResult] upon successful completion.
class BayOptIterationCommand extends BiocentralCommand<BayOptTrainingResult> {
  final BiocentralDatabase _biocentralDatabase;
  final BiocentralAPIRepository _apiRepository;
  final Map<String, dynamic> _trainingConfiguration;
  final String _targetFeature;

  /// Constructor for [BayOptIterationCommand].
  ///
  /// - [biocentralDatabase]: The database containing the training data.
  /// - [client]: The Bayesian Optimization client for server communication.
  /// - [trainingConfiguration]: The configuration for the training process.
  /// - [targetFeature]: The feature to optimize during training.
  BayOptIterationCommand({
    required BiocentralDatabase biocentralDatabase,
    required BiocentralAPIRepository apiRepository,
    required Map<String, dynamic> trainingConfiguration,
    required String targetFeature,
  })  : _biocentralDatabase = biocentralDatabase,
        _apiRepository = apiRepository,
        _trainingConfiguration = trainingConfiguration,
        _targetFeature = targetFeature;

  /// Executes the command to transfer training configuration and manage the training process.
  ///
  /// - [state]: The current state of the command.
  ///
  /// Returns a stream of [Either] objects:
  /// - [Left]: Indicates an error or intermediate state.
  /// - [Right]: Contains the [BayOptTrainingResult] upon successful completion.
  @override
  Stream<Either<T, BayOptTrainingResult>> execute<T extends BiocentralCommandState<T>>(
    T state,
  ) async* {
    throw UnimplementedError();
    /*
    // TODO [Refactoring] Adapt to biocentral API
    yield left(state.setOperating(information: 'Training new model!'));

    final Map<String, dynamic> entryMap = _biocentralDatabase.databaseToMap();
    final String databaseHash = await _biocentralDatabase.getHash();


    final taskIDEither = await _boClient.startTraining(_trainingConfiguration, databaseHash);
    yield* taskIDEither.match((error) async* {
      yield left(
        state.setErrored(
          information: 'Training could not be started! Error: ${error.message}',
        ),
      );
      return;
    }, (taskID) async* {
      final initialModel = PredictionModel.fromTrainingConfig(_trainingConfiguration)
          .copyWith(trainingStatus: BiocentralTaskStatus.running);

      final T trainingState =
          state.setOperating(information: 'Training model..').copyWith(copyMap: {'trainingModel': initialModel});
      yield left(trainingState);

      var trainingResult = BayOptTrainingResult(
          results: [], trainingConfig: BayOptConfig.fromMap(_trainingConfiguration), taskID: taskID);
      await for (final (dto, currentResult) in _boClient.boTrainingTaskStream(taskID, trainingResult)) {
        if (currentResult != null) {
          trainingResult = currentResult;
        }
      }

      yield right(trainingResult);
      yield left(state.setFinished(information: 'Finished training model!'));
    });

     */
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
