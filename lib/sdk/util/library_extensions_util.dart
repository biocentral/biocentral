import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/util/type_util.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:built_collection/src/list.dart';

extension CommonEmbedderDisplay on CommonEmbedder {
  String displayName() {
    final wN = wireName;
    final n = name.capitalize();
    if (wN.contains('/')) {
      return '$n ($wN)';
    }
    return n.toLowerCase();
  }
}

extension DisplayName on EmbeddingType {
  String displayName() {
    switch (this) {
      case EmbeddingType.perSequence:
        return 'Per Sequence';
      case EmbeddingType.perResidue:
        return 'Per Residue';
    }
  }
}

extension TrainingType on Protocol {
  String trainingType() {
    if (name.toLowerCase().contains('value')) {
      return 'Regression';
    }
    return 'Classification';
  }
}

extension SequenceTrainingDataSerial on SequenceTrainingData {
  // TODO Optimize to take up less space when saving
  Map<String, dynamic> serialize() {
    return {
      'seq_id': seqId,
      'sequence': sequence,
      'set': set_,
      'label': label,
      'mask': mask,
    };
  }

  static SequenceTrainingData deserialize(Map<String, dynamic> jsonMap) {
    return SequenceTrainingData((b) => b
      ..seqId = jsonMap['seq_id'] as String
      ..sequence = jsonMap['sequence'] as String
      ..set_ = jsonMap['set'] as String
      ..label = jsonMap['label'] as String?
      ..mask = jsonMap['mask'] as String?);
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
      ..iterationData = ListBuilder<SequenceTrainingData>((jsonMap['iteration_data'] as List)
          .map((e) => SequenceTrainingDataSerial.deserialize(e as Map<String, dynamic>)))
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
