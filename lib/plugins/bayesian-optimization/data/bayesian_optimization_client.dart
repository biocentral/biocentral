import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

import '../model/bayesian_optimization_training_result.dart';
import 'bayesian_optimization_service_api.dart';

/// Factory for creating [BayesianOptimizationClient] instances.
final class BayesianOptimizationClientFactory extends BiocentralClientFactory<BayesianOptimizationClient> {
  @override
  BayesianOptimizationClient create(BiocentralServerData? server, BiocentralHubServerClient hubServerClient) {
    return BayesianOptimizationClient(server, hubServerClient);
  }
}

/// Client for interacting with the Bayesian Optimization service API.
class BayesianOptimizationClient extends BiocentralClient {
  /// Creates a new [BayesianOptimizationClient].
  BayesianOptimizationClient(super._server, super._hubServerClient);

  /// Starts a Bayesian Optimization training job on the server.
  /// Returns task ID on success or exception on failure.
  Future<Either<BiocentralException, String>> startTraining(
    Map<String, dynamic> trainingConfig,
    String databaseHash,
  ) async {
    final responseEither = await doPostRequest(BayesianOptimizationServiceEndpoints.startTraining,
        trainingConfig.map((key, value) => MapEntry(key, value.toString())));
    return responseEither.flatMap((responseMap) => right(responseMap['task_id']));
  }

  /// Retrieves results of a completed Bayesian Optimization training job.
  Future<Either<BiocentralException, BayesianOptimizationTrainingResult>> getModelResults(
    String databaseHash,
    String taskId,
  ) async {
    final responseEither = await doPostRequest(
      BayesianOptimizationServiceEndpoints.modelResults,
      {'database_hash': databaseHash, 'task_id': taskId},
    );
    return responseEither.match((error) => left(error), (responseData) {
      final resultsList = (responseData['result'] as List)
          .map((item) => BayesianOptimizationTrainingResultData.fromMap(item as Map<String, dynamic>))
          .toList();

      return right(BayesianOptimizationTrainingResult(results: resultsList));
    });
  }

  /// Updates the current model state from a DTO received during training.
  String? updateFunction(String? currentModel, BiocentralDTO? dto) {
    // TODO: Implement model updating from DTO
    return null;
  }

  /// Creates a stream that monitors the Bayesian Optimization training task.
  Stream<String?> biotrainerTrainingTaskStream(String taskID, String initialModel) async* {
    yield* taskUpdateStream<String?>(taskID, initialModel, updateFunction);
  }

  @override
  String getServiceName() {
    return 'bayesian_optimization_service';
  }
}
