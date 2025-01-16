import 'package:bio_flutter/bio_flutter.dart';

import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';

class EmbeddingsRepository {
  final Map<Type, EmbeddingsColumnWizard> _embeddingsColumnWizards = {};

  // Embedder Name -> Map<ProjectionData, List>
  final Map<String, Map<ProjectionData, List<Map<String, String>>>> _projectionDataToPointData = {};

  EmbeddingsRepository();

  Map<ProjectionData, List<Map<String, String>>> updateProjectionData(
      String embedderName, ProjectionData projectionData, List<Map<String, String>> pointData,) {
    _projectionDataToPointData.putIfAbsent(embedderName, () => {});
    _projectionDataToPointData[embedderName]![projectionData] = pointData;
    return getProjectionDataMap(embedderName)!;
  }

  Map<ProjectionData, List<Map<String, String>>>? getProjectionDataMap(String embedderName) {
    return _projectionDataToPointData[embedderName];
  }

  Map<Type, EmbeddingsColumnWizard> updateEmbeddingsColumnWizardForType(
      Type type, EmbeddingsColumnWizard embeddingsColumnWizard,) {
    _embeddingsColumnWizards[type] = embeddingsColumnWizard;
    return Map.from(_embeddingsColumnWizards);
  }

  EmbeddingsColumnWizard? getEmbeddingsColumnWizardByType(Type? type) {
    return _embeddingsColumnWizards[type];
  }
}
