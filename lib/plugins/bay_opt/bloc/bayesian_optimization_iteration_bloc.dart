import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_commands.dart';
import 'package:biocentral/plugins/bay_opt/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bay_opt/domain/bayesian_optimization_repository.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_model_types.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_task.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

sealed class BayesianOptimizationIterationEvent {}

final class BayesianOptimizationIterationStartEvent extends BayesianOptimizationIterationEvent {
  final TaskType? selectedTask;
  final String? selectedFeature;
  final BayesianOptimizationModelTypes? selectedModel;
  final double exploitationExplorationValue;
  final PredefinedEmbedder? selectedEmbedder;
  final String? optimizationType;
  final double? targetValue;
  final double? targetRangeMin;
  final double? targetRangeMax;
  final bool? desiredBooleanValue;

  /// Constructor for starting Bayesian Optimization training.
  ///
  /// - [selectedTask]: The selected task type.
  /// - [selectedFeature]: The feature to optimize.
  /// - [selectedModel]: The model type.
  /// - [exploitationExplorationValue]: The coefficient for exploitation vs. exploration.
  /// - [selectedEmbedder]: The selected embedder.
  /// - [optimizationType]: The optimization type (e.g., Maximize, Minimize).
  /// - [targetValue]: The target value for optimization.
  /// - [targetRangeMin]: The minimum value for the target range.
  /// - [targetRangeMax]: The maximum value for the target range.
  /// - [desiredBooleanValue]: The desired boolean value for discrete tasks.
  BayesianOptimizationIterationStartEvent(
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
final class BayesianOptimizationIterationState extends BiocentralCommandState<BayesianOptimizationIterationState> {
  const BayesianOptimizationIterationState(super.stateInformation, super.status);

  const BayesianOptimizationIterationState.idle() : super.idle();

  @override
  List<Object?> get props => [stateInformation, status];

  @override
  BayesianOptimizationIterationState newState(
      BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return BayesianOptimizationIterationState(stateInformation, status);
  }
}

class BayesianOptimizationIterationBloc
    extends BiocentralBloc<BayesianOptimizationIterationEvent, BayesianOptimizationIterationState>
    with BiocentralUpdateBloc {
  final BiocentralProjectRepository _projectRepository;
  final BayesianOptimizationRepository _bayesianOptimizationRepository;
  final BiocentralDatabaseRepository _databaseRepository;
  final BiocentralClientRepository _clientRepository;

  BayesianOptimizationIterationBloc(
    this._projectRepository,
    this._bayesianOptimizationRepository,
    this._databaseRepository,
    this._clientRepository,
    EventBus eventBus,
  ) : super(const BayesianOptimizationIterationState.idle(), eventBus) {
    on<BayesianOptimizationIterationStartEvent>((event, emit) async {
      final BiocentralDatabase? biocentralDatabase = _databaseRepository.getFromType(Protein);
      if (biocentralDatabase == null) {
        emit(
          state.setErrored(
            information: 'Could not find the database to use!',
          ),
        );
      } else {
        final String databaseHash = await biocentralDatabase.getHash();
        Map<String, dynamic> config = {
          'database_hash': databaseHash,
          'optimization_mode': switch (event.optimizationType) {
            'Maximize' => 'maximize',
            'Minimize' => 'minimize',
            'Target Range' => 'interval',
            'Target Value' => 'value',
            _ => 'value',
          },
          'model_type': event.selectedModel?.name,
          // Does not support other embedders than One_hot. Backend loads indefinitely
          'embedder_name': event.selectedEmbedder?.biotrainerName,
          'feature_name': event.selectedFeature.toString(),
          'coefficient': event.exploitationExplorationValue.toString(),
        };

        // Discrete:
        if (event.selectedTask == TaskType.findHighestProbability) {
          config = {
            ...config,
            'discrete': true,
            'discrete_labels': ['0', '1'],
            'discrete_targets': event.desiredBooleanValue.toString().toLowerCase() == 'true' ? ['1'] : ['0'],
          };
          // Continuous:
        } else {
          config = {
            ...config,
            'discrete': false,
            'target_lb': event.targetRangeMin?.toString() ?? event.targetValue?.toString() ?? '-Infinity',
            'target_ub': event.targetRangeMax?.toString() ?? event.targetValue?.toString() ?? 'Infinity',
            'target_value': switch (event.optimizationType.toString()) {
              'Target Value' => event.targetValue.toString(),
              _ => '',
            },
          };
        }

        final command = BayesianOptimizationIterationCommand(
          biocentralDatabase: biocentralDatabase,
          client: _clientRepository.getServiceClient<BayesianOptimizationClient>(),
          trainingConfiguration: config,
          targetFeature: event.selectedFeature.toString(),
        );

        await command
            .executeWithLogging<BayesianOptimizationIterationState>(
          _projectRepository,
          state,
        )
            .forEach(
          (either) {
            either.match((l) => emit(l), (r) {
              _bayesianOptimizationRepository.addTrainingResult(r);
              emit(
                state.setFinished(
                  information: 'Training completed',
                ),
              );
            });
          },
        ).then((_) => updateDatabases());
      }
    });
  }
}
