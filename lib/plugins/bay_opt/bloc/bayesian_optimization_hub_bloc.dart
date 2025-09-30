import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bay_opt/domain/bayesian_optimization_repository.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_training_result.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:cross_file/cross_file.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BayesianOptimizationHubEvent {}

class BayesianOptimizationHubLoadEvent extends BayesianOptimizationHubEvent {}

class BayesianOptimizationHubSelectEvent extends BayesianOptimizationHubEvent {
  final int selectedIndex;

  BayesianOptimizationHubSelectEvent({required this.selectedIndex});
}

class BayesianOptimizationHubAddExperimentalDataEvent extends BayesianOptimizationHubEvent {
  final Map<String, dynamic> experimentalData;

  BayesianOptimizationHubAddExperimentalDataEvent({required this.experimentalData});
}

class BayesianOptimizationHubLoadTrainingsFromFileEvent extends BayesianOptimizationHubEvent {
  final XFile? xFile;

  BayesianOptimizationHubLoadTrainingsFromFileEvent({required this.xFile});
}

class BayesianOptimizationIterateTrainingEvent extends BayesianOptimizationHubEvent {
  final BuildContext context;
  final BayesianOptimizationTrainingResult trainingResult;
  final List<double?> updateList;

  /// Constructor for iterating Bayesian Optimization training.
  ///
  /// - [context]: The build context.
  /// - [trainingResult]: The training result to iterate from.
  /// - [updateList]: The list of values to update.
  BayesianOptimizationIterateTrainingEvent(this.context, this.trainingResult, this.updateList);
}

class BayesianOptimizationDirectIterateTrainingEvent extends BayesianOptimizationHubEvent {
  final BuildContext context;
  final BayesianOptimizationTrainingResult trainingResult;
  final List<double?> updateList;

  /// Constructor for iterating Bayesian Optimization training.
  ///
  /// - [context]: The build context.
  /// - [trainingResult]: The training result to iterate from.
  /// - [updateList]: The list of values to update.
  BayesianOptimizationDirectIterateTrainingEvent(this.context, this.trainingResult, this.updateList);
}

@immutable
final class BayesianOptimizationHubState extends BiocentralCommandState<BayesianOptimizationHubState> {
  final List<BayesianOptimizationTrainingResult> trainingResults;
  final int selectedResultIndex;

  const BayesianOptimizationHubState(
    super.stateInformation,
    super.status,
    this.trainingResults,
    this.selectedResultIndex,
  );

  const BayesianOptimizationHubState.idle()
      : trainingResults = const [],
        selectedResultIndex = 0,
        super.idle();

  BayesianOptimizationTrainingResult? get latestResult => trainingResults.lastOrNull;

  BayesianOptimizationTrainingResult? get selectedResult => latestResult; // TODO Implement selection

  @override
  BayesianOptimizationHubState newState(
    BiocentralCommandStateInformation stateInformation,
    BiocentralCommandStatus status,
  ) {
    return BayesianOptimizationHubState(stateInformation, status, trainingResults, selectedResultIndex);
  }

  @override
  BayesianOptimizationHubState copyWith({required Map<String, dynamic> copyMap}) {
    return BayesianOptimizationHubState(
      stateInformation,
      status,
      copyMap['trainingResults'] ?? trainingResults,
      copyMap['selectedResultIndex'] ?? selectedResultIndex,
    );
  }

  @override
  List<Object?> get props =>
      [stateInformation, status, trainingResults, selectedResultIndex, latestResult, latestResult?.experimentalData];
}

