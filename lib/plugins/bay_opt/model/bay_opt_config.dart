import 'package:biocentral/plugins/bay_opt/model/bay_opt_model_types.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_task.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';

class BayOptConfig {
  final String? selectedDatasetType;
  final BayOptTaskType? selectedTask;
  final String? selectedFeature;
  final PredefinedEmbedder? selectedEmbedder;
  final BayOptModelTypes? selectedModel;
  final double? exploitationExplorationValue;
  final String? optimizationType;
  final double? targetValue;
  final double? targetRangeMin;
  final double? targetRangeMax;
  final bool? desiredBooleanValue;

  BayOptConfig({
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

  factory BayOptConfig.empty() => BayOptConfig();

  BayOptConfig copyWith({
    String? selectedDatasetType,
    BayOptTaskType? selectedTask,
    String? selectedFeature,
    PredefinedEmbedder? selectedEmbedder,
    BayOptModelTypes? selectedModel,
    double? exploitationExplorationValue,
    List<String>? availableFeatures,
    List<BayOptTaskType>? tasks,
    List<PredefinedEmbedder>? availableEmbedders,
    String? optimizationType,
    double? targetValue,
    double? targetRangeMin,
    double? targetRangeMax,
    bool? desiredBooleanValue,
  }) {
    // Reset feature-related fields when task changes
    if (selectedTask != null && selectedTask != this.selectedTask) {
      return BayOptConfig(
        selectedDatasetType: selectedDatasetType ?? this.selectedDatasetType,
        selectedTask: selectedTask,
      );
    }

    return BayOptConfig(
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
    if (selectedTask == BayOptTaskType.findOptimalValues) {
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
    } else if (selectedTask == BayOptTaskType.findHighestProbability) {
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

  factory BayOptConfig.fromMap(Map<String, dynamic> map) {
    return BayOptConfig(
      selectedDatasetType: map['selectedDatasetType'],
      selectedTask: map['selectedTask'] != null
          ? BayOptTaskType.values.firstWhere(
            (e) => e.name == map['selectedTask'],
        orElse: () => BayOptTaskType.values.first,
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
          ? BayOptModelTypes.values.firstWhere(
            (e) => e.name == map['model_type'],
        orElse: () => BayOptModelTypes.values.first,
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
