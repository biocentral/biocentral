import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';


/// tests for PredictionApi
void main() {
  final instance = BiocentralApi().getPredictionApi();

  group(PredictionApi, () {
    // Get predict model metadata
    //
    // Get metadata for available prediction models
    //
    //Future<ModelMetadataResponse> modelMetadataApiV1PredictionServiceModelMetadataGet() async
    test('test modelMetadataApiV1PredictionServiceModelMetadataGet', () async {
      // TODO
    });

    // Submit protein sequence prediction job
    //
    // Submit sequences for prediction using specified models and receive a task ID for tracking
    //
    //Future<StartTaskResponse> predictApiV1PredictionServicePredictPost(PredictionRequest predictionRequest) async
    test('test predictApiV1PredictionServicePredictPost', () async {
      // TODO
    });

  });
}
