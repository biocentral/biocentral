import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/model/task_dto.dart';
import 'package:biocentral_api/src/model/task_status.dart';
import 'package:biocentral_api/src/model/prediction.dart';

import 'tasks/biocentral_server_task.dart';
import 'tasks/dto_handler.dart';


class ActiveLearningClient {

  /// Start a prediction task using provided model names and sequences.
  Future<BiocentralServerTask<dynamic>> activeLearningIteration({
    required gen.BiocentralApi api,
    required List<String> modelNames,
    required Map<String, String> sequenceData,
  }) async {
    final alApi = api.getActiveLearningApi();
    throw UnimplementedError();
  }
}
