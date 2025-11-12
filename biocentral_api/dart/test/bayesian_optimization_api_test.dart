import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';


/// tests for BayesianOptimizationApi
void main() {
  final instance = BiocentralApi().getBayesianOptimizationApi();

  group(BayesianOptimizationApi, () {
    // Start Bayesian optimization training
    //
    // Submit a Bayesian optimization job with specified configuration and training data
    //
    //Future<StartTaskResponse> trainAndInferenceApiV1BayesianOptimizationServiceTrainingPost(BayesianOptimizationRequest bayesianOptimizationRequest) async
    test('test trainAndInferenceApiV1BayesianOptimizationServiceTrainingPost', () async {
      // TODO
    });

  });
}
