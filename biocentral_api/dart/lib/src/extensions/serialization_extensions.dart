import 'package:biocentral_api/src/serializers.dart';
import 'package:built_collection/built_collection.dart';

import '../model/active_learning_campaign_config.dart';
import '../model/active_learning_iteration_config.dart';
import '../model/active_learning_iteration_result.dart';
import '../model/active_learning_model_type.dart';
import '../model/active_learning_optimization_mode.dart';
import '../model/active_learning_result.dart';
import '../model/sequence_data.dart';
import '../model/biotrainer_model_result.dart';
import '../model/training_result.dart';
import '../model/test_result.dart';
import '../model/derived_values.dart';
import '../model/biotrainer_prediction.dart';
import '../model/bootstrapped_metric.dart';
import '../model/biotrainer_inference_result.dart';
import '../model/epoch_metrics.dart';
import '../model/embedding_stats.dart';

extension SequenceDataSerial on SequenceData {
  // TODO Optimize to take up less space when saving
  Map<String, dynamic> serialize() {
    return {
      'seq_id': seqId,
      'seq': seq,
      'set': set_,
      'label': label,
      'mask': mask,
      'embedding': embedding,
    };
  }

  static SequenceData deserialize(Map<String, dynamic> jsonMap) {
    return SequenceData((b) => b
      ..seqId = jsonMap['seq_id'] as String
      ..seq = jsonMap['seq'] as String
      ..set_ = jsonMap['set'] as String
      ..label = jsonMap['label'] as String?
      ..mask = jsonMap['mask'] as String?
      ..embedding = jsonMap['embedding']);
  }
}

extension BiotrainerModelResultSerial on BiotrainerModelResult {
  Map<String, dynamic> serialize() {
    return standardSerializers.serializeWith(BiotrainerModelResult.serializer, this) as Map<String, dynamic>;
  }

  static BiotrainerModelResult? deserialize(Map<String, dynamic> jsonMap) {
    return standardSerializers.deserializeWith(BiotrainerModelResult.serializer, jsonMap);
  }
}

extension TrainingResultSerial on TrainingResult {
  Map<String, dynamic> serialize() {
    return standardSerializers.serializeWith(TrainingResult.serializer, this) as Map<String, dynamic>;
  }

  static TrainingResult deserialize(Map<String, dynamic> jsonMap) {
    return standardSerializers.deserializeWith(TrainingResult.serializer, jsonMap)!;
  }
}

extension TestResultSerial on TestResult {
  Map<String, dynamic> serialize() {
    return standardSerializers.serializeWith(TestResult.serializer, this) as Map<String, dynamic>;
  }

  static TestResult deserialize(Map<String, dynamic> jsonMap) {
    return standardSerializers.deserializeWith(TestResult.serializer, jsonMap)!;
  }
}

extension DerivedValuesSerial on DerivedValues {
  Map<String, dynamic> serialize() {
    return standardSerializers.serializeWith(DerivedValues.serializer, this) as Map<String, dynamic>;
  }

  static DerivedValues deserialize(Map<String, dynamic> jsonMap) {
    return standardSerializers.deserializeWith(DerivedValues.serializer, jsonMap)!;
  }
}

extension BiotrainerPredictionSerial on BiotrainerPrediction {
  Map<String, dynamic> serialize() {
    return standardSerializers.serializeWith(BiotrainerPrediction.serializer, this) as Map<String, dynamic>;
  }

  static BiotrainerPrediction deserialize(Map<String, dynamic> jsonMap) {
    return standardSerializers.deserializeWith(BiotrainerPrediction.serializer, jsonMap)!;
  }
}

extension BootstrappedMetricSerial on BootstrappedMetric {
  Map<String, dynamic> serialize() {
    return standardSerializers.serializeWith(BootstrappedMetric.serializer, this) as Map<String, dynamic>;
  }

  static BootstrappedMetric deserialize(Map<String, dynamic> jsonMap) {
    return standardSerializers.deserializeWith(BootstrappedMetric.serializer, jsonMap)!;
  }
}

extension BiotrainerInferenceResultSerial on BiotrainerInferenceResult {
  Map<String, dynamic> serialize() {
    return standardSerializers.serializeWith(BiotrainerInferenceResult.serializer, this) as Map<String, dynamic>;
  }

  static BiotrainerInferenceResult deserialize(Map<String, dynamic> jsonMap) {
    return standardSerializers.deserializeWith(BiotrainerInferenceResult.serializer, jsonMap)!;
  }
}

