import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_config.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_model_types.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_task.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BayOptTrainingDialogEvent {}

class DatasetTypeSelected extends BayOptTrainingDialogEvent {
  final String datasetType;

  DatasetTypeSelected(this.datasetType);
}

class TaskSelected extends BayOptTrainingDialogEvent {
  final BayOptTaskType task;

  TaskSelected(this.task);
}

class EmbedderSelected extends BayOptTrainingDialogEvent {
  final PredefinedEmbedder embedder;

  EmbedderSelected(this.embedder);
}

class FeatureSelected extends BayOptTrainingDialogEvent {
  final String feature;

  FeatureSelected(this.feature);
}

class ModelSelected extends BayOptTrainingDialogEvent {
  final BayOptModelTypes model;

  ModelSelected(this.model);
}

class ExploitationExplorationUpdated extends BayOptTrainingDialogEvent {
  final double value;

  ExploitationExplorationUpdated(this.value);
}

class OptimizationTypeSelected extends BayOptTrainingDialogEvent {
  final String type; // 'Maximize', 'Minimize', 'Target Value', 'Target Range'
  OptimizationTypeSelected(this.type);
}

class TargetValueUpdated extends BayOptTrainingDialogEvent {
  final double value;

  TargetValueUpdated(this.value);
}

class TargetRangeMinUpdated extends BayOptTrainingDialogEvent {
  final double min;

  TargetRangeMinUpdated(this.min);
}

class TargetRangeMaxUpdated extends BayOptTrainingDialogEvent {
  final double max;

  TargetRangeMaxUpdated(this.max);
}

class DesiredBooleanValueUpdated extends BayOptTrainingDialogEvent {
  final bool value;

  DesiredBooleanValueUpdated(this.value);
}

@immutable
final class BayOptConfigDialogState extends Equatable {
  final List<String> availableFeatures;
  final BayOptConfig config;

  BayOptConfigDialogState.initial()
      : availableFeatures = const [],
        config = BayOptConfig.empty();

  const BayOptConfigDialogState.updateConfig({
    required this.availableFeatures,
    required this.config,
  });

  @override
  List<Object?> get props => [availableFeatures, config];
}

class BayOptConfigDialogBloc extends Bloc<BayOptTrainingDialogEvent, BayOptConfigDialogState> {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralProjectRepository biocentralProjectRepository;

  BayOptConfigDialogBloc(this._biocentralDatabaseRepository,
      this.biocentralProjectRepository, {
        BayOptConfig? initialConfig,
      }) : super(BayOptConfigDialogState.initial()) {
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

void _onDatasetSelected(DatasetTypeSelected event, Emitter<BayOptConfigDialogState> emit) {
  final availableFeatures = <String>[];
  if (event.datasetType.toString() == 'Protein') {
    final ProteinRepository? biocentralDatabase =
    _biocentralDatabaseRepository.getFromType(Protein) as ProteinRepository?;
    availableFeatures.addAll(biocentralDatabase?.getPartiallyUnlabeledColumnNames() ?? []);
  }

  emit(
    BayOptConfigDialogState.updateConfig(
      availableFeatures: availableFeatures,
      config: state.config.copyWith(
        selectedDatasetType: event.datasetType,
      ),
    ),
  );
}

void _onTaskSelected(TaskSelected event, Emitter<BayOptConfigDialogState> emit) {
  final ProteinRepository? biocentralDatabase =
  _biocentralDatabaseRepository.getFromType(Protein) as ProteinRepository?;

  List<String> filteredFeatures = [];

  switch (event.task) {
    case BayOptTaskType.findHighestProbability:
      filteredFeatures = biocentralDatabase!.getPartiallyUnlabeledColumnNames(binaryTypes: true, numericTypes: false);
      break;
    case BayOptTaskType.findOptimalValues:
      filteredFeatures = biocentralDatabase!.getPartiallyUnlabeledColumnNames(binaryTypes: false, numericTypes: true);
      break;
  }

  final config = state.config.copyWith(selectedTask: event.task);
  emit(
    BayOptConfigDialogState.updateConfig(
      availableFeatures: filteredFeatures,
      config: config,
    ),
  );
}

void _onFeatureSelected(FeatureSelected event, Emitter<BayOptConfigDialogState> emit) {
  emit(
    BayOptConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: state.config.copyWith(selectedFeature: event.feature),
    ),
  );
}

void _onOptimizationTypeSelected(OptimizationTypeSelected event,
    Emitter<BayOptConfigDialogState> emit,) {
  final config = state.config.copyWith(optimizationType: event.type);
  emit(
    BayOptConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: config,
    ),
  );
}

void _onTargetValueUpdated(TargetValueUpdated event, Emitter<BayOptConfigDialogState> emit) {
  final config = state.config.copyWith(targetValue: event.value);
  emit(
    BayOptConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: config,
    ),
  );
}

void _onTargetRangeMinUpdated(TargetRangeMinUpdated event, Emitter<BayOptConfigDialogState> emit) {
  final config = state.config.copyWith(targetRangeMin: event.min);
  emit(
    BayOptConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: config,
    ),
  );
}

void _onTargetRangeMaxUpdated(TargetRangeMaxUpdated event, Emitter<BayOptConfigDialogState> emit) {
  final config = state.config.copyWith(targetRangeMax: event.max);
  emit(
    BayOptConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: config,
    ),
  );
}

void _onDesiredBooleanValueUpdated(DesiredBooleanValueUpdated event,
    Emitter<BayOptConfigDialogState> emit,) {
  final config = state.config.copyWith(desiredBooleanValue: event.value);
  emit(
    BayOptConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: config,
    ),
  );
}

void _onEmbedderSelected(EmbedderSelected event, Emitter<BayOptConfigDialogState> emit) {
  emit(
    BayOptConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: state.config.copyWith(selectedEmbedder: event.embedder),
    ),
  );
}

void _onModelSelected(ModelSelected event, Emitter<BayOptConfigDialogState> emit) {
  emit(
    BayOptConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: state.config.copyWith(selectedModel: event.model),
    ),
  );
}

void _onExploitationExplorationUpdated(ExploitationExplorationUpdated event,
    Emitter<BayOptConfigDialogState> emit,) {
  emit(
    BayOptConfigDialogState.updateConfig(
      availableFeatures: state.availableFeatures,
      config: state.config.copyWith(exploitationExplorationValue: event.value),
    ),
  );
}}
