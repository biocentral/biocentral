import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bay_opt/domain/bay_opt_repository.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_training_result.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:cross_file/cross_file.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BayOptHubEvent {}

class BayOptHubLoadEvent extends BayOptHubEvent {}

class BayOptHubSelectEvent extends BayOptHubEvent {
  final int selectedIndex;

  BayOptHubSelectEvent({required this.selectedIndex});
}

class BayOptHubAddExperimentalDataEvent extends BayOptHubEvent {
  final Map<String, dynamic> experimentalData;

  BayOptHubAddExperimentalDataEvent({required this.experimentalData});
}

class BayOptHubLoadTrainingsFromFileEvent extends BayOptHubEvent {
  final XFile? xFile;

  BayOptHubLoadTrainingsFromFileEvent({required this.xFile});
}

class BayOptIterateTrainingEvent extends BayOptHubEvent {
  final BuildContext context;
  final BayOptTrainingResult trainingResult;
  final List<double?> updateList;

  /// Constructor for iterating Bayesian Optimization training.
  ///
  /// - [context]: The build context.
  /// - [trainingResult]: The training result to iterate from.
  /// - [updateList]: The list of values to update.
  BayOptIterateTrainingEvent(this.context, this.trainingResult, this.updateList);
}

class BayOptDirectIterateTrainingEvent extends BayOptHubEvent {
  final BuildContext context;
  final BayOptTrainingResult trainingResult;
  final List<double?> updateList;

  /// Constructor for iterating Bayesian Optimization training.
  ///
  /// - [context]: The build context.
  /// - [trainingResult]: The training result to iterate from.
  /// - [updateList]: The list of values to update.
  BayOptDirectIterateTrainingEvent(this.context, this.trainingResult, this.updateList);
}

@immutable
final class BayOptHubState extends BiocentralCommandState<BayOptHubState> {
  final List<BayOptTrainingResult> trainingResults;
  final int selectedResultIndex;

  const BayOptHubState(
    super.stateInformation,
    super.status,
    this.trainingResults,
    this.selectedResultIndex,
  );

  const BayOptHubState.idle()
      : trainingResults = const [],
        selectedResultIndex = 0,
        super.idle();

  BayOptTrainingResult? get latestResult => trainingResults.lastOrNull;

  BayOptTrainingResult? get selectedResult => latestResult; // TODO Implement selection

  @override
  BayOptHubState newState(
    BiocentralCommandStateInformation stateInformation,
    BiocentralCommandStatus status,
  ) {
    return BayOptHubState(stateInformation, status, trainingResults, selectedResultIndex);
  }

  @override
  BayOptHubState copyWith({required Map<String, dynamic> copyMap}) {
    return BayOptHubState(
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

class BayOptHubBloc extends BiocentralBloc<BayOptHubEvent, BayOptHubState>
    with BiocentralSyncBloc {
  final BayOptRepository _bayOptRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabaseRepository _databaseRepository;
  final BiocentralClientRepository _clientRepository;
  final EventBus _eventBus;

  /// Constructor for Bayesian Optimization Bloc.
  ///
  /// - [_bayOptRepository]: Repository for managing Bayesian Optimization data.
  /// - [_biocentralProjectRepository]: Repository for managing project data.
  /// - [_bioCentralClientRepository]: Repository for managing client data.
  /// - [eventBus]: Event bus for handling events.
  /// - [_biocentralDatabaseRepository]: Repository for managing database data.
  BayOptHubBloc(
    this._bayOptRepository,
    this._biocentralProjectRepository,
    this._clientRepository,
    this._eventBus,
    this._databaseRepository,
  ) : super(const BayOptHubState.idle(), _eventBus) {
    on<BayOptHubLoadEvent>(_onLoadTrainings);
    on<BayOptHubSelectEvent>(_onSelectTraining);
    on<BayOptHubAddExperimentalDataEvent>(_onAddExperimentalData);
    on<BayOptHubLoadTrainingsFromFileEvent>(_onLoadPreviousTrainingsFromFile);
  }

  Future<void> _onLoadTrainings(
    BayOptHubLoadEvent event,
    Emitter<BayOptHubState> emit,
  ) async {
    final loadedTrainings = _bayOptRepository.trainingResultsToList();
    emit(
      state.copyWith(copyMap: {'trainingResults': loadedTrainings}),
    );
  }

  Future<void> _onSelectTraining(
    BayOptHubSelectEvent event,
    Emitter<BayOptHubState> emit,
  ) async {
    emit(state.copyWith(copyMap: {'selectedResultIndex': event.selectedIndex}));
  }

  Future<void> _onAddExperimentalData(
    BayOptHubAddExperimentalDataEvent event,
    Emitter<BayOptHubState> emit,
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
    final updatedResults = _bayOptRepository.updateLatestResult(updatedResult);
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
    BayOptHubLoadTrainingsFromFileEvent event,
    Emitter<BayOptHubState> emit,
  ) async {
    // TODO Refactor to command
    emit(state.setOperating(information: 'Loading previous trainings...'));

    final loadingEither = await _biocentralProjectRepository.handleLoad(xFile: event.xFile);
    loadingEither.match((error) => emit(state.setErrored(information: 'Loading previous trainings failed!')),
        (loadedFile) {
      if (loadedFile == null) {
        emit(state.setErrored(information: 'Loading previous trainings failed!'));
      } else {
        final loadedTrainings = _bayOptRepository.loadTrainingResults(loadedFile.content);
        emit(
          state
              .setFinished(information: 'Loading previous trainings finished!')
              .copyWith(copyMap: {'trainingResults': loadedTrainings}),
        );
      }
    });
  }
}
