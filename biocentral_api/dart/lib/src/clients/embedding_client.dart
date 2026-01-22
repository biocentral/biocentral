import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/model/embed_request.dart';
import 'package:biocentral_api/src/model/projection_request.dart';
import 'package:biocentral_api/src/model/task_dto.dart';
import 'package:biocentral_api/src/model/task_status.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';

import 'tasks/biocentral_server_task.dart';
import 'tasks/dto_handler.dart';
import 'tasks/submit_task.dart';

class _EmbedDtoHandler extends DtoHandler<String> {
  int? _total;
  int _last = 0;

  @override
  String? handle(List<TaskDTO> dtos) {
    for (final dto in dtos) {
      if (dto.status == TaskStatus.FINISHED) {
        return dto.embeddingsFile;
      }
    }
    return null;
  }

  @override
  void updateProgress(List<TaskDTO> dtos) {
    for (final dto in dtos) {
      if (dto.status == TaskStatus.RUNNING || dto.status == TaskStatus.FINISHED) {
        _total ??= dto.embeddingProgress?.total;
        final current = dto.embeddingProgress?.current;
        if (current != null && _total != null) {
          // Placeholder hook: users can attach a progress listener via BiocentralServerTask.run(onProgress: ...)
          _last = current;
        }
      }
    }
  }
}

class _ProjectionDTOHandler extends DtoHandler<Map<String, dynamic>> {
  @override
  Map<String, dynamic>? handle(List<TaskDTO> dtos) {
    for (final dto in dtos) {
      if (dto.status == TaskStatus.FINISHED) {
        return dto.projectionResult?.toMap();
      }
    }
    return null;
  }
}

class EmbeddingClient {
  /// Start an embedding task. The returned task resolves to a base64-encoded
  /// HDF5 file string (same content as Python client receives), or null on failure/timeout.
  Future<BiocentralServerTask<String>> embed({
    required gen.BiocentralApi api,
    required String embedderName,
    required Map<String, String> sequenceData,
    bool reduce = true,
    bool useHalfPrecision = false,
  }) async {
    final embeddingsApi = api.getEmbeddingsApi();
    final req = EmbedRequest((b) =>
    b
      ..embedderName = embedderName
      ..reduce = reduce
      ..sequenceData.replace(BuiltMap<String, String>(sequenceData))
      ..useHalfPrecision = useHalfPrecision);

    final taskId = await submitTask(() =>
        embeddingsApi.embedApiV1EmbeddingsServiceEmbedPost(embedRequest: req));
    final handler = _EmbedDtoHandler();
    return BiocentralServerTask<String>(taskId: taskId, api: api, dtoHandler: handler);
  }

  Future<Map<String, dynamic>?> projectionConfig({
    required gen.BiocentralApi api,
}) async {
    final projectionsApi = api.getProjectionsApi();

    final resp = await projectionsApi.projectionConfigApiV1ProjectionServiceProjectionConfigGet();
    final projectionConfigResponse = resp.data!;
    return projectionConfigResponse.projectionConfig.toMap();
  }

  Future<BiocentralServerTask<Map<String, dynamic>?>> project({
    required gen.BiocentralApi api,
    required String embedderName,
    required String method,
    required Map<String, String> sequenceData,
    required Map<String, dynamic> config,
  }) async {
    final projectionsApi = api.getProjectionsApi();
    final req = ProjectionRequest((b) =>
    b
      ..embedderName = embedderName
      ..method = method
      ..sequenceData.replace(BuiltMap<String, String>(sequenceData))
      ..config.replace(config.map((k, v) => MapEntry(k, JsonObject(v))))
    );
    final taskId = await submitTask(() =>
        projectionsApi.projectApiV1ProjectionServiceProjectPost(projectionRequest: req));
    final handler = _ProjectionDTOHandler();
    return BiocentralServerTask<Map<String, dynamic>>(taskId: taskId, api: api, dtoHandler: handler);
  }
}
