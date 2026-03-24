import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/domain/al_repository.dart';
import 'package:biocentral/plugins/active_learning/model/al_training_result.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:cross_file/cross_file.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ALHubEvent {}

class ALHubLoadEvent extends ALHubEvent {}

class ALHubSelectEvent extends ALHubEvent {
  final int selectedIndex;

  ALHubSelectEvent({required this.selectedIndex});
}

class ALHubAddExperimentalDataEvent extends ALHubEvent {
  final Map<String, dynamic> experimentalData;

  ALHubAddExperimentalDataEvent({required this.experimentalData});
}

class ALHubLoadTrainingsFromFileEvent extends ALHubEvent {
  final XFile? xFile;

  ALHubLoadTrainingsFromFileEvent({required this.xFile});
}

class ALIterateTrainingEvent extends ALHubEvent {
  final BuildContext context;
  final ALTrainingResult trainingResult;
  final List<double?> updateList;

  /// Constructor for iterating Active Learning training.
  ///
  /// - [context]: The build context.
  /// - [trainingResult]: The training result to iterate from.
  /// - [updateList]: The list of values to update.
  ALIterateTrainingEvent(this.context, this.trainingResult, this.updateList);
}

class ALDirectIterateTrainingEvent extends ALHubEvent {
  final BuildContext context;
  final ALTrainingResult trainingResult;
  final List<double?> updateList;

  /// Constructor for iterating Active Learning training.
  ///
  /// - [context]: The build context.
  /// - [trainingResult]: The training result to iterate from.
  /// - [updateList]: The list of values to update.
  ALDirectIterateTrainingEvent(this.context, this.trainingResult, this.updateList);
}

@immutable
final class ALHubState extends BiocentralCommandState<ALHubState> {
  final List<ALTrainingResult> trainingResults;
  final int selectedResultIndex;

  const ALHubState(
    super.stateInformation,
    super.status,
    this.trainingResults,
    this.selectedResultIndex,
  );

  const ALHubState.idle()
      : trainingResults = const [],
        selectedResultIndex = 0,
        super.idle();

  ALTrainingResult? get latestResult => trainingResults.lastOrNull;

  ALTrainingResult? get selectedResult => latestResult; // TODO Implement selection

  @override
  ALHubState newState(
    BiocentralCommandStateInformation stateInformation,
    BiocentralCommandStatus status,
  ) {
    return ALHubState(stateInformation, status, trainingResults, selectedResultIndex);
  }

  @override
  ALHubState copyWith({required Map<String, dynamic> copyMap}) {
    return ALHubState(
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

class ALHubBloc extends BiocentralBloc<ALHubEvent, ALHubState>
    with BiocentralSyncBloc {
  final ALRepository _alRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabaseRepository _databaseRepository;
  final BiocentralAPIRepository _apiRepository;
  final EventBus _eventBus;

  /// Constructor for Active Learning Bloc.
  ///
  /// - [_alRepository]: Repository for managing active learning data.
  /// - [_biocentralProjectRepository]: Repository for managing project data.
  /// - [_bioCentralClientRepository]: Repository for managing client data.
  /// - [eventBus]: Event bus for handling events.
  /// - [_biocentralDatabaseRepository]: Repository for managing database data.
  ALHubBloc(
    this._alRepository,
    this._biocentralProjectRepository,
    this._apiRepository,
    this._eventBus,
    this._databaseRepository,
  ) : super(const ALHubState.idle(), _eventBus) {
    on<ALHubLoadEvent>(_onLoadTrainings);
    on<ALHubSelectEvent>(_onSelectTraining);
    on<ALHubAddExperimentalDataEvent>(_onAddExperimentalData);
    on<ALHubLoadTrainingsFromFileEvent>(_onLoadPreviousTrainingsFromFile);
  }

  Future<void> _onLoadTrainings(
    ALHubLoadEvent event,
    Emitter<ALHubState> emit,
  ) async {
    final loadedTrainings = _alRepository.trainingResultsToList();
    emit(
      state.copyWith(copyMap: {'trainingResults': loadedTrainings}),
    );
  }

  Future<void> _onSelectTraining(
    ALHubSelectEvent event,
    Emitter<ALHubState> emit,
  ) async {
    emit(state.copyWith(copyMap: {'selectedResultIndex': event.selectedIndex}));
  }

  Future<void> _onAddExperimentalData(
    ALHubAddExperimentalDataEvent event,
    Emitter<ALHubState> emit,
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
    final updatedResults = _alRepository.updateLatestResult(updatedResult);
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
    ALHubLoadTrainingsFromFileEvent event,
    Emitter<ALHubState> emit,
  ) async {
    // TODO Refactor to command
    emit(state.setOperating(information: 'Loading previous trainings...'));

    final loadingEither = await _biocentralProjectRepository.handleLoad(xFile: event.xFile);
    loadingEither.match((error) => emit(state.setErrored(information: 'Loading previous trainings failed!')),
        (loadedFile) {
      if (loadedFile == null) {
        emit(state.setErrored(information: 'Loading previous trainings failed!'));
      } else {
        final loadedTrainings = _alRepository.loadTrainingResults(loadedFile.content);
        emit(
          state
              .setFinished(information: 'Loading previous trainings finished!')
              .copyWith(copyMap: {'trainingResults': loadedTrainings}),
        );
      }
    });
  }
}
