import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';


/// tests for ProjectionsApi
void main() {
  final instance = BiocentralApi().getProjectionsApi();

  group(ProjectionsApi, () {
    // Calculate projections
    //
    // Calculate projections for embeddings using Protspace
    //
    //Future<StartTaskResponse> projectApiV1ProjectionServiceProjectPost(ProjectionRequest projectionRequest) async
    test('test projectApiV1ProjectionServiceProjectPost', () async {
      // TODO
    });

    // Get Protspace config options
    //
    // Get Protspace project configs by projection method
    //
    //Future<GetProjectionConfigResponse> projectionConfigApiV1ProjectionServiceProjectionConfigGet() async
    test('test projectionConfigApiV1ProjectionServiceProjectionConfigGet', () async {
      // TODO
    });

  });
}
