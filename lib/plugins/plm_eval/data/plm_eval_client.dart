import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

import 'package:biocentral/plugins/plm_eval/data/plm_eval_api.dart';

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

  Future<Either<BiocentralException, Map<String, List<String>>>> getAvailableBenchmarkDatasets() async {
    final responseEither = await doGetRequest(PLMEvalServiceEndpoints.getBenchmarkDatasets);
    return responseEither.flatMap((map) =>
        right(Map.fromEntries(map.entries.map((entry) => MapEntry(entry.key, List<String>.from(entry.value))))),);
  }

  Future<Either<BiocentralException, String>> startAutoEval(String modelID) async {
    final Map<String, String> body = {'modelID': modelID};
    final responseEither = await doPostRequest(PLMEvalServiceEndpoints.autoeval, body);
    return responseEither.flatMap((map) {
      final taskID = map['task_id'];
      if (taskID == null || taskID.toString().isEmpty) {
        return left(BiocentralParsingException(message: 'Could not find task_id in response to autoeval task!'));
      }
      return right(taskID);
    });
  }

  @override
  String getServiceName() {
    return 'plm_eval_service';
  }
}
