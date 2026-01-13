import 'package:biocentral_api/src/model/model_metadata.dart';
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/model/prediction_request.dart';
import 'package:biocentral_api/src/model/task_dto.dart';
import 'package:biocentral_api/src/model/task_status.dart';
import 'package:biocentral_api/src/model/prediction.dart';

import 'tasks/biocentral_server_task.dart';
import 'tasks/dto_handler.dart';

class _PredictDtoHandler extends DtoHandler<Map<String, List<Prediction>>> {
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

class PredictClient {

  Future<List<ModelMetadata>?> getModelMetadata({
    required gen.BiocentralApi api,
  }) async {
    final predictionApi = api.getPredictionApi();
    final resp = await predictionApi.modelMetadataApiV1PredictionServiceModelMetadataGet();
    final metadataResponse = resp.data!;
    return metadataResponse.metadata.toList();
  }

  /// Start a prediction task using provided model names and sequences.
  Future<BiocentralServerTask<Map<String, List<Prediction>>>> predict({
    required gen.BiocentralApi api,
    required List<String> modelNames,
    required Map<String, String> sequenceData,
  }) async {
    final predictionApi = api.getPredictionApi();
    final req = PredictionRequest((b) => b
      ..modelNames.replace(BuiltList<String>(modelNames))
      ..sequenceInput.replace(BuiltMap<String, String>(sequenceData)));

    final startResp = await predictionApi.predictApiV1PredictionServicePredictPost(predictionRequest: req);
    final taskId = startResp.data!.taskId;
    final handler = _PredictDtoHandler();
    return BiocentralServerTask<Map<String, List<Prediction>>>(taskId: taskId, api: api, dtoHandler: handler);
  }
}
