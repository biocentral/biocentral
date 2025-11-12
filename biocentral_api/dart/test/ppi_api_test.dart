import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';


/// tests for PpiApi
void main() {
  final instance = BiocentralApi().getPpiApi();

  group(PpiApi, () {
    // Auto Detect Format By Header
    //
    //Future<DetectedFormatResponse> autoDetectFormatByHeaderApiV1PpiServiceAutoDetectFormatPost(AutoDetectFormatRequest autoDetectFormatRequest) async
    test('test autoDetectFormatByHeaderApiV1PpiServiceAutoDetectFormatPost', () async {
      // TODO
    });

    // Formats
    //
    //Future<JsonObject> formatsApiV1PpiServiceFormatsGet() async
    test('test formatsApiV1PpiServiceFormatsGet', () async {
      // TODO
    });

    // Import Dataset
    //
    //Future<ImportDatasetResponse> importDatasetApiV1PpiServiceImportPost(ImportDatasetRequest importDatasetRequest) async
    test('test importDatasetApiV1PpiServiceImportPost', () async {
      // TODO
    });

    // Run Test
    //
    //Future<RunTestResponse> runTestApiV1PpiServiceDatasetTestsRunTestPost(RunTestRequest runTestRequest) async
    test('test runTestApiV1PpiServiceDatasetTestsRunTestPost', () async {
      // TODO
    });

    // Tests
    //
    //Future<JsonObject> testsApiV1PpiServiceDatasetTestsTestsGet() async
    test('test testsApiV1PpiServiceDatasetTestsTestsGet', () async {
      // TODO
    });

  });
}
