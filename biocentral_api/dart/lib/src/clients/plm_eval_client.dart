import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/model/plm_eval_autoeval_request.dart';
import 'package:biocentral_api/src/model/plm_eval_information_response.dart';
import 'package:biocentral_api/src/model/plm_eval_validate_request.dart';
import 'package:biocentral_api/src/model/plm_eval_validate_response.dart';
import 'package:biocentral_api/src/model/task_dto.dart';
import 'package:biocentral_api/src/model/task_status.dart';

import '../model/auto_eval_report.dart';
import '../model/plm_eval_information.dart';
import 'tasks/biocentral_server_task.dart';
import 'tasks/dto_handler.dart';

class _PLMEvalDTOHandler extends DtoHandler<AutoEvalReport> {
  @override
  AutoEvalReport? handle(List<TaskDTO> dtos) {
    for (final dto in dtos) {
      if (dto.status == TaskStatus.FINISHED) {
        return dto.autoevalProgress?.finalReport;
      }
    }
    return null;
  }
}

class PlmEvalClient {
  Future<PLMEvalInformation?> getPlmEvalInformation({
    required gen.BiocentralApi api,
  }) async {
    final plmEvalApi = api.getPlmEvalApi();

    final informationResp =
      await plmEvalApi.plmEvalInformationApiV1PlmEvalServicePlmEvalInformationGet();
    final PLMEvalInformationResponse? information = informationResp.data;
    return information?.info;
  }


  Future<String?> validateModelID({
    required gen.BiocentralApi api,
    required String modelID,
  }) async {
    final plmEvalApi = api.getPlmEvalApi();

    final validateReq = PLMEvalValidateRequest((b) => b..modelId = modelID);
    final validateResp =
        await plmEvalApi.validateApiV1PlmEvalServiceValidateModelIdPost(pLMEvalValidateRequest: validateReq);
    final PLMEvalValidateResponse validation = validateResp.data!;
    String? err = validation.error;
    err = (err?.isEmpty ?? true) ? null : err;
    return err;
  }

  Future<BiocentralServerTask<AutoEvalReport?>> autoeval({
    required gen.BiocentralApi api,
    required String modelID,
    String? onnxFile,
    String? tokenizerConfig,
  }) async {
    final plmEvalApi = api.getPlmEvalApi();
    final autoevalRequest = PLMEvalAutoevalRequest((b) => b
      ..modelId = modelID
      ..onnxFile = onnxFile
      ..tokenizerConfig = tokenizerConfig);

    final startResp = await plmEvalApi.autoevalApiV1PlmEvalServiceAutoevalPost(pLMEvalAutoevalRequest: autoevalRequest);
    final taskId = startResp.data!.taskId;
    final handler = _PLMEvalDTOHandler();
    return BiocentralServerTask<AutoEvalReport?>(taskId: taskId, api: api, dtoHandler: handler);
  }
}
