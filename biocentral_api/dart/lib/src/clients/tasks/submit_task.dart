import 'dart:async';

import 'package:dio/dio.dart';

import '../../model/start_task_response.dart' as gen;


/// Submits a task-starting API call with retry-on-rate-limit behavior.
///
/// Mirrors the Python client's retry logic:
/// - Retries up to [maxRetries] times when receiving HTTP 429 and a Retry-After header.
/// - Waits (retry-after + 1) seconds before each retry.
/// - Throws if no task id is returned or if retry conditions are not met.
Future<String> submitTask(Future<Response<gen.StartTaskResponse>> Function() endpointCaller,
    {int maxRetries = 2}) async {
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      final resp = await endpointCaller();
      final startTask = resp.data;
      final taskId = startTask?.taskId;
      if (taskId == null) {
        throw Exception('No task id returned from server!');
      }
      return taskId;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Headers are case-insensitive; use helper to extract value
      final retryAfterHeader = e.response?.headers.value('retry-after') ??
          e.response?.headers.value('Retry-After');
      if (status != 429 || retryAfterHeader == null) {
        rethrow;
      }
      // parse wait seconds
      int waitSeconds = 0;
      try {
        waitSeconds = int.parse(retryAfterHeader);
      } catch (_) {
        // If header is not numeric, do not retry
        rethrow;
      }
      await Future.delayed(Duration(seconds: waitSeconds + 1));
      // loop continues to retry
    } catch (e) {
      rethrow;
    }
  }
  throw Exception('Max retries ($maxRetries) exceeded - Failed to start task!');
}
