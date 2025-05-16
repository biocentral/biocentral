import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_model_types.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';

// Define an enum for task types
enum TaskType {
  findOptimalValues,
  findHighestProbability,
}

// Extension to get display string for UI
extension TaskTypeExtension on TaskType {
  String get displayName {
    switch (this) {
      case TaskType.findOptimalValues:
        return 'Find proteins with optimal values for feature...';
      case TaskType.findHighestProbability:
        return 'Find proteins with the highest probability to have feature...';
    }
  }
}

abstract class BOTrainingDialogEvent {}

class DatasetSelected extends BOTrainingDialogEvent {
  final Type dataset;

  DatasetSelected(this.dataset);
}

class TaskSelected extends BOTrainingDialogEvent {
  final TaskType task;

  TaskSelected(this.task);
}

class EmbedderSelected extends BOTrainingDialogEvent {
  final PredefinedEmbedder embedder;

  EmbedderSelected(this.embedder);
}

class FeatureSelected extends BOTrainingDialogEvent {
  final String feature;

  FeatureSelected(this.feature);
}

class ModelSelected extends BOTrainingDialogEvent {
  final BayesianOptimizationModelTypes model;

  ModelSelected(this.model);
}

class ExploitationExplorationUpdated extends BOTrainingDialogEvent {
  final double value;

  ExploitationExplorationUpdated(this.value);
}

class OptimizationTypeSelected extends BOTrainingDialogEvent {
  final String type; // 'Maximize', 'Minimize', 'Target Value', 'Target Range'
  OptimizationTypeSelected(this.type);
}

class TargetValueUpdated extends BOTrainingDialogEvent {
  final double value;

  TargetValueUpdated(this.value);
}

class TargetRangeMinUpdated extends BOTrainingDialogEvent {
  final double min;

  TargetRangeMinUpdated(this.min);
}

class TargetRangeMaxUpdated extends BOTrainingDialogEvent {
  final double max;

  TargetRangeMaxUpdated(this.max);
}

class DesiredBooleanValueUpdated extends BOTrainingDialogEvent {
  final bool value;

  DesiredBooleanValueUpdated(this.value);
}

enum BOTrainingDialogStep {
  datasetSelection,
  taskSelection,
  featureSelection,
  featureConfiguration,
  embedderSelection,
  modelSelection,
  exploitationExplorationSelection,
  complete
}

class BOTrainingDialogState {
  final BOTrainingDialogStep currentStep;
  final Type? selectedDataset;
  final TaskType? selectedTask;
  final String? selectedFeature;
  final PredefinedEmbedder? selectedEmbedder;
  final BayesianOptimizationModelTypes? selectedModel;
  final double exploitationExplorationValue;
  final List<String> availableFeatures;
  final List<TaskType> tasks;
  final List<PredefinedEmbedder> availableEmbedders;
  final String? optimizationType;
  final double? targetValue;
  final double? targetRangeMin;
  final double? targetRangeMax;
  final bool? desiredBooleanValue;

