import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/plm_eval/model/leaderboard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_dto.dart';
import 'package:fpdart/fpdart.dart';

final class PLMEvalClientFactory extends BiocentralClientFactory<PLMEvalClient> {
  @override
  PLMEvalClient create(BiocentralServerData? server) {
    return PLMEvalClient(server);
  }
}

class PLMEvalClient extends BiocentralClient {
  PLMEvalClient(super.server);

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

  Future<Either<BiocentralException, AutoEvalProgress>> _getAutoEvalStatus(String taskID) async {
    final responseEither = await doGetRequest('${PLMEvalServiceEndpoints.taskStatus}/$taskID');
    return responseEither.flatMap((responseMap) => AutoEvalProgress.fromDTO(BiocentralDTO(responseMap)));
  }

  Stream<AutoEvalProgress> autoEvalStatusStream(String taskID, AutoEvalProgress initialProgress) async* {
    const int maxRequests = 720; // TODO Listening for only 60 Minutes
    bool finished = false;
    AutoEvalProgress currentProgress = initialProgress;
    for (int i = 0; i < maxRequests; i++) {
      if (finished) {
        break;
      }
      await Future.delayed(const Duration(seconds: 5));
      final autoEvalProgressEither = await _getAutoEvalStatus(taskID);
      final newProgress = autoEvalProgressEither.getOrElse((l) => AutoEvalProgress.failed());
      currentProgress = currentProgress.update(newProgress);
      if (currentProgress.status == AutoEvalStatus.failed) {
        finished = true;
        continue;
      }
      if (currentProgress.status == AutoEvalStatus.finished) {
        finished = true;
      }
      yield currentProgress;
    }
  }

  Future<Either<BiocentralException, Leaderboard>> downloadLeaderboardData() async {
    final leaderboardStringEither =
        await doSimpleFileDownload('https://biocentral.cloud/downloads/biocentral/plm_leaderboard/leaderboard-v1.csv');
    return leaderboardStringEither.flatMap((leaderboardString) => right(Leaderboard.fromCsvString(leaderboardString)));
  }

  @override
  String getServiceName() {
    return 'plm_eval_service';
  }
}