class BayesianOptimizationHubBloc extends BiocentralBloc<BayesianOptimizationHubEvent, BayesianOptimizationHubState>
    with BiocentralSyncBloc {
  final BayesianOptimizationRepository _bayesianOptimizationRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabaseRepository _databaseRepository;
  final BiocentralClientRepository _clientRepository;
  final EventBus _eventBus;

  /// Constructor for Bayesian Optimization Bloc.
  ///
  /// - [_bayesianOptimizationRepository]: Repository for managing Bayesian Optimization data.
  /// - [_biocentralProjectRepository]: Repository for managing project data.
  /// - [_bioCentralClientRepository]: Repository for managing client data.
  /// - [eventBus]: Event bus for handling events.
  /// - [_biocentralDatabaseRepository]: Repository for managing database data.
  BayesianOptimizationHubBloc(
    this._bayesianOptimizationRepository,
    this._biocentralProjectRepository,
    this._clientRepository,
    this._eventBus,
    this._databaseRepository,
  ) : super(const BayesianOptimizationHubState.idle(), _eventBus) {
    on<BayesianOptimizationHubLoadEvent>(_onLoadTrainings);
    on<BayesianOptimizationHubSelectEvent>(_onSelectTraining);
    on<BayesianOptimizationHubAddExperimentalDataEvent>(_onAddExperimentalData);
    on<BayesianOptimizationHubLoadTrainingsFromFileEvent>(_onLoadPreviousTrainingsFromFile);
  }

  Future<void> _onLoadTrainings(
    BayesianOptimizationHubLoadEvent event,
    Emitter<BayesianOptimizationHubState> emit,
  ) async {
    final loadedTrainings = _bayesianOptimizationRepository.trainingResultsToList();
    emit(
      state.copyWith(copyMap: {'trainingResults': loadedTrainings}),
    );
  }

  Future<void> _onSelectTraining(
    BayesianOptimizationHubSelectEvent event,
    Emitter<BayesianOptimizationHubState> emit,
  ) async {
    emit(state.copyWith(copyMap: {'selectedResultIndex': event.selectedIndex}));
  }

  Future<void> _onAddExperimentalData(
    BayesianOptimizationHubAddExperimentalDataEvent event,
    Emitter<BayesianOptimizationHubState> emit,
  ) async {
    // Always add to latest result
    if (state.latestResult == null) {
      // TODO This should not happen
      return;
    }
    final newExperimentalData = event.experimentalData;
    final existingExperimentalData = state.latestResult!.experimentalData;
    final mergedData = Map.of(existingExperimentalData);
    for (final (key, value) in newExperimentalData.entriesRecord) {
      mergedData[key] = value; // Overwrite if data was updated via dialog
    }
    final updatedResult = state.latestResult!.copyWith(experimentalData: mergedData);
    final updatedResults = _bayesianOptimizationRepository.updateLatestResult(updatedResult);
    // Sync back to database
    // TODO [Refactor] Get database type from campaign
    final database = _databaseRepository.getFromType(Protein);
    if (database == null) {
      // TODO Error Handling
    }
    final entitiesToUpdate = <String, BioEntity>{};
    for (final (id, value) in mergedData.entriesRecord) {
      final entityToUpdate = database!.getEntityById(id);
      final updatedEntity = entityToUpdate?.updateFromMap<Protein>({state.latestResult!.trainingConfig.selectedFeature!: value.toString()});
      if (updatedEntity != null) {
        entitiesToUpdate[id] = updatedEntity;
      }
    }
    syncWithDatabases(entitiesToUpdate, importMode: DatabaseImportMode.merge);
    emit(state.copyWith(copyMap: {'trainingResults': updatedResults}));
  }

  /// Handles the loading of previous training results.
  ///
  /// - [event]: The event to load previous trainings.
  /// - [emit]: Emits the new state.
  Future<void> _onLoadPreviousTrainingsFromFile(
    BayesianOptimizationHubLoadTrainingsFromFileEvent event,
    Emitter<BayesianOptimizationHubState> emit,
  ) async {
    // TODO Refactor to command
    emit(state.setOperating(information: 'Loading previous trainings...'));

    final loadingEither = await _biocentralProjectRepository.handleLoad(xFile: event.xFile);
    loadingEither.match((error) => emit(state.setErrored(information: 'Loading previous trainings failed!')),
        (loadedFile) {
      if (loadedFile == null) {
        emit(state.setErrored(information: 'Loading previous trainings failed!'));
      } else {
        final loadedTrainings = _bayesianOptimizationRepository.loadTrainingResults(loadedFile.content);
        emit(
          state
              .setFinished(information: 'Loading previous trainings finished!')
              .copyWith(copyMap: {'trainingResults': loadedTrainings}),
        );
      }
    });
  }
}
