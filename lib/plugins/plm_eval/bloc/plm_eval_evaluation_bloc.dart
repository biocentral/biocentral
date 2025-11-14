import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_commands.dart';
import 'package:biocentral/plugins/plm_eval/domain/plm_eval_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';

sealed class PLMEvalEvaluationEvent {}

final class PLMEvalHuggingfaceEvaluationStartEvent extends PLMEvalEvaluationEvent {
  final String modelID;
  final List<PLMEvalTaskInformation> tasks;

  PLMEvalHuggingfaceEvaluationStartEvent(this.modelID, this.tasks);
}

final class PLMEvalONNXEvaluationStartEvent extends PLMEvalEvaluationEvent {
  final XFile onnxFile;
  final Map<String, dynamic> tokenizerConfig;
  final List<PLMEvalTaskInformation> tasks;

  PLMEvalONNXEvaluationStartEvent(this.onnxFile, this.tokenizerConfig, this.tasks);
}

final class PLMEvalEvaluationResumeEvent extends PLMEvalEvaluationEvent {
  final BiocentralCommandLog commandLog;

  PLMEvalEvaluationResumeEvent(this.commandLog);
}

@immutable
final class PLMEvalEvaluationState extends BiocentralCommandState<PLMEvalEvaluationState> {
  final String? modelID;
  final AutoEvalProgressWrapper? autoEvalProgress;

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
  List<Object?> get props => [stateInformation, modelID, autoEvalProgress, status];

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
  final BiocentralAPIRepository _apiRepository;
  final PLMEvalRepository _plmEvalRepository;

  PLMEvalEvaluationBloc(
    this._projectRepository,
    this._apiRepository,
    this._plmEvalRepository,
    EventBus eventBus,
  ) : super(const PLMEvalEvaluationState.idle(), eventBus) {
    on<PLMEvalHuggingfaceEvaluationStartEvent>((event, emit) async {
      final autoEvalCommand = AutoevalPLMCommand(
        projectRepository: _projectRepository,
        apiRepository: _apiRepository,
        plmEvalRepository: _plmEvalRepository,
        modelID: event.modelID,
        onnxFile: null,
        tokenizerConfig: null,
        tasks: event.tasks,
      );
      await autoEvalCommand.executeWithLogging<PLMEvalEvaluationState>(_projectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) {
          updateDatabases();
        }); // Ignore result here
      });
    });
    on<PLMEvalONNXEvaluationStartEvent>((event, emit) async {
      final autoEvalCommand = AutoevalPLMCommand(
        projectRepository: _projectRepository,
        apiRepository: _apiRepository,
        plmEvalRepository: _plmEvalRepository,
        modelID: event.onnxFile.name.replaceAll('.onnx', ''),
        onnxFile: event.onnxFile,
        tokenizerConfig: event.tokenizerConfig,
        tasks: event.tasks,
      );
      await autoEvalCommand.executeWithLogging<PLMEvalEvaluationState>(_projectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) {
          updateDatabases();
        }); // Ignore result here
      });
    });
    on<PLMEvalEvaluationResumeEvent>((event, emit) async {
      /*
      // TODO [Refactoring] Resume

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
      // TODO Improve conversion
      final List<BenchmarkDataset> convertedBenchmarkDatasets = [];
      for (final entry in benchmarkDatasets.entries) {
        final datasetName = entry.key;
        for (final splitName in entry.value) {
          convertedBenchmarkDatasets.add(BenchmarkDataset(taskName: '$datasetName-' + splitName));
        }
      }

      final autoEvalCommand = AutoevalPLMCommand(
        projectRepository: _projectRepository,
        apiRepository: _apiRepository,
        plmEvalRepository: _plmEvalRepository,
        modelID: modelID,
        tasks: convertedBenchmarkDatasets,
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
       */
    });
  }
}
