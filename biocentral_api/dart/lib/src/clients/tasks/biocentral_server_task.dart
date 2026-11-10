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
      final TaskStatusResponse statusResp;
      try {
        statusResp = await _fetchStatus(biocentralApi);
      } on DioException {
        // A transport failure does not establish that the server task failed.
        await Future.delayed(pollInterval);
        continue;
      }

      final dtos = statusResp.dtos.toList(growable: false);
      if (onProgress != null) onProgress(dtos);
      dtoHandler.updateProgress(dtos);
      for (final dto in dtos) {
        yield (dto, null);
      }
      for (final dto in dtos) {
        if (dto.status == TaskStatus.FAILED) {
          yield* Stream<(TaskDTO?, T?)>.error(
            BiocentralTaskFailure(taskId: taskId, message: dto.error ?? 'Task failed.', status: dto.status),
          );
          return;
        }
      }
      final result = dtoHandler.handle(dtos);
      if (result != null) {
        yield (null, result);
        return;
      }
      await Future.delayed(pollInterval);
    }
    yield* Stream<(TaskDTO?, T?)>.error(BiocentralTaskFailure(taskId: taskId, message: 'Task polling timed out.'));
  }
}

/// A terminal server-task failure, including the original server message.
final class BiocentralTaskFailure implements Exception {
  final String taskId;
  final String message;
  final TaskStatus? status;

  const BiocentralTaskFailure({required this.taskId, required this.message, this.status});

  @override
  String toString() => 'Task $taskId: $message';
}
