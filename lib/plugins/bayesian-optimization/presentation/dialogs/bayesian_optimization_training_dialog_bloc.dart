import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../embeddings/data/predefined_embedders.dart';

// Events
abstract class BOTrainingDialogEvent {}

class DatasetSelected extends BOTrainingDialogEvent {
  final Type dataset;

  DatasetSelected(this.dataset);
}

class TaskSelected extends BOTrainingDialogEvent {
  final String task;

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
  final String model;

  ModelSelected(this.model);
}

class ExploitationExplorationUpdated extends BOTrainingDialogEvent {
  final double value;

  ExploitationExplorationUpdated(this.value);
}

// Add to BOTrainingDialogEvent section:
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

// State
// First, let's fix the step enum to reflect the correct order
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

// Update the state class to better handle feature configuration
class BOTrainingDialogState {
  final BOTrainingDialogStep currentStep;
  final Type? selectedDataset;
  final String? selectedTask;
  final String? selectedFeature;
  final PredefinedEmbedder? selectedEmbedder;
  final String? selectedModel;
  final double exploitationExplorationValue;
  final List<String> availableFeatures;
  final List<String> tasks;
  final List<String> models;
  final List<PredefinedEmbedder> availableEmbedders;
  final String? optimizationType;
  final double? targetValue;
  final double? targetRangeMin;
  final double? targetRangeMax;
  final bool? desiredBooleanValue;

  bool get isFeatureConfigurationComplete {
    if (selectedTask?.contains('optimal values') ?? false) {
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
    } else if (selectedTask?.contains('highest probability') ?? false) {
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
      'Find proteins with optimal values for feature...',
      'Find proteins with the highest probability to have feature...',
    ],
    this.models = const ['Gaussian Processes', 'Random Forest'],
    this.availableEmbedders = const [],
    this.optimizationType,
    this.targetValue,
    this.targetRangeMin,
    this.targetRangeMax,
    this.desiredBooleanValue,
  });

  // Update copyWith to reset dependent fields when necessary
  BOTrainingDialogState copyWith({
    BOTrainingDialogStep? currentStep,
    Type? selectedDataset,
    String? selectedTask,
    String? selectedFeature,
    PredefinedEmbedder? selectedEmbedder,
    String? selectedModel,
    double? exploitationExplorationValue,
    List<String>? availableFeatures,
    List<String>? tasks,
    List<String>? models,
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
        models: models ?? this.models,
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
      exploitationExplorationValue:
          exploitationExplorationValue ?? this.exploitationExplorationValue,
      availableFeatures: availableFeatures ?? this.availableFeatures,
      tasks: tasks ?? this.tasks,
      models: models ?? this.models,
      availableEmbedders: availableEmbedders ?? this.availableEmbedders,
      optimizationType: optimizationType ?? this.optimizationType,
      targetValue: targetValue ?? this.targetValue,
      targetRangeMin: targetRangeMin ?? this.targetRangeMin,
      targetRangeMax: targetRangeMax ?? this.targetRangeMax,
      desiredBooleanValue: desiredBooleanValue ?? this.desiredBooleanValue,
    );
  }
}

// Update the Bloc class to handle the new flow
class BOTrainingDialogBloc
    extends Bloc<BOTrainingDialogEvent, BOTrainingDialogState> {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralProjectRepository biocentralProjectRepository;

  BOTrainingDialogBloc(
    this._biocentralDatabaseRepository,
    this.biocentralProjectRepository,
  ) : super(BOTrainingDialogState(
          availableEmbedders: PredefinedEmbedderContainer.predefinedEmbedders(),
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
  }

  void _onDatasetSelected(
      DatasetSelected event, Emitter<BOTrainingDialogState> emit) {
    var availableFeatures = [''];
    if (event.dataset.toString() == 'Protein') {
      final ProteinRepository? biocentralDatabase =
          _biocentralDatabaseRepository.getFromType(Protein)
              as ProteinRepository?;
      availableFeatures = biocentralDatabase!.getTrainableColumnNames();
    }
    emit(state.copyWith(
      selectedDataset: event.dataset,
      currentStep: BOTrainingDialogStep.taskSelection,
      availableFeatures: availableFeatures,
    ));
  }

  void _onTaskSelected(
      TaskSelected event, Emitter<BOTrainingDialogState> emit) {
    final ProteinRepository? biocentralDatabase = _biocentralDatabaseRepository
        .getFromType(Protein) as ProteinRepository?;

    List<String> filteredFeatures = [];
    if (event.task.contains('highest probability')) {
      filteredFeatures =
          biocentralDatabase!.getTrainableColumnNames(true, false);
    } else if (event.task.contains('optimal values')) {
      filteredFeatures =
          biocentralDatabase!.getTrainableColumnNames(false, true);
    }

    emit(state.copyWith(
      selectedTask: event.task,
      currentStep: BOTrainingDialogStep.featureSelection,
      availableFeatures: filteredFeatures,
    ));
  }

  void _onFeatureSelected(
      FeatureSelected event, Emitter<BOTrainingDialogState> emit) {
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

  void _onOptimizationTypeSelected(
      OptimizationTypeSelected event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(
      optimizationType: event.type,
      targetValue: null,
      targetRangeMin: null,
      targetRangeMax: null,
    ));
    _updateFeatureConfigurationStep(emit);
  }

  void _onTargetValueUpdated(
      TargetValueUpdated event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(targetValue: event.value));
    _updateFeatureConfigurationStep(emit);
  }

  void _onTargetRangeMinUpdated(
      TargetRangeMinUpdated event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(targetRangeMin: event.min));
    _updateFeatureConfigurationStep(emit);
  }

  void _onTargetRangeMaxUpdated(
      TargetRangeMaxUpdated event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(targetRangeMax: event.max));
    _updateFeatureConfigurationStep(emit);
  }

  void _onDesiredBooleanValueUpdated(
      DesiredBooleanValueUpdated event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(desiredBooleanValue: event.value));
    _updateFeatureConfigurationStep(emit);
  }

  void _onEmbedderSelected(
      EmbedderSelected event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(
      selectedEmbedder: event.embedder,
      currentStep: BOTrainingDialogStep.modelSelection,
    ));
  }

  void _onModelSelected(
      ModelSelected event, Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(
      selectedModel: event.model,
      currentStep: BOTrainingDialogStep.exploitationExplorationSelection,
    ));
  }

  void _onExploitationExplorationUpdated(ExploitationExplorationUpdated event,
      Emitter<BOTrainingDialogState> emit) {
    emit(state.copyWith(
      exploitationExplorationValue: event.value,
      currentStep: BOTrainingDialogStep.complete,
    ));
  }
}
