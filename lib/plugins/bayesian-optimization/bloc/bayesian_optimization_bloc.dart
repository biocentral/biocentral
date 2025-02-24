import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bayesian-optimization/bloc/bayesian_optimization_commands.dart';
import 'package:biocentral/plugins/bayesian-optimization/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BayesianOptimizationEvent {}

class BayesianOptimizationInitial extends BayesianOptimizationEvent {
  //TODO: List<BayesianOptimizationTrainingResult> previousTrainings;
}

class BayesianOptimizationLoaded extends BayesianOptimizationEvent {
  BayesianOptimizationTrainingResult? currentResult;
}

class BayesianOptimizationTrainingStarted extends BayesianOptimizationEvent {
  final BuildContext context;
  final String? selectedTask;
  final String? selectedFeature;
  final String? selectedModel;
  final double exploitationExplorationValue;
  final PredefinedEmbedder? selectedEmbedder;
  final String? optimizationType;
  final double? targetValue;
  final double? targetRangeMin;
  final double? targetRangeMax;
  final bool? desiredBooleanValue;

  BayesianOptimizationTrainingStarted(
    this.context,
    this.selectedTask,
    this.selectedFeature,
    this.selectedModel,
    this.exploitationExplorationValue,
    this.selectedEmbedder, {
    this.optimizationType,
    this.targetValue,
    this.targetRangeMin,
    this.targetRangeMax,
    this.desiredBooleanValue,
  });
}

@immutable
final class BayesianOptimizationState
    extends BiocentralCommandState<BayesianOptimizationState> {
  const BayesianOptimizationState(super.stateInformation, super.status);

  const BayesianOptimizationState.idle() : super.idle();

  @override
  BayesianOptimizationState newState(
    BiocentralCommandStateInformation stateInformation,
    BiocentralCommandStatus status,
  ) {
    return BayesianOptimizationState(stateInformation, status);
  }

  @override
  List<Object?> get props => [stateInformation, status];
}

class BayesianOptimizationBloc
    extends BiocentralBloc<BayesianOptimizationEvent, BayesianOptimizationState>
    with BiocentralSyncBloc, Effects<ReOpenColumnWizardEffect> {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralClientRepository _bioCentralClientRepository;

  BayesianOptimizationBloc(
    this._biocentralProjectRepository,
    this._bioCentralClientRepository,
    EventBus eventBus,
    this._biocentralDatabaseRepository,
  ) : super(const BayesianOptimizationState.idle(), eventBus) {
    on<BayesianOptimizationTrainingStarted>(_onTrainingStarted);
  }

  void _onTrainingStarted(
    BayesianOptimizationTrainingStarted event,
    Emitter<BayesianOptimizationState> emit,
  ) async {
    final BiocentralDatabase? biocentralDatabase =
        _biocentralDatabaseRepository.getFromType(Protein);
    if (biocentralDatabase == null) {
      emit(
        state.setErrored(
          information:
              'Could not find the database for which to calculate embeddings!',
        ),
      );
    } else {
      final config = {
        'databaseHash': biocentralDatabase.getHash().toString(),
        'task': event.selectedTask.toString(),
        'feature': event.selectedFeature.toString(),
        'model': event.selectedModel.toString(),
        'exploitationExplorationValue':
            event.exploitationExplorationValue.toString(),
        'selectedEmbedder': event.selectedEmbedder?.name,
        'optimizationType': event.optimizationType,
        if (event.targetValue != null)
          'targetValue': event.targetValue.toString(),
        if (event.targetRangeMin != null)
          'targetRangeMin': event.targetRangeMin.toString(),
        if (event.targetRangeMax != null)
          'targetRangeMax': event.targetRangeMax.toString(),
        if (event.desiredBooleanValue != null)
          'desiredBooleanValue': event.desiredBooleanValue.toString(),
      };

      final command = TransferBOTrainingConfigCommand(
        biocentralProjectRepository: _biocentralProjectRepository,
        biocentralDatabase: biocentralDatabase,
        client: _bioCentralClientRepository
            .getServiceClient<BayesianOptimizationClient>(),
        trainingConfiguration: config,
      );

      // await command
      //     .executeWithLogging<BayesianOptimizationState>(
      //   _biocentralProjectRepository,
      //   const BayesianOptimizationState(
      //       const BiocentralCommandStateInformation(information: ''),
      //       BiocentralCommandStatus.operating),
      // )
      //     .forEach(
      //   (either) {
      //     either.match((l) => emit(l), (r) => ());
      //   },
      // );
    }
  }
}
