import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_commands.dart';
import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/domain/plm_eval_repository.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:cross_file/cross_file.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

sealed class PLMEvalHubEvent {}

final class PLMEvalHubLoadEvent extends PLMEvalHubEvent {}

final class PLMEvalHubLoadPersistentResultsEvent extends PLMEvalHubEvent {
  final XFile persistentResultFile;

  PLMEvalHubLoadPersistentResultsEvent(this.persistentResultFile);
}

final class PLMEvalHubAddResumableCommandsEvent extends PLMEvalHubEvent {
  final List<BiocentralCommandLog> resumableCommands;

  PLMEvalHubAddResumableCommandsEvent(this.resumableCommands);
}

final class PLMEvalHubRemoveResumableCommandEvent extends PLMEvalHubEvent {
  final BiocentralCommandLog commandToRemove;

  PLMEvalHubRemoveResumableCommandEvent(this.commandToRemove);
}

@immutable
final class PLMEvalHubState extends BiocentralCommandState<PLMEvalHubState> {
  final List<AutoEvalProgress> sessionResults;
  final List<PLMEvalPersistentResult> persistentResults;

  final List<BiocentralCommandLog> resumableCommands;

  const PLMEvalHubState(
      super.stateInformation, super.status, this.sessionResults, this.persistentResults, this.resumableCommands);

  const PLMEvalHubState.idle()
      : sessionResults = const [],
        persistentResults = const [],
        resumableCommands = const [],
        super.idle();

  @override
  PLMEvalHubState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return PLMEvalHubState(stateInformation, status, sessionResults, persistentResults, resumableCommands);
  }

  @override
  PLMEvalHubState copyWith({required Map<String, dynamic> copyMap}) {
    return PLMEvalHubState(
      stateInformation,
      status,
      copyMap['sessionResults'] ?? sessionResults,
      copyMap['persistentResults'] ?? persistentResults,
      copyMap['resumableCommands'] ?? resumableCommands,
    );
  }

  @override
  List<Object?> get props => [sessionResults, persistentResults, resumableCommands, status];
}

enum PLMEvalHubStatus { initial, loading, loaded, errored }

class PLMEvalHubBloc extends BiocentralBloc<PLMEvalHubEvent, PLMEvalHubState> with BiocentralUpdateBloc {
  final BiocentralProjectRepository _projectRepository;
  final PLMEvalRepository _plmEvalRepository;

  PLMEvalHubBloc(this._projectRepository, this._plmEvalRepository, EventBus eventBus)
      : super(const PLMEvalHubState.idle(), eventBus) {
    on<PLMEvalHubLoadEvent>((event, emit) async {
      final sessionResults = _plmEvalRepository.getSessionResults();
      final persistentResults = _plmEvalRepository.getPersistentResults();
      emit(
        state.copyWith(
          copyMap: {
            if (sessionResults.isNotEmpty) 'sessionResults': sessionResults,
            'persistentResults': persistentResults,
          },
        ),
      );
    });
    on<PLMEvalHubLoadPersistentResultsEvent>((event, emit) async {
      final PLMEvalLoadPersistentResultCommand loadPersistentResultCommand = PLMEvalLoadPersistentResultCommand(
        projectRepository: _projectRepository,
        plmEvalRepository: _plmEvalRepository,
        persistentResultFile: event.persistentResultFile,
      );

      await loadPersistentResultCommand
          .executeWithLogging<PLMEvalHubState>(_projectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) {
          updateDatabases();
        }); // Ignore result here
      });
    });
    on<PLMEvalHubAddResumableCommandsEvent>((event, emit) async {
      emit(state.setOperating(information: 'Looking for resumable commands..'));

      // TODO [Refactoring] make command type name static to avoid string here
      final resumableCommands = event.resumableCommands
          .where(
            (commandLog) =>
                commandLog.commandName == 'AutoEvalPLMCommand' &&
                commandLog.commandStatus == BiocentralCommandStatus.operating &&
                commandLog.metaData.serverTaskID != null,
          )
          .toList();

      emit(
        state
            .setFinished(information: 'Finished loading resumable commands!')
            .copyWith(copyMap: {'resumableCommands': resumableCommands}),
      );
    });
    on<PLMEvalHubRemoveResumableCommandEvent>((event, emit) async {
      final updatedResumableCommands = List<BiocentralCommandLog>.from(state.resumableCommands)
        ..remove(event.commandToRemove);
      emit(
        state.copyWith(copyMap: {'resumableCommands': updatedResumableCommands}),
      );
    });
  }
}
