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

class BayOptTrainingDialogDatasetTypeSelectedEvent extends BayOptTrainingDialogEvent {
  final String datasetType;

  BayOptTrainingDialogDatasetTypeSelectedEvent(this.datasetType);
}

class BayOptTrainingDialogTaskSelectedEvent extends BayOptTrainingDialogEvent {
  final BayOptTaskType task;

  BayOptTrainingDialogTaskSelectedEvent(this.task);
}

class BayOptTrainingDialogConfigUpdatedEvent extends BayOptTrainingDialogEvent {
  final BayOptConfig config;

  BayOptTrainingDialogConfigUpdatedEvent(this.config);
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

  BayOptConfigDialogBloc(
    this._biocentralDatabaseRepository,
    this.biocentralProjectRepository, {
    BayOptConfig? initialConfig,
  }) : super(BayOptConfigDialogState.initial()) {
    on<BayOptTrainingDialogDatasetTypeSelectedEvent>(_onDatasetSelected);
    on<BayOptTrainingDialogTaskSelectedEvent>(_onTaskSelected);

    on<BayOptTrainingDialogConfigUpdatedEvent>(_onConfigUpdated);
  }

  void _onDatasetSelected(BayOptTrainingDialogDatasetTypeSelectedEvent event, Emitter<BayOptConfigDialogState> emit) {
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

  void _onTaskSelected(BayOptTrainingDialogTaskSelectedEvent event, Emitter<BayOptConfigDialogState> emit) {
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

  void _onConfigUpdated(BayOptTrainingDialogConfigUpdatedEvent event, Emitter<BayOptConfigDialogState> emit) {
    emit(
      BayOptConfigDialogState.updateConfig(
        availableFeatures: state.availableFeatures,
        config: event.config,
      ),
    );
  }
}
