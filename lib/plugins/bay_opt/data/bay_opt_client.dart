import 'package:biocentral/plugins/bay_opt/data/bay_opt_dto.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

import '../model/bay_opt_training_result.dart';
import 'bay_opt_service_api.dart';

/// Factory for creating [BayOptClient] instances.
final class BayOptClientFactory extends BiocentralClientFactory<BayOptClient> {
  @override
  BayOptClient create(BiocentralServerData? server, BiocentralHubServerClient hubServerClient) {
    return BayOptClient(server, hubServerClient);
  }
}

/// Client for interacting with the Bayesian Optimization service API.
class BayOptClient extends BiocentralClient {
  /// Creates a new [BayOptClient].
  BayOptClient(super._server, super._hubServerClient);

  /// Starts a Bayesian Optimization training job on the server.
  /// Returns task ID on success or exception on failure.
  Future<Either<BiocentralException, String>> startTraining(
    Map<String, dynamic> trainingConfig,
    String databaseHash,
  ) async {
    final responseEither = await doPostRequest(BayOptServiceEndpoints.startTraining,
        trainingConfig.map((key, value) => MapEntry(key, value.toString())));
    return responseEither.flatMap((responseMap) => right(responseMap['task_id']));
  }

  /// Updates the current model state from a DTO received during training.
  BayOptTrainingResult? updateFunction(
    BayOptTrainingResult? currentResult,
    BiocentralDTO? dto,
  ) {
    if (dto == null) {
      return currentResult;
    }
    final results = dto.bayOptResults;
    if (results == null) {
      return currentResult;
    }

    final resultData = <BayOptTrainingResultData>[];
    for(final resultMap in results) {
      resultData.add(BayOptTrainingResultData.fromMap(resultMap));
    }
    return currentResult?.copyWith(results: resultData);
  }

  /// Creates a stream that monitors the Bayesian Optimization training task.
  Stream<(BiocentralDTO, BayOptTrainingResult?)> boTrainingTaskStream(
    String taskID,
    BayOptTrainingResult initialResult,
  ) async* {
    yield* taskUpdateStream<BayOptTrainingResult?>(taskID, initialResult, updateFunction);
  }

  @override
  String getServiceName() {
    return 'bayesian_optimization_service';
  }
}
