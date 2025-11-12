import 'package:biocentral_api/src/model/bayesian_optimization_request.dart';
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/model/prediction_request.dart';
import 'package:biocentral_api/src/model/task_dto.dart';
import 'package:biocentral_api/src/model/task_status.dart';
import 'package:biocentral_api/src/model/prediction.dart';

import 'tasks/biocentral_server_task.dart';
import 'tasks/dto_handler.dart';

class _PredictDtoHandler extends DtoHandler<Map<String, List<Prediction>>> {
  @override
  Map<String, List<Prediction>>? handle(List<TaskDTO> dtos) {
    for (final dto in dtos) {
      if (dto.status == TaskStatus.FINISHED) {
        return dto.predictions?.toMap().map((k, v) => MapEntry(k, v.toList()));
      }
    }
    return null;
  }
}

class BayOptClient {

  /// Start a prediction task using provided model names and sequences.
  Future<BiocentralServerTask<dynamic>> activeLearningIteration({
    required gen.BiocentralApi api,
    required List<String> modelNames,
    required Map<String, String> sequenceData,
  }) async {
    final bayOptApi = api.getBayesianOptimizationApi();
    throw UnimplementedError();
  }
}
