import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';


/// tests for BiocentralApi
void main() {
  final instance = BiocentralApi().getBiocentralApi();

  group(BiocentralApi, () {
    // Stats
    //
    //Future<JsonObject> statsApiV1BiocentralServiceStatsGet() async
    test('test statsApiV1BiocentralServiceStatsGet', () async {
      // TODO
    });

    // Task Status
    //
    //Future<TaskStatusResponse> taskStatusApiV1BiocentralServiceTaskStatusTaskIdGet(String taskId) async
    test('test taskStatusApiV1BiocentralServiceTaskStatusTaskIdGet', () async {
      // TODO
    });

    // Task Status Resumed
    //
    //Future<TaskStatusResponse> taskStatusResumedApiV1BiocentralServiceTaskStatusResumedTaskIdGet(String taskId) async
    test('test taskStatusResumedApiV1BiocentralServiceTaskStatusResumedTaskIdGet', () async {
      // TODO
    });

    // Welcome Message
    //
    //Future<JsonObject> welcomeMessageApiV1BiocentralServiceWelcomeMessageGet() async
    test('test welcomeMessageApiV1BiocentralServiceWelcomeMessageGet', () async {
      // TODO
    });

  });
}
