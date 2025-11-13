import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_commands.dart';
import 'package:biocentral/plugins/bay_opt/domain/bay_opt_repository.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_config.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_task.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

sealed class BayOptIterationEvent {}

final class BayOptIterationStartEvent extends BayOptIterationEvent {
  final BayOptConfig config;

  BayOptIterationStartEvent(this.config);
}

@immutable
final class BayOptIterationState extends BiocentralCommandState<BayOptIterationState> {
  const BayOptIterationState(super.stateInformation, super.status);

  const BayOptIterationState.idle() : super.idle();

  @override
  List<Object?> get props => [stateInformation, status];

  @override
  BayOptIterationState newState(
      BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return BayOptIterationState(stateInformation, status);
  }
}

class BayOptIterationBloc
    extends BiocentralBloc<BayOptIterationEvent, BayOptIterationState>
    with BiocentralUpdateBloc {
  final BiocentralProjectRepository _projectRepository;
  final BayOptRepository _bayOptRepository;
  final BiocentralDatabaseRepository _databaseRepository;
  final BiocentralAPIRepository _apiRepository;

  BayOptIterationBloc(
    this._projectRepository,
    this._bayOptRepository,
    this._databaseRepository,
    this._apiRepository,
    EventBus eventBus,
  ) : super(const BayOptIterationState.idle(), eventBus) {
    on<BayOptIterationStartEvent>((event, emit) async {
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
        if (boConfig.selectedTask == BayOptTaskType.findHighestProbability) {
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

        final command = BayOptIterationCommand(
          biocentralDatabase: biocentralDatabase,
          apiRepository: _apiRepository,
          trainingConfiguration: config,
          targetFeature: boConfig.selectedFeature.toString(),
        );

        await command
            .executeWithLogging<BayOptIterationState>(
          _projectRepository,
          state,
        )
            .forEach(
          (either) {
            either.match((l) => emit(l), (r) {
              final updatedResults = _bayOptRepository.addTrainingResult(r);
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
