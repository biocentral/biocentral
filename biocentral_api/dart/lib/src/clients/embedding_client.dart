import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/api/embeddings_api.dart' as endpoints;
import 'package:biocentral_api/src/model/embed_request.dart';
import 'package:biocentral_api/src/model/start_task_response.dart';
import 'package:biocentral_api/src/model/task_dto.dart';
import 'package:biocentral_api/src/model/task_status.dart';

import 'tasks/biocentral_server_task.dart';
import 'tasks/dto_handler.dart';

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
        _total ??= dto.embeddingTotal;
        final current = dto.embeddingCurrent;
        if (current != null && _total != null) {
          // Placeholder hook: users can attach a progress listener via BiocentralServerTask.run(onProgress: ...)
          _last = current;
        }
      }
    }
  }
}

class _ProjectionDTOHandler extends DtoHandler<String> {
  @override
  String? handle(List<TaskDTO> dtos) {
    return null; // TODO
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
    final endpointsApi = api.getEmbeddingsApi();
    final req = EmbedRequest((b) => b
      ..embedderName = embedderName
      ..reduce = reduce
      ..sequenceData.replace(BuiltMap<String, String>(sequenceData))
      ..useHalfPrecision = useHalfPrecision);

    final startResp = await endpointsApi.embedApiV1EmbeddingsServiceEmbedPost(embedRequest: req);
    final taskId = startResp.data!.taskId;
    final handler = _EmbedDtoHandler();
    return BiocentralServerTask<String>(taskId: taskId, api: api, dtoHandler: handler);
  }

  // TODO Placeholder function
  Future<BiocentralServerTask<String>> project({
    required gen.BiocentralApi api,
    required String embedderName,
    required Map<String, String> sequenceData,
  }) async {
    final handler = _ProjectionDTOHandler();
    return BiocentralServerTask<String>(taskId: "", api: api, dtoHandler: handler);
  }
}
