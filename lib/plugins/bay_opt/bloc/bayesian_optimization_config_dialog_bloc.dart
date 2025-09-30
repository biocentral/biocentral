import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_config.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_model_types.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_task.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BOTrainingDialogEvent {}

class DatasetTypeSelected extends BOTrainingDialogEvent {
  final String datasetType;

  DatasetTypeSelected(this.datasetType);
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

@immutable
final class BayesianOptimizationConfigDialogState extends Equatable {
  final BayesianOptimizationConfigDialogStep currentStep;
  final List<String> availableFeatures;
  final BayesianOptimizationConfig config;

  BayesianOptimizationConfigDialogState.initial()
      : currentStep = BayesianOptimizationConfigDialogStep.datasetSelection,
        availableFeatures = const [],
        config = BayesianOptimizationConfig.empty();

  const BayesianOptimizationConfigDialogState.updateConfig({
    required this.availableFeatures,
    required this.config,
    required this.currentStep,
  });

  @override
  List<Object?> get props => [currentStep, availableFeatures, config];
}

enum BayesianOptimizationConfigDialogStep {
  datasetSelection,
  taskSelection,
  featureSelection,
  featureConfiguration,
  embedderSelection,
  modelSelection,
  exploitationExplorationSelection,
  complete
}

class BayesianOptimizationConfigDialogBloc extends Bloc<BOTrainingDialogEvent, BayesianOptimizationConfigDialogState> {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralProjectRepository biocentralProjectRepository;

  BayesianOptimizationConfigDialogBloc(this._biocentralDatabaseRepository,
      this.biocentralProjectRepository, {
        BayesianOptimizationConfig? initialConfig,
      }) : super(BayesianOptimizationConfigDialogState.initial()) {
    on<DatasetTypeSelected>(_onDatasetSelected);
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

void _onDatasetSelected(DatasetTypeSelected event, Emitter<BayesianOptimizationConfigDialogState> emit) {
  final availableFeatures = <String>[];
  if (event.datasetType.toString() == 'Protein') {
    final ProteinRepository? biocentralDatabase =
    _biocentralDatabaseRepository.getFromType(Protein) as ProteinRepository?;
    availableFeatures.addAll(biocentralDatabase?.getPartiallyUnlabeledColumnNames() ?? []);
  }

  emit(
    BayesianOptimizationConfigDialogState.updateConfig(
      availableFeatures: availableFeatures,
      config: state.config.copyWith(
        selectedDatasetType: event.datasetType,
      ),
      currentStep: BayesianOptimizationConfigDialogStep.taskSelection,
    ),
  );
}

void _onTaskSelected(TaskSelected event, Emitter<BayesianOptimizationConfigDialogState> emit) {
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

  final config = state.config.copyWith(selectedTask: event.task);
  emit(
    BayesianOptimizationConfigDialogState.updateConfig(
      availableFeatures: filteredFeatures,
      config: config,
      currentStep: BayesianOptimizationConfigDialogStep.featureSelection,
    ),
  );
}

void _onFeatureSelected(FeatureSelected event, Emitter<BayesianOptimizationConfigDialogState> emit) {
  emit(
    BayesianOptimizationConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: state.config.copyWith(selectedFeature: event.feature),
      currentStep: BayesianOptimizationConfigDialogStep.featureConfiguration,
    ),
  );
}

void _onOptimizationTypeSelected(OptimizationTypeSelected event,
    Emitter<BayesianOptimizationConfigDialogState> emit,) {
  final config = state.config.copyWith(optimizationType: event.type);
  emit(
    BayesianOptimizationConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: config,
      currentStep: config.isFeatureConfigurationComplete
          ? BayesianOptimizationConfigDialogStep.embedderSelection
          : BayesianOptimizationConfigDialogStep.featureConfiguration,
    ),
  );
}

void _onTargetValueUpdated(TargetValueUpdated event, Emitter<BayesianOptimizationConfigDialogState> emit) {
  final config = state.config.copyWith(targetValue: event.value);
  emit(
    BayesianOptimizationConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: config,
      currentStep: config.isFeatureConfigurationComplete
          ? BayesianOptimizationConfigDialogStep.embedderSelection
          : BayesianOptimizationConfigDialogStep.featureConfiguration,
    ),
  );
}

void _onTargetRangeMinUpdated(TargetRangeMinUpdated event, Emitter<BayesianOptimizationConfigDialogState> emit) {
  final config = state.config.copyWith(targetRangeMin: event.min);
  emit(
    BayesianOptimizationConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: config,
      currentStep: config.isFeatureConfigurationComplete
          ? BayesianOptimizationConfigDialogStep.embedderSelection
          : BayesianOptimizationConfigDialogStep.featureConfiguration,
    ),
  );
}

void _onTargetRangeMaxUpdated(TargetRangeMaxUpdated event, Emitter<BayesianOptimizationConfigDialogState> emit) {
  final config = state.config.copyWith(targetRangeMax: event.max);
  emit(
    BayesianOptimizationConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: config,
      currentStep: config.isFeatureConfigurationComplete
          ? BayesianOptimizationConfigDialogStep.embedderSelection
          : BayesianOptimizationConfigDialogStep.featureConfiguration,
    ),
  );
}

void _onDesiredBooleanValueUpdated(DesiredBooleanValueUpdated event,
    Emitter<BayesianOptimizationConfigDialogState> emit,) {
  final config = state.config.copyWith(desiredBooleanValue: event.value);
  emit(
    BayesianOptimizationConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: config,
      currentStep: config.isFeatureConfigurationComplete
          ? BayesianOptimizationConfigDialogStep.embedderSelection
          : BayesianOptimizationConfigDialogStep.featureConfiguration,
    ),
  );
}

void _onEmbedderSelected(EmbedderSelected event, Emitter<BayesianOptimizationConfigDialogState> emit) {
  emit(
    BayesianOptimizationConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: state.config.copyWith(selectedEmbedder: event.embedder),
      currentStep: BayesianOptimizationConfigDialogStep.modelSelection,
    ),
  );
}

void _onModelSelected(ModelSelected event, Emitter<BayesianOptimizationConfigDialogState> emit) {
  emit(
    BayesianOptimizationConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: state.config.copyWith(selectedModel: event.model),
      currentStep: BayesianOptimizationConfigDialogStep.exploitationExplorationSelection,
    ),
  );
}

void _onExploitationExplorationUpdated(ExploitationExplorationUpdated event,
    Emitter<BayesianOptimizationConfigDialogState> emit,) {
  emit(
    BayesianOptimizationConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: state.config.copyWith(exploitationExplorationValue: event.value),
      currentStep: BayesianOptimizationConfigDialogStep.complete,
    ),
  );
}}
