import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

import 'plm_eval_api.dart';


final class PLMEvalClientFactory extends BiocentralClientFactory<PLMEvalClient> {
  @override
  PLMEvalClient create(BiocentralServerData? server) {
    return PLMEvalClient(server);
  }
}

class PLMEvalClient extends BiocentralClient {
  PLMEvalClient(super.server);

  Future<Either<BiocentralException, Unit>> validateModelID(String modelID) async {
    Map<String, String> body = {"modelID": modelID};
    final responseEither = await doPostRequest(PLMEvalServiceEndpoints.validateModelID, body);
    return responseEither.flatMap((_) => right(unit));
  }

  @override
  String getServiceName() {
    return "plm_eval_service";
  }
}
