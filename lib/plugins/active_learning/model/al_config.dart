import 'package:biocentral/plugins/active_learning/model/al_model_types.dart';
import 'package:biocentral/plugins/active_learning/model/al_task.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';

class ALConfig {
  final String? selectedDatasetType;
  final ALTaskType? selectedTask;
  final String? selectedFeature;
  final PredefinedEmbedder? selectedEmbedder;
  final ALModelType? selectedModel;
  final double? exploitationExplorationValue;
  final String? optimizationType;
  final double? targetValue;
  final double? targetRangeMin;
  final double? targetRangeMax;
  final bool? desiredBooleanValue;

  ALConfig({
    this.selectedDatasetType,
    this.selectedTask,
    this.selectedFeature,
    this.selectedEmbedder,
    this.selectedModel,
    this.exploitationExplorationValue = 0.5,
    this.optimizationType,
    this.targetValue,
    this.targetRangeMin,
    this.targetRangeMax,
    this.desiredBooleanValue,
  });

  factory ALConfig.empty() => ALConfig();

  ALConfig copyWith({
    String? selectedDatasetType,
    ALTaskType? selectedTask,
    String? selectedFeature,
    PredefinedEmbedder? selectedEmbedder,
    ALModelType? selectedModel,
    double? exploitationExplorationValue,
    List<String>? availableFeatures,
    List<ALTaskType>? tasks,
    List<PredefinedEmbedder>? availableEmbedders,
    String? optimizationType,
    double? targetValue,
    double? targetRangeMin,
    double? targetRangeMax,
    bool? desiredBooleanValue,
  }) {
    // Reset feature-related fields when task changes
    if (selectedTask != null && selectedTask != this.selectedTask) {
      return ALConfig(
        selectedDatasetType: selectedDatasetType ?? this.selectedDatasetType,
        selectedTask: selectedTask,
      );
    }

    return ALConfig(
      selectedDatasetType: selectedDatasetType ?? this.selectedDatasetType,
      selectedTask: selectedTask ?? this.selectedTask,
      selectedFeature: selectedFeature ?? this.selectedFeature,
      selectedEmbedder: selectedEmbedder ?? this.selectedEmbedder,
      selectedModel: selectedModel ?? this.selectedModel,
      exploitationExplorationValue: exploitationExplorationValue ?? this.exploitationExplorationValue,
      optimizationType: optimizationType ?? this.optimizationType,
      targetValue: targetValue ?? this.targetValue,
      targetRangeMin: targetRangeMin ?? this.targetRangeMin,
      targetRangeMax: targetRangeMax ?? this.targetRangeMax,
      desiredBooleanValue: desiredBooleanValue ?? this.desiredBooleanValue,
    );
  }

  bool get isFeatureConfigurationComplete {
    if (selectedTask == ALTaskType.findOptimalValues) {
      switch (optimizationType) {
        case 'Maximize':
          return true;
        case 'Minimize':
          return true;
        case 'Target Value':
          return targetValue != null;
        case 'Target Range':
          return targetRangeMin != null && targetRangeMax != null;
        default:
          return false;
      }
    } else if (selectedTask == ALTaskType.findHighestProbability) {
      return desiredBooleanValue != null;
    }
    return false;
  }

  bool get isTargetRangeValid =>
      optimizationType != 'Target Range' ||
      (targetRangeMin != null && targetRangeMax != null && targetRangeMin! < targetRangeMax!);

  bool get canStartTraining =>
      selectedTask != null &&
      selectedFeature != null &&
      selectedModel != null &&
      selectedEmbedder != null &&
      isFeatureConfigurationComplete &&
      isTargetRangeValid;

  Map<String, dynamic> toMap() {
    return {
      'selectedDataset': selectedDatasetType?.toString(),
      'selectedTask': selectedTask?.name,
      'feature_name': selectedFeature,
      'embedder_name': selectedEmbedder?.name,
      'model_type': selectedModel?.name,
      'coefficient': exploitationExplorationValue,
      'optimization_mode': optimizationType,
      'targetValue': targetValue,
      'targetRangeMin': targetRangeMin,
      'targetRangeMax': targetRangeMax,
      'desiredBooleanValue': desiredBooleanValue,
    };
  }

  factory ALConfig.fromMap(Map<String, dynamic> map) {
    return ALConfig(
      selectedDatasetType: map['selectedDatasetType'],
      selectedTask: map['selectedTask'] != null
          ? ALTaskType.values.firstWhere(
            (e) => e.name == map['selectedTask'],
        orElse: () => ALTaskType.values.first,
      )
          : null,
      selectedFeature: map['feature_name'],
      selectedEmbedder: map['embedder_name'] != null
          ? PredefinedEmbedderContainer.predefinedEmbedders().firstWhere(
            (e) => e.name == map['embedder_name'],
        orElse: () => PredefinedEmbedderContainer.predefinedEmbedders().first,
      )
          : null,
      selectedModel: map['model_type'] != null
          ? ALModelType.values.firstWhere(
            (e) => e.name == map['model_type'],
        orElse: () => ALModelType.values.first,
      )
          : null,
      exploitationExplorationValue: double.tryParse(map['coefficient'].toString()),
      optimizationType: map['optimization_mode'],
      targetValue: double.tryParse(map['targetValue'].toString()),
      targetRangeMin: double.tryParse(map['targetRangeMin'].toString()),
      targetRangeMax: double.tryParse(map['targetRangeMax'].toString()),
      desiredBooleanValue: map['desiredBooleanValue'],
    );
  }

}
