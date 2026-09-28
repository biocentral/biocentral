import 'package:biocentral_api/biocentral_api.dart';
import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/clients/tasks/dto_handler.dart';
import 'package:biocentral_api/src/clients/tasks/submit_task.dart';
import 'package:biocentral_api/src/model/active_learning_engineering_iteration_request.dart';

class _EngineeringIterationDTOHandler extends DtoHandler<ActiveLearningIterationResult> {
  @override
  ActiveLearningIterationResult? handle(List<TaskDTO> dtos) {
    for (final dto in dtos) {
      if (dto.status == TaskStatus.FINISHED) {
        return dto.alIterationResult;
      }
    }
    return null;
  }

  @override
  void updateProgress(List<TaskDTO> dtos) {}
}

class EngineeringClient {
  /// Start an active learning engineering iteration.
  Future<BiocentralServerTask<ActiveLearningIterationResult>> engineeringIteration({
    required gen.BiocentralApi api,
    required ActiveLearningEngineeringCampaignConfig campaignConfig,
    required ActiveLearningEngineeringIterationConfig iterationConfig,
  }) async {
    final alApi = api.getActiveLearningApi();

    final handler = _EngineeringIterationDTOHandler();
    final iterationRequest = ActiveLearningEngineeringIterationRequest((b) => b
      ..campaignConfig.replace(campaignConfig)
      ..iterationConfig.replace(iterationConfig));

    final taskId = await submitTask(
        () => alApi.activeLearningEngineeringIterationApiV1ActiveLearningServiceEngineeringIterationPost(
              activeLearningEngineeringIterationRequest: iterationRequest,
            ));
    return BiocentralServerTask<ActiveLearningIterationResult>(taskId: taskId, api: api, dtoHandler: handler);
  }
}
