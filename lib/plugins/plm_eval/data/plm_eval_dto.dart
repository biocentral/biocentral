import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';

extension PlmEvalDTO on BiocentralDTO {
  String? get embedderName => get<String>('embedder_name');

  int? get completedTasks {
    return int.tryParse(get<int>('completed_tasks').toString());
  }

  int? get totalTasks {
    return int.tryParse(get<int>('total_tasks').toString());
  }

  String? get currentTask => get<String>('current_task');

  Map<String, dynamic>? get currentTaskConfig => get<Map<String, dynamic>>('current_task_config');

  BiocentralDTO get modelDTO => BiocentralDTO(get<Map>('current_task_dto') ?? {});

  PredictionModel parseCurrentTaskModel() {
    final predictionModel = PredictionModel.fromTrainingConfig(currentTaskConfig ?? {});
    return predictionModel.updateFromDTO(modelDTO);
  }
}
