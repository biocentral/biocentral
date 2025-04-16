import 'dart:convert';
import 'dart:typed_data';

import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_leaderboard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

final class PLMEvalClientFactory extends BiocentralClientFactory<PLMEvalClient> {
  @override
  PLMEvalClient create(BiocentralServerData? server, BiocentralHubServerClient hubServerClient) {
    return PLMEvalClient(server, hubServerClient);
  }
}

class PLMEvalClient extends BiocentralClient {
  const PLMEvalClient(super._server, super._hubServerClient);

  Future<Either<BiocentralException, Unit>> validateModelID(String modelID) async {
    final Map<String, String> body = {'modelID': modelID};
    final responseEither = await doPostRequest(PLMEvalServiceEndpoints.validateModelID, body);
    return responseEither.flatMap((_) => right(unit));
  }

  Future<Either<BiocentralException, List<BenchmarkDataset>>> getAvailableBenchmarkDatasets() async {
    final responseEither = await doGetRequest(PLMEvalServiceEndpoints.getBenchmarkDatasets);
    return responseEither.flatMap((map) => parseBenchmarkDatasetsFromMap(map));
  }

  Future<Either<BiocentralException, List<BenchmarkDataset>>> getRecommendedBenchmarkDatasets() async {
    final responseEither = await doGetRequest(PLMEvalServiceEndpoints.getRecommendedBenchmarkDatasets);
    return responseEither.flatMap((map) => parseBenchmarkDatasetsFromMap(map));
  }

  Future<Either<BiocentralException, String>> startAutoEval(
    String modelID,
    Uint8List? onnxBytes,
    Map<String, dynamic>? tokenizerConfig,
    bool recommendedOnly,
  ) async {
    final Map<String, String> body = {'modelID': modelID, 'recommended_only': recommendedOnly.toString()};
    if (onnxBytes != null) {
      body['onnxFile'] = base64Encode(onnxBytes);
      body['tokenizerConfig'] = jsonEncode(tokenizerConfig);
    }
    final responseEither = await doPostRequest(PLMEvalServiceEndpoints.autoeval, body);
    return responseEither.flatMap((map) {
      final taskID = map['task_id'];
      if (taskID == null || taskID.toString().isEmpty) {
        return left(BiocentralParsingException(message: 'Could not find task_id in response to autoeval task!'));
      }
      return right(taskID);
    });
  }

  Future<Either<BiocentralException, AutoEvalProgress>> resumeAutoEval(
    String taskID,
    AutoEvalProgress initialProgress,
  ) async {
    final responseEither = await resumeTask(taskID);
    return responseEither.flatMap((dtos) {
      AutoEvalProgress? currentProgress = initialProgress;
      for (final dto in dtos) {
        currentProgress = _updateFunction(currentProgress, dto);
      }
      if (currentProgress == null) {
        return left(BiocentralParsingException(message: 'Could not parse resumed eval progress from server dtos!'));
      }
      return right(currentProgress);
    });
  }

  AutoEvalProgress? _updateFunction(AutoEvalProgress? currentProgress, BiocentralDTO biocentralDTO) {
    return currentProgress?.updateFromDTO(biocentralDTO);
  }

  Stream<AutoEvalProgress?> autoEvalProgressStream(String taskID, AutoEvalProgress initialProgress) async* {
    yield* taskUpdateStream<AutoEvalProgress?>(taskID, initialProgress, _updateFunction);
  }

  Future<Either<BiocentralException, (PLMLeaderboard, Map<String, String>)>> downloadPLMLeaderboardData() async {
    final leaderboardMapEither = await hubServerClient.doGetRequest(BiocentralHubServerClient.leaderBoardEndpoint);
    return leaderboardMapEither.flatMap((leaderboardMap) => _parseLeaderboardFromResponse(leaderboardMap));
  }

  Future<Either<BiocentralException, (PLMLeaderboard, Map<String, String>)>> publishResult(
      PLMEvalPersistentResult result) async {
    final Map<String, String> body = {'result': jsonEncode(result.toMap())};

    final leaderboardMapEither =
        await hubServerClient.doPostRequest(BiocentralHubServerClient.publishLeaderboardEntryEndpoint, body);
    return leaderboardMapEither.flatMap((leaderboardMap) => _parseLeaderboardFromResponse(leaderboardMap));
  }

  Either<BiocentralException, (PLMLeaderboard, Map<String, String>)> _parseLeaderboardFromResponse(
      Map<dynamic, dynamic> leaderboardMap) {
    final leaderboardEntries = leaderboardMap['leaderboard'];
    final recommendedMetrics = convertToStringMap(leaderboardMap['recommended_metrics'] ?? {});
    if (leaderboardEntries == null || leaderboardEntries is! List) {
      return left(
        BiocentralParsingException(
          message: 'Could not parse leaderboard from server response - '
              'Expected a list but got type ${leaderboardEntries?.runtimeType}!',
        ),
      );
    }

    final List<PLMEvalPersistentResult> plmPersistentResults = [];
    for (final entryMap in leaderboardEntries) {
      final persistentResult = PLMEvalPersistentResult.fromMap(jsonDecode(entryMap));
      if (persistentResult == null) {
        return left(
          BiocentralParsingException(
            message: 'Could not parse leaderboard from server response '
                '- Could not parse any valid persistent results!',
          ),
        );
      }
      plmPersistentResults.add(persistentResult);
    }
    return right((PLMLeaderboard.fromPersistentResults(plmPersistentResults), recommendedMetrics));
  }

  @override
  String getServiceName() {
    return 'plm_eval_service';
  }
}
