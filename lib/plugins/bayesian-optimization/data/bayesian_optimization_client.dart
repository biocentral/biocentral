import 'package:biocentral/sdk/biocentral_sdk.dart';

final class BayesianOptimizationClientFactory extends BiocentralClientFactory<BayesianOptimizationClient> {
  @override
  BayesianOptimizationClient create(BiocentralServerData? server) {
    return BayesianOptimizationClient(server);
  }
}

class BayesianOptimizationClient extends BiocentralClient {
  BayesianOptimizationClient(super._server);

  @override
  String getServiceName() {
    return "bayesian_optimization_service";
  }
}
