import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';


/// tests for DefaultApi
void main() {
  final instance = BiocentralApi().getDefaultApi();

  group(DefaultApi, () {
    // Health Check
    //
    //Future<JsonObject> healthCheckHealthGet() async
    test('test healthCheckHealthGet', () async {
      // TODO
    });

    // Metrics
    //
    //Future<JsonObject> metricsMetricsGet() async
    test('test metricsMetricsGet', () async {
      // TODO
    });

  });
}
