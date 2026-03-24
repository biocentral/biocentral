import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/model/al_config.dart';
import 'package:biocentral/plugins/active_learning/model/al_task.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ALTrainingDialogEvent {}

class ALTrainingDialogDatasetTypeSelectedEvent extends ALTrainingDialogEvent {
  final String datasetType;

  ALTrainingDialogDatasetTypeSelectedEvent(this.datasetType);
}

class ALTrainingDialogTaskSelectedEvent extends ALTrainingDialogEvent {
  final ALTaskType task;

  ALTrainingDialogTaskSelectedEvent(this.task);
}

class ALTrainingDialogConfigUpdatedEvent extends ALTrainingDialogEvent {
  final ALConfig config;

  ALTrainingDialogConfigUpdatedEvent(this.config);
}

@immutable
final class ALConfigDialogState extends Equatable {
  final List<String> availableFeatures;
  final ALConfig config;

  ALConfigDialogState.initial()
      : availableFeatures = const [],
        config = ALConfig.empty();

  const ALConfigDialogState.updateConfig({
    required this.availableFeatures,
    required this.config,
  });

  @override
  List<Object?> get props => [availableFeatures, config];
}

class ALConfigDialogBloc extends Bloc<ALTrainingDialogEvent, ALConfigDialogState> {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralProjectRepository biocentralProjectRepository;

  ALConfigDialogBloc(
    this._biocentralDatabaseRepository,
    this.biocentralProjectRepository, {
    ALConfig? initialConfig,
  }) : super(ALConfigDialogState.initial()) {
    on<ALTrainingDialogDatasetTypeSelectedEvent>(_onDatasetSelected);
    on<ALTrainingDialogTaskSelectedEvent>(_onTaskSelected);

    on<ALTrainingDialogConfigUpdatedEvent>(_onConfigUpdated);
  }

  void _onDatasetSelected(ALTrainingDialogDatasetTypeSelectedEvent event, Emitter<ALConfigDialogState> emit) {
    final availableFeatures = <String>[];
    if (event.datasetType.toString() == 'Protein') {
      final ProteinRepository? biocentralDatabase =
          _biocentralDatabaseRepository.getFromType(Protein) as ProteinRepository?;
      availableFeatures.addAll(biocentralDatabase?.getPartiallyUnlabeledColumnNames() ?? []);
    }

    emit(
      ALConfigDialogState.updateConfig(
        availableFeatures: availableFeatures,
        config: state.config.copyWith(
          selectedDatasetType: event.datasetType,
        ),
      ),
    );
  }

  void _onTaskSelected(ALTrainingDialogTaskSelectedEvent event, Emitter<ALConfigDialogState> emit) {
    final ProteinRepository? biocentralDatabase =
        _biocentralDatabaseRepository.getFromType(Protein) as ProteinRepository?;

    List<String> filteredFeatures = [];

    switch (event.task) {
      case ALTaskType.findHighestProbability:
        filteredFeatures = biocentralDatabase!.getPartiallyUnlabeledColumnNames(binaryTypes: true, numericTypes: false);
        break;
      case ALTaskType.findOptimalValues:
        filteredFeatures = biocentralDatabase!.getPartiallyUnlabeledColumnNames(binaryTypes: false, numericTypes: true);
        break;
    }

    final config = state.config.copyWith(selectedTask: event.task);
    emit(
      ALConfigDialogState.updateConfig(
        availableFeatures: filteredFeatures,
        config: config,
      ),
    );
  }

  void _onConfigUpdated(ALTrainingDialogConfigUpdatedEvent event, Emitter<ALConfigDialogState> emit) {
    emit(
      ALConfigDialogState.updateConfig(
        availableFeatures: state.availableFeatures,
        config: event.config,
      ),
    );
  }
}
