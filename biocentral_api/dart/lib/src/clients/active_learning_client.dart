import 'package:biocentral_api/src/api.dart' as gen;

import 'tasks/biocentral_server_task.dart';

class ActiveLearningClient {
  /// Start a prediction task using provided model names and sequences.
  Future<BiocentralServerTask<dynamic>> activeLearningIteration({
    required gen.BiocentralApi api,
    required List<String> modelNames,
    required Map<String, String> sequenceData,
  }) async {
    // TODO
    final alApi = api.getActiveLearningApi();
    throw UnimplementedError();
  }
}
