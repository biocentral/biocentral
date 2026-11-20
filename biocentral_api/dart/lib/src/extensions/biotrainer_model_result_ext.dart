import 'dart:convert';

import '../model/biotrainer_model_result.dart';
import '../model/training_result.dart';

extension BiotrainerModelResultExt on BiotrainerModelResult {
  Map<String, dynamic>? configMap() {
    return this.config?.toMap().map((k, v) {
      return MapEntry(k, v.toString() as dynamic);
    });
  }
}

extension TrainingResultExt on TrainingResult {
  int getLastEpoch() {
    return this.trainingLosses?.length ?? 0;
  }
}
