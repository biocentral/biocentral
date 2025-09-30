import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_commands.dart';
import 'package:biocentral/plugins/bay_opt/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bay_opt/domain/bayesian_optimization_repository.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_config.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_task.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

sealed class BayesianOptimizationIterationEvent {}

final class BayesianOptimizationIterationStartEvent extends BayesianOptimizationIterationEvent {
  final BayesianOptimizationConfig config;

  BayesianOptimizationIterationStartEvent(this.config);
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
        // TODO This conversion is not ideal here, improve interface between UI and backend configs
        final boConfig = event.config;
        Map<String, dynamic> config = {
          'database_hash': databaseHash,
          'optimization_mode': switch (boConfig.optimizationType) {
            'Maximize' => 'maximize',
            'Minimize' => 'minimize',
            'Target Range' => 'interval',
            'Target Value' => 'value',
            _ => 'value',
          },
          'model_type': boConfig.selectedModel?.name,
          'embedder_name': boConfig.selectedEmbedder?.biotrainerName,
          'feature_name': boConfig.selectedFeature.toString(),
          'coefficient': boConfig.exploitationExplorationValue.toString(),
        };

        // Discrete:
        if (boConfig.selectedTask == TaskType.findHighestProbability) {
          config = {
            ...config,
            'discrete': true,
            'discrete_labels': ['0', '1'],
            'discrete_targets': boConfig.desiredBooleanValue.toString().toLowerCase() == 'true' ? ['1'] : ['0'],
          };
          // Continuous:
        } else {
          config = {
            ...config,
            'discrete': false,
            'target_lb': boConfig.targetRangeMin?.toString() ?? boConfig.targetValue?.toString() ?? '-Infinity',
            'target_ub': boConfig.targetRangeMax?.toString() ?? boConfig.targetValue?.toString() ?? 'Infinity',
            'target_value': switch (boConfig.optimizationType.toString()) {
              'Target Value' => boConfig.targetValue.toString(),
              _ => '',
            },
          };
        }

        final command = BayesianOptimizationIterationCommand(
          biocentralDatabase: biocentralDatabase,
          client: _clientRepository.getServiceClient<BayesianOptimizationClient>(),
          trainingConfiguration: config,
          targetFeature: boConfig.selectedFeature.toString(),
        );

        await command
            .executeWithLogging<BayesianOptimizationIterationState>(
          _projectRepository,
          state,
        )
            .forEach(
          (either) {
            either.match((l) => emit(l), (r) {
              final updatedResults = _bayesianOptimizationRepository.addTrainingResult(r);
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
