import 'package:biocentral/sdk/data/biocentral_task_dto.dart';

extension PredictionModelsDTO on BiocentralDTO {
  String? get logFile => get<String>('log_file');

  Map<String, dynamic>? get config => get<Map<String, dynamic>>('config');

  Map<String, dynamic>? get derivedValues => get<Map<String, dynamic>>('derived_values');

  String? get databaseType => get<String>('database_type');

  Map<String, dynamic>? get trainingIteration => get<Map<String, dynamic>>('training_iteration');

  Map<String, dynamic>? get testResults => get<Map<String, dynamic>>('test_results');

  Map<String, dynamic>? get predictions => get<Map<String, dynamic>>('predictions');
}
