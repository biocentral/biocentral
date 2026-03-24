import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_commands.dart';
import 'package:biocentral/plugins/active_learning/domain/al_repository.dart';
import 'package:biocentral/plugins/active_learning/model/al_config.dart';
import 'package:biocentral/plugins/active_learning/model/al_task.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

sealed class ALIterationEvent {}

final class ALIterationStartEvent extends ALIterationEvent {
  final ALConfig config;

  ALIterationStartEvent(this.config);
}

@immutable
final class ALIterationState extends BiocentralCommandState<ALIterationState> {
  const ALIterationState(super.stateInformation, super.status);

  const ALIterationState.idle() : super.idle();

  @override
  List<Object?> get props => [stateInformation, status];

  @override
  ALIterationState newState(
      BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status,) {
    return ALIterationState(stateInformation, status);
  }
}

class ALIterationBloc
    extends BiocentralBloc<ALIterationEvent, ALIterationState>
    with BiocentralUpdateBloc {
  final BiocentralProjectRepository _projectRepository;
  final ALRepository _alRepository;
  final BiocentralDatabaseRepository _databaseRepository;
  final BiocentralAPIRepository _apiRepository;

  ALIterationBloc(
    this._projectRepository,
    this._alRepository,
    this._databaseRepository,
    this._apiRepository,
    EventBus eventBus,
  ) : super(const ALIterationState.idle(), eventBus) {
    on<ALIterationStartEvent>((event, emit) async {
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
        if (boConfig.selectedTask == ALTaskType.findHighestProbability) {
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

        final command = ALIterationCommand(
          biocentralDatabase: biocentralDatabase,
          apiRepository: _apiRepository,
          trainingConfiguration: config,
          targetFeature: boConfig.selectedFeature.toString(),
        );

        await command
            .executeWithLogging<ALIterationState>(
          _projectRepository,
          state,
        )
            .forEach(
          (either) {
            either.match((l) => emit(l), (r) {
              final updatedResults = _alRepository.addTrainingResult(r);
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
