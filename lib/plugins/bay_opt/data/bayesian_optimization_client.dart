import 'package:biocentral/plugins/bay_opt/data/bay_opt_dto.dart';
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

  /// Updates the current model state from a DTO received during training.
  BayesianOptimizationTrainingResult? updateFunction(
    BayesianOptimizationTrainingResult? currentResult,
    BiocentralDTO? dto,
  ) {
    if (dto == null) {
      return currentResult;
    }
    final results = dto.bayOptResults;
    if (results == null) {
      return currentResult;
    }

    final resultData = <BayesianOptimizationTrainingResultData>[];
    for(final resultMap in results) {
      resultData.add(BayesianOptimizationTrainingResultData.fromMap(resultMap));
    }
    return currentResult?.copyWith(results: resultData);
  }

  /// Creates a stream that monitors the Bayesian Optimization training task.
  Stream<BayesianOptimizationTrainingResult?> biotrainerTrainingTaskStream(
    String taskID,
    BayesianOptimizationTrainingResult initialResult,
  ) async* {
    yield* taskUpdateStream<BayesianOptimizationTrainingResult?>(taskID, initialResult, updateFunction);
  }

  @override
  String getServiceName() {
    return 'bayesian_optimization_service';
  }
}
