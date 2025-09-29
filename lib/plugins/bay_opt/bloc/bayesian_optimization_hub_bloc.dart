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

  const BayesianOptimizationHubState(super.stateInformation, super.status, this.trainingResults);

  const BayesianOptimizationHubState.idle()
      : trainingResults = const [],
        super.idle();

  BayesianOptimizationTrainingResult? get latestResult => trainingResults.lastOrNull;

  @override
  BayesianOptimizationHubState newState(
    BiocentralCommandStateInformation stateInformation,
    BiocentralCommandStatus status,
  ) {
    return BayesianOptimizationHubState(stateInformation, status, trainingResults);
  }

  @override
  BayesianOptimizationHubState copyWith({required Map<String, dynamic> copyMap}) {
    return BayesianOptimizationHubState(
      stateInformation,
      status,
      copyMap['trainingResults'] ?? trainingResults,
    );
  }

  @override
  List<Object?> get props => [stateInformation, status, trainingResults];
}

class BayesianOptimizationHubBloc extends BiocentralBloc<BayesianOptimizationHubEvent, BayesianOptimizationHubState> {
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
    on<BayesianOptimizationHubLoadTrainingsFromFileEvent>(_onLoadPreviousTrainingsFromFile);
  }

  Future<void> _onLoadTrainings(
    BayesianOptimizationHubLoadEvent event,
    Emitter<BayesianOptimizationHubState> emit,
  ) async {
    final loadedTrainings = _bayesianOptimizationRepository.trainingResultsToList();
    emit(state.copyWith(copyMap: {'trainingResults': loadedTrainings}));
  }

  /// Updates protein lab values in the database based on training results
  Future<void> _updateProteinLabValues(
    BiocentralDatabase proteinDatabase,
    Map<String, dynamic> config,
    BayesianOptimizationTrainingResult trainingResult,
    List<double?> updateList,
  ) async {
    // TODO Replace with database abstraction
    for (int i = 0; i < updateList.length; i++) {
      if (updateList[i] != null) {
        final String proteinId = trainingResult.results![i].id!;
        final double? newvalue = updateList[i];
        if (newvalue != null) {
          final BioEntity? entity = proteinDatabase.getEntityById(proteinId);
          if (entity != null && entity is Protein) {
            final Map<String, String> newAttributes = Map.from(entity.attributes.toMap());
            newAttributes[config['feature_name']] = newvalue.toString();
            final Protein updatedProtein = entity.copyWith(attributes: CustomAttributes(newAttributes));
            proteinDatabase.updateEntity(proteinId, updatedProtein);
          }
        }
      }
    }
    _eventBus.fire(BiocentralDatabaseUpdatedEvent());
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
