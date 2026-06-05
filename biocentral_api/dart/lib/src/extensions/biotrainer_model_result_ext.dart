
import '../model/biotrainer_model_result.dart';
import '../model/training_result.dart';

extension BiotrainerModelResultExt on BiotrainerModelResult {
  Map<String, dynamic>? configMap() {
    return this.config?.toMap().map((k, v) => MapEntry(k, v as dynamic));
  }
}

extension TrainingResultExt on TrainingResult {
  int getLastEpoch() {
    return this.trainingLosses?.length ?? 0;
  }
}