  bool get isFeatureConfigurationComplete {
    if (selectedTask == TaskType.findOptimalValues) {
      switch (optimizationType) {
        case 'Maximize':
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

  BOTrainingDialogState({
    this.currentStep = BOTrainingDialogStep.datasetSelection,
    this.selectedDataset,
    this.selectedTask,
    this.selectedFeature,
    this.selectedEmbedder,
    this.selectedModel,
    this.exploitationExplorationValue = 0.5,
    this.availableFeatures = const [],
    this.tasks = const [
      TaskType.findOptimalValues,
      TaskType.findHighestProbability,
    ],
    this.availableEmbedders = const [],
    this.optimizationType,
    this.targetValue,
    this.targetRangeMin,
    this.targetRangeMax,
    this.desiredBooleanValue,
  });

  BOTrainingDialogState copyWith({
    BOTrainingDialogStep? currentStep,
    Type? selectedDataset,
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
      return BOTrainingDialogState(
        currentStep: currentStep ?? this.currentStep,
        selectedDataset: selectedDataset ?? this.selectedDataset,
        selectedTask: selectedTask,
        availableFeatures: availableFeatures ?? this.availableFeatures,
        tasks: tasks ?? this.tasks,
        availableEmbedders: availableEmbedders ?? this.availableEmbedders,
        exploitationExplorationValue: this.exploitationExplorationValue,
      );
    }

    return BOTrainingDialogState(
      currentStep: currentStep ?? this.currentStep,
      selectedDataset: selectedDataset ?? this.selectedDataset,
      selectedTask: selectedTask ?? this.selectedTask,
      selectedFeature: selectedFeature ?? this.selectedFeature,
      selectedEmbedder: selectedEmbedder ?? this.selectedEmbedder,
      selectedModel: selectedModel ?? this.selectedModel,
      exploitationExplorationValue: exploitationExplorationValue ?? this.exploitationExplorationValue,
      availableFeatures: availableFeatures ?? this.availableFeatures,
      tasks: tasks ?? this.tasks,
      availableEmbedders: availableEmbedders ?? this.availableEmbedders,
      optimizationType: optimizationType ?? this.optimizationType,
      targetValue: targetValue ?? this.targetValue,
      targetRangeMin: targetRangeMin ?? this.targetRangeMin,
      targetRangeMax: targetRangeMax ?? this.targetRangeMax,
      desiredBooleanValue: desiredBooleanValue ?? this.desiredBooleanValue,
    );
  }
}

class BOTrainingDialogBloc extends Bloc<BOTrainingDialogEvent, BOTrainingDialogState> {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralProjectRepository biocentralProjectRepository;

  BOTrainingDialogBloc(
    this._biocentralDatabaseRepository,
    this.biocentralProjectRepository, {
    TaskType? initialTask,
    String? initialFeature,
    BayesianOptimizationModelTypes? initialModel,
    double initialExploitationExploration = 0.5,
    PredefinedEmbedder? initialEmbedder,
    String? initialOptimizationType,
    double? initialTargetValue,
    double? initialTargetRangeMin,
    double? initialTargetRangeMax,
    bool? initialDesiredBooleanValue,
  }) : super(BOTrainingDialogState(
          availableEmbedders: PredefinedEmbedderContainer.predefinedEmbedders(),
          selectedDataset: Protein,
          selectedTask: initialTask,
          selectedFeature: initialFeature,
          selectedModel: initialModel,
          exploitationExplorationValue: initialExploitationExploration,
          selectedEmbedder: initialEmbedder,
          optimizationType: initialOptimizationType,
          targetValue: initialTargetValue,
          targetRangeMin: initialTargetRangeMin,
          targetRangeMax: initialTargetRangeMax,
          desiredBooleanValue: initialDesiredBooleanValue,
          currentStep: initialTask != null ? BOTrainingDialogStep.featureSelection : BOTrainingDialogStep.taskSelection,
        )) {
    on<DatasetSelected>(_onDatasetSelected);
    on<TaskSelected>(_onTaskSelected);
    on<FeatureSelected>(_onFeatureSelected);
    on<EmbedderSelected>(_onEmbedderSelected);
    on<ModelSelected>(_onModelSelected);
    on<ExploitationExplorationUpdated>(_onExploitationExplorationUpdated);
    on<OptimizationTypeSelected>(_onOptimizationTypeSelected);
    on<TargetValueUpdated>(_onTargetValueUpdated);
    on<TargetRangeMinUpdated>(_onTargetRangeMinUpdated);
    on<TargetRangeMaxUpdated>(_onTargetRangeMaxUpdated);
    on<DesiredBooleanValueUpdated>(_onDesiredBooleanValueUpdated);

    // If we have initial values, we should be at the feature configuration step
    if (initialTask != null && initialFeature != null) {
      add(TaskSelected(initialTask));
      add(FeatureSelected(initialFeature));
      if (initialEmbedder != null) {
        add(EmbedderSelected(initialEmbedder));
      }
      if (initialModel != null) {
        add(ModelSelected(initialModel));
      }
      if (initialOptimizationType != null) {
        add(OptimizationTypeSelected(initialOptimizationType));
      }
      if (initialTargetValue != null) {
        add(TargetValueUpdated(initialTargetValue));
      }
      if (initialTargetRangeMin != null) {
        add(TargetRangeMinUpdated(initialTargetRangeMin));
      }
      if (initialTargetRangeMax != null) {
        add(TargetRangeMaxUpdated(initialTargetRangeMax));
      }
      if (initialDesiredBooleanValue != null) {
        add(DesiredBooleanValueUpdated(initialDesiredBooleanValue));
      }
      add(ExploitationExplorationUpdated(initialExploitationExploration));
    }
  }

  void _onDatasetSelected(DatasetSelected event, Emitter<BOTrainingDialogState> emit) {
    var availableFeatures = [''];
    if (event.dataset.toString() == 'Protein') {
      final ProteinRepository? biocentralDatabase =
          _biocentralDatabaseRepository.getFromType(Protein) as ProteinRepository?;
      availableFeatures = biocentralDatabase!.getPartiallyUnlabeledColumnNames();
    }

    emit(state.copyWith(
      selectedDataset: event.dataset,
      currentStep: BOTrainingDialogStep.taskSelection,
      availableFeatures: availableFeatures,
    ));
  }

  void _onTaskSelected(TaskSelected event, Emitter<BOTrainingDialogState> emit) {
    final ProteinRepository? biocentralDatabase =
        _biocentralDatabaseRepository.getFromType(Protein) as ProteinRepository?;

    List<String> filteredFeatures = [];

    switch (event.task) {
      case TaskType.findHighestProbability:
        filteredFeatures = biocentralDatabase!.getPartiallyUnlabeledColumnNames(binaryTypes: true, numericTypes: false);
        break;
      case TaskType.findOptimalValues:
        filteredFeatures = biocentralDatabase!.getPartiallyUnlabeledColumnNames(binaryTypes: false, numericTypes: true);
        break;
    }

    emit(state.copyWith(
      selectedTask: event.task,
      currentStep: BOTrainingDialogStep.featureSelection,
      availableFeatures: filteredFeatures,
    ));
  }

  void _onFeatureSelected(FeatureSelected event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(
      selectedFeature: event.feature,
      currentStep: BOTrainingDialogStep.featureConfiguration,
    ));
  }

  void _updateFeatureConfigurationStep(Emitter<BOTrainingDialogState> emit) {
    if (state.isFeatureConfigurationComplete) {
      emit(state.copyWith(
        currentStep: BOTrainingDialogStep.embedderSelection,
      ));
    }
  }

  void _onOptimizationTypeSelected(OptimizationTypeSelected event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(
      optimizationType: event.type,
      targetValue: null,
      targetRangeMin: null,
      targetRangeMax: null,
    ));
    _updateFeatureConfigurationStep(emit);
  }

  void _onTargetValueUpdated(TargetValueUpdated event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(targetValue: event.value));
    _updateFeatureConfigurationStep(emit);
  }

  void _onTargetRangeMinUpdated(TargetRangeMinUpdated event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(targetRangeMin: event.min));
    _updateFeatureConfigurationStep(emit);
  }

  void _onTargetRangeMaxUpdated(TargetRangeMaxUpdated event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(targetRangeMax: event.max));
    _updateFeatureConfigurationStep(emit);
  }

  void _onDesiredBooleanValueUpdated(DesiredBooleanValueUpdated event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(desiredBooleanValue: event.value));
    _updateFeatureConfigurationStep(emit);
  }

  void _onEmbedderSelected(EmbedderSelected event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(
      selectedEmbedder: event.embedder,
      currentStep: BOTrainingDialogStep.modelSelection,
    ));
  }

  void _onModelSelected(ModelSelected event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(
      selectedModel: event.model,
      currentStep: BOTrainingDialogStep.exploitationExplorationSelection,
    ));
  }

  void _onExploitationExplorationUpdated(ExploitationExplorationUpdated event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(
      exploitationExplorationValue: event.value,
      currentStep: BOTrainingDialogStep.complete,
    ));
  }
}
