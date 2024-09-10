import 'package:bio_flutter/bio_flutter.dart';

import '../model/embeddings_column_wizard.dart';

class EmbeddingsRepository {
  final Map<Type, EmbeddingsColumnWizard> _embeddingsColumnWizards = {};

  // Embedder Name -> Map<UMAPData, List>
  final Map<String, Map<UMAPData, List<Map<String, String>>>> _umapDataToPointData = {};

  EmbeddingsRepository();

  Map<UMAPData, List<Map<String, String>>> updateUMAPData(
      String embedderName, UMAPData umapData, List<Map<String, String>> pointData) {
    _umapDataToPointData.putIfAbsent(embedderName, () => {});
    _umapDataToPointData[embedderName]![umapData] = pointData;
    return getUMAPDataMap(embedderName)!;
  }

  Map<UMAPData, List<Map<String, String>>>? getUMAPDataMap(String embedderName) {
    return _umapDataToPointData[embedderName];
  }

  Map<Type, EmbeddingsColumnWizard> updateEmbeddingsColumnWizardForType(
      Type type, EmbeddingsColumnWizard embeddingsColumnWizard) {
    _embeddingsColumnWizards[type] = embeddingsColumnWizard;
    return Map.from(_embeddingsColumnWizards);
  }

  EmbeddingsColumnWizard? getEmbeddingsColumnWizardByType(Type? type) {
    return _embeddingsColumnWizards[type];
  }
}
