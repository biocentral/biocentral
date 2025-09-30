import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_model_types.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_task.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';

enum BOConfigStep {
  datasetSelection,
  taskSelection,
  featureSelection,
  featureConfiguration,
  embedderSelection,
  modelSelection,
  exploitationExplorationSelection,
  complete
}

class BayesianOptimizationConfig {
  final String? selectedDatasetType;
  final TaskType? selectedTask;
  final String? selectedFeature;
  final PredefinedEmbedder? selectedEmbedder;
  final BayesianOptimizationModelTypes? selectedModel;
  final double? exploitationExplorationValue;
  final String? optimizationType;
  final double? targetValue;
  final double? targetRangeMin;
  final double? targetRangeMax;
  final bool? desiredBooleanValue;

  BayesianOptimizationConfig({
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

  factory BayesianOptimizationConfig.empty() => BayesianOptimizationConfig();

  BayesianOptimizationConfig copyWith({
    String? selectedDatasetType,
    TaskType? selectedTask,
    String? selectedFeature,
    PredefinedEmbedder? selectedEmbedder,
    BayesianOptimizationModelTypes? selectedModel,
    double? exploitationExplorationValue,
    List<String>? availableFeatures,
    List<TaskType>? tasks,
    List<PredefinedEmbedder>? availableEmbedders,
    String? optimizationType,
    double? targetValue,
    double? targetRangeMin,
    double? targetRangeMax,
    bool? desiredBooleanValue,
  }) {
    // Reset feature-related fields when task changes
    if (selectedTask != null && selectedTask != this.selectedTask) {
      return BayesianOptimizationConfig(
        selectedDatasetType: selectedDatasetType ?? this.selectedDatasetType,
        selectedTask: selectedTask,
      );
    }

    return BayesianOptimizationConfig(
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
    if (selectedTask == TaskType.findOptimalValues) {
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
    } else if (selectedTask == TaskType.findHighestProbability) {
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

  factory BayesianOptimizationConfig.fromMap(Map<String, dynamic> map) {
    return BayesianOptimizationConfig(
      selectedDatasetType: map['selectedDatasetType'],
      selectedTask: map['selectedTask'] != null
          ? TaskType.values.firstWhere(
            (e) => e.name == map['selectedTask'],
        orElse: () => TaskType.values.first,
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
          ? BayesianOptimizationModelTypes.values.firstWhere(
            (e) => e.name == map['model_type'],
        orElse: () => BayesianOptimizationModelTypes.values.first,
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