extension EpochMetricsSerial on EpochMetrics {
  Map<String, dynamic> serialize() {
    return standardSerializers.serializeWith(EpochMetrics.serializer, this) as Map<String, dynamic>;
  }

  static EpochMetrics deserialize(Map<String, dynamic> jsonMap) {
    return standardSerializers.deserializeWith(EpochMetrics.serializer, jsonMap)!;
  }
}

extension EmbeddingStatsSerial on EmbeddingStats {
  Map<String, dynamic> serialize() {
    return standardSerializers.serializeWith(EmbeddingStats.serializer, this) as Map<String, dynamic>;
  }

  static EmbeddingStats deserialize(Map<String, dynamic> jsonMap) {
    return standardSerializers.deserializeWith(EmbeddingStats.serializer, jsonMap)!;
  }
}

extension ALCampaignConfigSerial on ActiveLearningCampaignConfig {
  Map<String, dynamic> serialize() {
    return {
      'name': name,
      'embedderName': embedderName,
      'modelType': modelType.name,
      'optimizationMode': optimizationMode.name,
      'seed': seed,
      'targetLb': targetLb,
      'targetUb': targetUb,
      'targetValue': targetValue,
      'discreteTargets': discreteTargets?.toList(),
    };
  }

  static ActiveLearningCampaignConfig deserialize(Map<String, dynamic> jsonMap) {
    return ActiveLearningCampaignConfig((b) => b
      ..name = jsonMap['name'] as String
      ..embedderName = jsonMap['embedderName'] as String
      ..modelType = ActiveLearningModelType.valueOf(jsonMap['modelType'] as String)
      ..optimizationMode = ActiveLearningOptimizationMode.valueOf(jsonMap['optimizationMode'] as String)
      ..seed = jsonMap['seed'] as int?
      ..targetLb = jsonMap['targetLb'] as num?
      ..targetUb = jsonMap['targetUb'] as num?
      ..targetValue = jsonMap['targetValue'] as num?
      ..discreteTargets = jsonMap['discreteTargets'] != null
          ? ListBuilder<String>(List<String>.from(jsonMap['discreteTargets'] as List))
          : null);
  }
}

extension ALIterationConfigSerial on ActiveLearningIterationConfig {
  Map<String, dynamic> serialize() {
    return {
      'iteration': iteration,
      'iteration_data': iterationData.map((data) => data.serialize()).toList(),
      'coefficient': coefficient,
      'n_suggestions': nSuggestions,
    };
  }

  static ActiveLearningIterationConfig deserialize(Map<String, dynamic> jsonMap) {
    return ActiveLearningIterationConfig((b) => b
      ..iteration = jsonMap['iteration'] as int
      ..iterationData = ListBuilder<SequenceData>((jsonMap['iteration_data'] as List)
          .map((e) => SequenceDataSerial.deserialize(e as Map<String, dynamic>)))
      ..coefficient = jsonMap['coefficient'] as num
      ..nSuggestions = jsonMap['n_suggestions'] as int);
  }
}

extension ALResultSerial on ActiveLearningResult {
  Map<String, dynamic> serialize() {
    return {
      'entity_id': entityId,
      'prediction': prediction,
      'uncertainty': uncertainty,
      'score': score,
    };
  }

  static ActiveLearningResult deserialize(Map<String, dynamic> jsonMap) {
    return ActiveLearningResult(
          (b) => b
        ..entityId = jsonMap['entity_id'] as String
        ..prediction = jsonMap['prediction'] as String
        ..uncertainty = jsonMap['uncertainty'] as num
        ..score = jsonMap['score'] as num,
    );
  }
}

extension ALIterationResultSerial on ActiveLearningIterationResult {
  Map<String, dynamic> serialize() {
    return {
      'iteration': iteration,
      'results': results.map((result) => result.serialize()).toList(),
      'suggestions': suggestions.toList(),
    };
  }

  static ActiveLearningIterationResult deserialize(Map<String, dynamic> jsonMap) {
    return ActiveLearningIterationResult((b) => b
      ..iteration = jsonMap['iteration'] as int
      ..results = ListBuilder<ActiveLearningResult>(
          (jsonMap['results'] as List).map((e) => ALResultSerial.deserialize(e as Map<String, dynamic>)))
      ..suggestions = ListBuilder<String>(List<String>.from(jsonMap['suggestions'] as List)));
  }
}