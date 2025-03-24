import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_commands.dart';
import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
import 'package:biocentral/plugins/plm_eval/domain/plm_eval_repository.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import '../data/plm_eval_service_api.dart';

sealed class PLMEvalEvaluationEvent {}

final class PLMEvalEvaluationStartEvent extends PLMEvalEvaluationEvent {
  final String modelID;
  final List<BenchmarkDataset> benchmarkDatasets;
  final bool recommendedOnly;

  PLMEvalEvaluationStartEvent(this.modelID, this.benchmarkDatasets, this.recommendedOnly);
}

final class PLMEvalEvaluationResumeEvent extends PLMEvalEvaluationEvent {
  final BiocentralCommandLog commandLog;

  PLMEvalEvaluationResumeEvent(this.commandLog);
}

@immutable
final class PLMEvalEvaluationState extends BiocentralCommandState<PLMEvalEvaluationState> {
  final String? modelID;
  final AutoEvalProgress? autoEvalProgress;

  const PLMEvalEvaluationState(
    super.stateInformation,
    super.status,
    this.modelID,
    this.autoEvalProgress,
  );

  const PLMEvalEvaluationState.idle()
      : modelID = null,
        autoEvalProgress = null,
        super.idle();

  @override
  List<Object?> get props => [modelID, autoEvalProgress, status];

  @override
  PLMEvalEvaluationState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return PLMEvalEvaluationState(
      stateInformation,
      status,
      modelID,
      autoEvalProgress,
    );
  }

  @override
  PLMEvalEvaluationState setIdle({String? information}) {
    return const PLMEvalEvaluationState.idle();
  }

  @override
  PLMEvalEvaluationState copyWith({required Map<String, dynamic> copyMap}) {
    return PLMEvalEvaluationState(
      stateInformation,
      status,
      copyMap['modelID'] ?? modelID,
      copyMap['autoEvalProgress'] ?? autoEvalProgress,
    );
  }
}

class PLMEvalEvaluationBloc extends BiocentralBloc<PLMEvalEvaluationEvent, PLMEvalEvaluationState>
    with BiocentralUpdateBloc {
  final BiocentralProjectRepository _projectRepository;
  final BiocentralClientRepository _clientRepository;
  final PLMEvalRepository _plmEvalRepository;

  PLMEvalEvaluationBloc(
    this._projectRepository,
    this._clientRepository,
    this._plmEvalRepository,
    EventBus eventBus,
  ) : super(const PLMEvalEvaluationState.idle(), eventBus) {
    on<PLMEvalEvaluationStartEvent>((event, emit) async {
      final autoEvalCommand = AutoEvalPLMCommand(
        plmEvalClient: _clientRepository.getServiceClient<PLMEvalClient>(),
        plmEvalRepository: _plmEvalRepository,
        modelID: event.modelID,
        recommendedOnly: event.recommendedOnly,
        benchmarkDatasets: event.benchmarkDatasets,
      );
      await autoEvalCommand.executeWithLogging<PLMEvalEvaluationState>(_projectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) {
          updateDatabases();
        }); // Ignore result here
      });
    });
    on<PLMEvalEvaluationResumeEvent>((event, emit) async {
      final String? modelID = event.commandLog.commandConfig['modelID'];
      final bool? recommendedOnly = event.commandLog.commandConfig['recommendedOnly'];
      final Map<String, dynamic>? benchmarkDatasets = event.commandLog.commandConfig['benchmarkDatasets'];
      final taskID = event.commandLog.metaData.serverTaskID;

      if (modelID == null || recommendedOnly == null || benchmarkDatasets == null || taskID == null) {
        return emit(
          state.setErrored(
            information: 'Could not resume plm evaluation: commandLog does not provide correct information!',
          ),
        );
      }

      // TODO [Error handling] Check splitNames
      final List<BenchmarkDataset> convertedBenchmarkDatasets = [];
      for (final entry in benchmarkDatasets.entries) {
        final datasetName = entry.key;
        for (final splitName in entry.value) {
          convertedBenchmarkDatasets.add(BenchmarkDataset(datasetName: datasetName, splitName: splitName));
        }
      }

      final autoEvalCommand = AutoEvalPLMCommand(
        plmEvalClient: _clientRepository.getServiceClient<PLMEvalClient>(),
        plmEvalRepository: _plmEvalRepository,
        modelID: modelID,
        recommendedOnly: recommendedOnly,
        benchmarkDatasets: convertedBenchmarkDatasets,
      );
      await autoEvalCommand
          .resumeWithLogging<PLMEvalEvaluationState>(
        _projectRepository,
        event.commandLog.metaData.startTime,
        taskID,
        state,
      )
          .forEach((either) {
        either.match((l) => emit(l), (r) {
          updateDatabases();
          finishedResumableCommand(event.commandLog);
        }); // Ignore result here
      });
    });
  }
}
