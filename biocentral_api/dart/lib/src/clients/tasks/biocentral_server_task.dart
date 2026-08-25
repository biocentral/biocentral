import 'dart:async';

import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/api/biocentral_service_api.dart';
import 'package:biocentral_api/src/model/task_dto.dart';
import 'package:biocentral_api/src/model/task_status.dart';
import 'package:biocentral_api/src/model/task_status_response.dart';
import 'package:dio/dio.dart';

import 'dto_handler.dart';

class BiocentralServerTask<T> {
  static const Duration pollInterval = Duration(seconds: 2);
  static const int maxTries = 10000;

  final String taskId;
  final gen.BiocentralApi api; // generated API root for creating endpoint clients
  final DtoHandler<T> dtoHandler;

  BiocentralServerTask({
    required this.taskId,
    required this.api,
    required this.dtoHandler,
  });

  Future<TaskStatusResponse> _fetchStatus(BiocentralServiceApi biocentralServiceApi) async {
    final resp = await biocentralServiceApi.taskStatusApiV1BiocentralServiceTaskStatusTaskIdGet(taskId: taskId);
    return resp.data!;
  }

  /// Poll the server until the task finishes and return the parsed result.
  Stream<(TaskDTO?, T?)> run({void Function(List<TaskDTO> dtos)? onProgress}) async* {
    final biocentralApi = api.getBiocentralServiceApi();

    for (int i = 0; i < maxTries; i++) {
      try {
        final statusResp = await _fetchStatus(biocentralApi);
        final dtos = statusResp.dtos.toList(growable: false);

        // progress callback
        if (onProgress != null) onProgress(dtos);
        dtoHandler.updateProgress(dtos);

        // yield dtos
        for(final dto in dtos) {
          yield (dto, null);
        }

        // try to extract final result
        final result = dtoHandler.handle(dtos);
        if (result != null) {
          yield (null, result);
          return;
        }

        // also stop on explicit FAILED to avoid unnecessary waits
        if (dtos.any((d) => d.status == TaskStatus.FAILED)) {
          yield (null, null);
        }
      } catch (err) {
        // ignore transient errors and continue polling
        print(err);
        if(err is DioException) {
          print(err.response);
          final detail = err.response?.data["detail"];
          if (detail != null) {
            print(detail);
          }
        }
      }
      await Future.delayed(pollInterval);
    }
    yield (null, null); // timeout
  }
}
