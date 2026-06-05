import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/model/config_options_response.dart';
import 'package:biocentral_api/src/model/config_verification_request.dart';
import 'package:biocentral_api/src/model/config_verification_response.dart';
import 'package:biocentral_api/src/model/prediction.dart';
import 'package:biocentral_api/src/model/biotrainer_model_result.dart';
import 'package:biocentral_api/src/model/sequence_data.dart';
import 'package:biocentral_api/src/model/start_inference_request.dart';
import 'package:biocentral_api/src/model/start_training_request.dart';
import 'package:biocentral_api/src/model/task_dto.dart';
import 'package:biocentral_api/src/model/task_status.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';

import 'tasks/biocentral_server_task.dart';
import 'tasks/dto_handler.dart';
import 'tasks/submit_task.dart';

class _TrainingDtoHandler extends DtoHandler<BiotrainerModelResult> {

  @override
  BiotrainerModelResult? handle(List<TaskDTO> dtos) {
    for (final dto in dtos) {
      if (dto.status == TaskStatus.FINISHED) {
        return dto.biotrainerResult;
      }
    }
    return null;
  }
}

class _InferenceDtoHandler extends DtoHandler<Map<String, List<Prediction>>> {
  @override
  Map<String, List<Prediction>>? handle(List<TaskDTO> dtos) {
    for (final dto in dtos) {
      if (dto.status == TaskStatus.FINISHED) {
        return dto.predictions?.toMap().map((k, v) => MapEntry(k, v.toList()));
      }
    }
    return null;
  }
}

class CustomModelsClient {

  Future<List<dynamic>?> getConfigOptionsForProtocol({required gen.BiocentralApi api, required String protocol}) async {
    final cmApi = api.getCustomModelsApi();
    final resp = await cmApi.configOptionsApiV1CustomModelsServiceConfigOptionsProtocolGet(protocol: protocol);
    final ConfigOptionsResponse optionsResponse = resp.data!;
    return optionsResponse.options.toList();
  }

  Future<String?> verifyTrainingConfig({
    required gen.BiocentralApi api,
    required Map<String, dynamic> config,
  }) async {
    final cmApi = api.getCustomModelsApi();

    final verifyReq =
        ConfigVerificationRequest((b) => b..configDict.replace(config.map((k, v) => MapEntry(k, JsonObject(v)))));
    final verifyResp = await cmApi.verifyConfigApiV1CustomModelsServiceVerifyConfigPost(
      configVerificationRequest: verifyReq,
    );
    final ConfigVerificationResponse verification = verifyResp.data!;
    String? err = verification.error;
    err = (err?.isEmpty ?? true) ? null : err;
    return err;
  }

  /// Verify config then start training.
  Future<BiocentralServerTask<BiotrainerModelResult?>> train({
    required gen.BiocentralApi api,
    required Map<String, dynamic> config,
    required List<SequenceData> trainingData,
  }) async {
    final cmApi = api.getCustomModelsApi();

    // Verify config
    final configVerificationError = await verifyTrainingConfig(api: api, config: config);

    if (configVerificationError != null) {
      throw Exception(configVerificationError);
    }

    final handler = _TrainingDtoHandler();
    final startReq = StartTrainingRequest((b) => b
      ..configDict.replace(config.map((k, v) => MapEntry(k, JsonObject(v))))
      ..trainingData.replace(BuiltList<SequenceData>(trainingData)));

    final taskId = await submitTask(() => cmApi
        .startTrainingApiV1CustomModelsServiceStartTrainingPost(startTrainingRequest: startReq));
    return BiocentralServerTask<BiotrainerModelResult>(taskId: taskId, api: api, dtoHandler: handler);
  }

  /// Start inference for a trained model.
  Future<BiocentralServerTask<Map<String, List<Prediction>>>> inference({
    required gen.BiocentralApi api,
    required String modelHash,
    required Map<String, String> sequenceData,
  }) async {
    final cmApi = api.getCustomModelsApi();
    final startReq = StartInferenceRequest((b) => b
      ..modelHash = modelHash
      ..sequenceData.replace(BuiltMap<String, String>(sequenceData)));

    final taskId = await submitTask(() => cmApi
        .startInferenceApiV1CustomModelsServiceStartInferencePost(startInferenceRequest: startReq));
    return BiocentralServerTask<Map<String, List<Prediction>>>(
      taskId: taskId,
      api: api,
      dtoHandler: _InferenceDtoHandler(),
    );
  }
}
