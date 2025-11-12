import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';


/// tests for CustomModelsApi
void main() {
  final instance = BiocentralApi().getCustomModelsApi();

  group(CustomModelsApi, () {
    // Get configuration options for a protocol
    //
    // Retrieve available configuration options for a specific biotrainer protocol
    //
    //Future<ConfigOptionsResponse> configOptionsApiV1CustomModelsServiceConfigOptionsProtocolGet(String protocol) async
    test('test configOptionsApiV1CustomModelsServiceConfigOptionsProtocolGet', () async {
      // TODO
    });

    // Retrieve model files
    //
    // Get trained model files after training completion
    //
    //Future<BuiltMap<String, JsonObject>> modelFilesApiV1CustomModelsServiceModelFilesPost(ModelFilesRequest modelFilesRequest) async
    test('test modelFilesApiV1CustomModelsServiceModelFilesPost', () async {
      // TODO
    });

    // Get available protocols
    //
    // Retrieve list of all available biotrainer protocols
    //
    //Future<ProtocolsResponse> protocolsApiV1CustomModelsServiceProtocolsGet() async
    test('test protocolsApiV1CustomModelsServiceProtocolsGet', () async {
      // TODO
    });

    // Start model inference
    //
    // Submit sequences for prediction using a trained model
    //
    //Future<StartTaskResponse> startInferenceApiV1CustomModelsServiceStartInferencePost(StartInferenceRequest startInferenceRequest) async
    test('test startInferenceApiV1CustomModelsServiceStartInferencePost', () async {
      // TODO
    });

    // Start model training
    //
    // Submit a new model training job with specified configuration and training data
    //
    //Future<StartTaskResponse> startTrainingApiV1CustomModelsServiceStartTrainingPost(StartTrainingRequest startTrainingRequest) async
    test('test startTrainingApiV1CustomModelsServiceStartTrainingPost', () async {
      // TODO
    });

    // Verify configuration
    //
    // Validate a biotrainer configuration dict
    //
    //Future<ConfigVerificationResponse> verifyConfigApiV1CustomModelsServiceVerifyConfigPost(ConfigVerificationRequest configVerificationRequest) async
    test('test verifyConfigApiV1CustomModelsServiceVerifyConfigPost', () async {
      // TODO
    });

  });
}
