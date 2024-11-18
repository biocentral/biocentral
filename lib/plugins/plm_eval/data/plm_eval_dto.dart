import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_dto.dart';

import 'plm_eval_service_api.dart';

extension PlmEvalDTO on BiocentralDTO {
  int? get completedTasks {
    return int.tryParse(get<int>('completed_tasks').toString());
  }

  int? get totalTasks {
    return int.tryParse(get<int>('total_tasks').toString());
  }

  AutoEvalStatus? get autoEvalStatus {
    return enumFromString(get<String>('status') ?? '', AutoEvalStatus.values);
  }

  String? get currentProcess => get<String>('current_process');

  Map<String, dynamic>? get _results => get<Map<String, dynamic>>('results');

  String _getLogFile(dynamic map) {
    return map is Map ? map['log_file'] ?? '' : '';
  }

  Map<String, dynamic> _getConfigMap(dynamic map) {
    return map is Map ? map['config'] ?? {} : {};
  }

  Map<BenchmarkDataset, PredictionModel?> parseResults() {
    final String? embedderName = this.embedderName;
    final Map<String, dynamic> resultMap = _results ?? {};
    final Map<BenchmarkDataset, PredictionModel?> autoEvalResults = {};
    for (MapEntry<String, dynamic> entry in resultMap.entries) {
      final benchmarkDataset = BenchmarkDataset.fromServerString(entry.key);
      final String resultLog = _getLogFile(entry.value);
      final Map<String, dynamic> configMap = _getConfigMap(entry.value)..addAll({'embedderName': embedderName});
      if (benchmarkDataset != null && resultLog.isNotEmpty) {
        final predictionModel =
            BiotrainerFileHandler.predictionModelFromBiotrainerLog(configMap, resultLog);
        autoEvalResults[benchmarkDataset] = predictionModel;
      }
    }
    return autoEvalResults;
  }
}
