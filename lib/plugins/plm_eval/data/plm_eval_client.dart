import 'dart:convert';

import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
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

  Future<Either<BiocentralException, String>> startAutoEval(String modelID, bool recommendedOnly) async {
    final Map<String, String> body = {'modelID': modelID, 'recommended_only': recommendedOnly.toString()};
    final responseEither = await doPostRequest(PLMEvalServiceEndpoints.autoeval, body);
    return responseEither.flatMap((map) {
      final taskID = map['task_id'];
      if (taskID == null || taskID.toString().isEmpty) {
        return left(BiocentralParsingException(message: 'Could not find task_id in response to autoeval task!'));
      }
      return right(taskID);
    });
  }

  Stream<AutoEvalProgress?> autoEvalProgressStream(String taskID, AutoEvalProgress initialProgress) async* {
    AutoEvalProgress? updateFunction(AutoEvalProgress? currentProgress, BiocentralDTO biocentralDTO) =>
        currentProgress?.updateFromDTO(biocentralDTO);
    yield* taskUpdateStream<AutoEvalProgress?>(taskID, initialProgress, updateFunction);
  }

  Future<Either<BiocentralException, PLMLeaderboard>> downloadPLMLeaderboardData() async {
    // TODO [Refactoring] Where to put the hubServerEndpoints?
    final leaderboardMapEither = await hubServerClient.doGetRequest('/plm_leaderboard/');
    return leaderboardMapEither.flatMap((leaderboardMap) => PLMLeaderboard.fromDTO(BiocentralDTO(leaderboardMap)));
  }

  Future<Either<BiocentralException, PLMLeaderboard>> publishResults(List publishingResults) async {
    final Map<String, String> body = {'results': jsonEncode(publishingResults)};
    
    final leaderboardMapEither = await hubServerClient.doPostRequest('/plm_leaderboard_publish/', body);
    return leaderboardMapEither.flatMap((leaderboardMap) => PLMLeaderboard.fromDTO(BiocentralDTO(leaderboardMap)));
  }

  @override
  String getServiceName() {
    return 'plm_eval_service';
  }
}
