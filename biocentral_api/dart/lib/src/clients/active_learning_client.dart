import 'package:biocentral_api/biocentral_api.dart';
import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/clients/tasks/dto_handler.dart';
import 'package:biocentral_api/src/clients/tasks/submit_task.dart';
import 'package:biocentral_api/src/model/active_learning_screening_iteration_request.dart';

class _ActiveLearningIterationDTOHandler extends DtoHandler<ActiveLearningIterationResult> {
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

class ActiveLearningClient {
  /// Start a prediction task using provided model names and sequences.
  Future<BiocentralServerTask<ActiveLearningIterationResult>> activeLearningIteration({
    required gen.BiocentralApi api,
    required ActiveLearningScreeningCampaignConfig campaignConfig,
    required ActiveLearningScreeningIterationConfig iterationConfig,
  }) async {
    final alApi = api.getActiveLearningApi();

    final handler = _ActiveLearningIterationDTOHandler();
    final iterationRequest = ActiveLearningScreeningIterationRequest((b) => b
      ..campaignConfig.replace(campaignConfig)
      ..iterationConfig.replace(iterationConfig));

    final taskId =
        await submitTask(() => alApi.activeLearningScreeningIterationApiV1ActiveLearningServiceScreeningIterationPost(
              activeLearningScreeningIterationRequest: iterationRequest,
            ));
    return BiocentralServerTask<ActiveLearningIterationResult>(taskId: taskId, api: api, dtoHandler: handler);
  }
}
