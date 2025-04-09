import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

import '../model/bayesian_optimization_training_result.dart';
import 'bayesian_optimization_service_api.dart';

final class BayesianOptimizationClientFactory extends BiocentralClientFactory<BayesianOptimizationClient> {
  @override
  BayesianOptimizationClient create(BiocentralServerData? server, BiocentralHubServerClient hubServerClient) {
    return BayesianOptimizationClient(server, hubServerClient);
  }
}

class BayesianOptimizationClient extends BiocentralClient {
  BayesianOptimizationClient(super._server, super._hubServerClient);

  Future<Either<BiocentralException, String>> startTraining(
    Map<String, dynamic> trainingConfig,
    String databaseHash,
  ) async {
    final responseEither = await doPostRequest(BayesianOptimizationServiceEndpoints.startTraining,
        trainingConfig.map((key, value) => MapEntry(key, value.toString())));
    return responseEither.flatMap((responseMap) => right(responseMap['task_id']));
  }

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

  String? _updateFunction(String? currentModel, BiocentralDTO? dto) {
    return null;
  }

  Stream<String?> biotrainerTrainingTaskStream(String taskID, String initialModel) async* {
    yield* taskUpdateStream<String?>(taskID, initialModel, _updateFunction);
  }

  @override
  String getServiceName() {
    return 'bayesian_optimization_service';
  }
}
// BOTrainingResult? trainingResult; trainingResult.updateFromDTO(biocentralDTO)
