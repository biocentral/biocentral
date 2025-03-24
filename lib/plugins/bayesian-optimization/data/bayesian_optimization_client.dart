import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

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
    final responseEither = await doPostRequest(PredictionModelsServiceEndpoints.startTraining,
        trainingConfig.map((key, value) => MapEntry(key, value.toString())));
    return responseEither.flatMap((responseMap) => right(responseMap['task_id']));
  }

  Stream<PredictionModel?> biotrainerTrainingTaskStream(
    String taskID,
    PredictionModel initialModel,
  ) async* {
    PredictionModel? updateFunction(
      PredictionModel? currentModel,
      BiocentralDTO biocentralDTO,
    ) =>
        currentModel?.updateTrainingResult(
          BiotrainerTrainingResult.fromDTO(biocentralDTO).getOrElse((e) => null),
        );
    yield* taskUpdateStream<PredictionModel?>(
      taskID,
      initialModel,
      updateFunction,
    );
  }

  @override
  String getServiceName() {
    return 'bayesian_optimization_service';
  }
}
// BOTrainingResult? trainingResult; trainingResult.updateFromDTO(biocentralDTO)
