import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';


/// tests for PlmEvalApi
void main() {
  final instance = BiocentralApi().getPlmEvalApi();

  group(PlmEvalApi, () {
    // Automated Protein Language Model Evaluation
    //
    // Automated protein language model evaluation on pre-defined, curated datasets and tasks
    //
    //Future<StartTaskResponse> autoevalApiV1PlmEvalServiceAutoevalPost(PLMEvalAutoevalRequest pLMEvalAutoevalRequest) async
    test('test autoevalApiV1PlmEvalServiceAutoevalPost', () async {
      // TODO
    });

    // Get PLM eval information
    //
    // Get information about PLM eval datasets and process
    //
    //Future<PLMEvalInformationResponse> plmEvalInformationApiV1PlmEvalServicePlmEvalInformationGet() async
    test('test plmEvalInformationApiV1PlmEvalServicePlmEvalInformationGet', () async {
      // TODO
    });

    // Validate model ID
    //
    // Validate if the given model id exists on huggingface and can be used for plm_eval
    //
    //Future<PLMEvalValidateResponse> validateApiV1PlmEvalServiceValidateModelIdPost(PLMEvalValidateRequest pLMEvalValidateRequest) async
    test('test validateApiV1PlmEvalServiceValidateModelIdPost', () async {
      // TODO
    });

  });
}
