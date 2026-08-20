import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_command_log_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class BiocentralCommandEvent {
  BiocentralCommandEvent();
}

final class BiocentralCommandExecuteEvent<R> extends BiocentralCommandEvent {
  final BiocentralCommand<R> command; // Command to execute
  final Widget Function(BiocentralCommandLog)? visualizeResult;
  final bool autoAccept; // Automatically accept the result after calculation successfully finished

  BiocentralCommandExecuteEvent(
      {required this.command,
      required this.visualizeResult,
      required this.autoAccept}); // Function to visualize result (progress)
}

final class BiocentralCommandAcceptResultEvent extends BiocentralCommandEvent {
  BiocentralCommandAcceptResultEvent();
}

final class BiocentralCommandDiscardResultEvent extends BiocentralCommandEvent {
  BiocentralCommandDiscardResultEvent();
}

@immutable
class BiocentralCommandState extends Equatable {
  final BiocentralCommand? _currentCommand; // Command to be executed, should not be used in UI
  final BiocentralCommandLog? currentCommandLog;
  final Widget Function(BiocentralCommandLog)? visualizeResult; // Function to visualize result (progress)

  const BiocentralCommandState(this._currentCommand, this.currentCommandLog, this.visualizeResult);

  const BiocentralCommandState.idle()
      : _currentCommand = null,
        currentCommandLog = null,
        visualizeResult = null;

  const BiocentralCommandState.start(this._currentCommand, this.visualizeResult) : currentCommandLog = null;

  BiocentralCommandState update(BiocentralCommandLog commandLog) {
    return BiocentralCommandState(_currentCommand, commandLog, visualizeResult);
  }

  bool isIdle() {
    return currentCommandLog == null;
  }

  bool isOperating() {
    return currentCommandLog?.commandStatus == BiocentralCommandStatus.operating;
  }

  bool isFinished() {
    return currentCommandLog?.commandStatus == BiocentralCommandStatus.finished;
  }

  bool isErrored() {
    return currentCommandLog?.commandStatus == BiocentralCommandStatus.errored;
  }

  @override
  List<Object?> get props => [currentCommandLog, visualizeResult];
}

class BiocentralCommandBloc extends Bloc<BiocentralCommandEvent, BiocentralCommandState> {
  final EventBus _eventBus;
  final BiocentralCommandLogRepository _commandLogRepository;

  BiocentralCommandBloc(this._eventBus, this._commandLogRepository) : super(const BiocentralCommandState.idle()) {
    on<BiocentralCommandExecuteEvent>((event, emit) async {
      // TODO CHECK THAT NOTHING IS RUNNING ALREADY
      final commandState = BiocentralCommandState.start(event.command, event.visualizeResult);
      await event.command.execute().forEach((commandLog) {
        emit(commandState.update(commandLog));
      });
      if (event.autoAccept) {
        add(BiocentralCommandAcceptResultEvent());
      }
    });

    on<BiocentralCommandAcceptResultEvent>((event, emit) async {
      state._currentCommand?.acceptResult(state.currentCommandLog);
      _commandLogRepository.logCommand(state.currentCommandLog);
      emit(const BiocentralCommandState.idle());
    });

    on<BiocentralCommandDiscardResultEvent>((event, emit) async {
      emit(const BiocentralCommandState.idle());
    });
  }

  // TODO DEPRECATED FUNCTIONS
  void syncWithDatabases(
    Map<String, BioEntity> entities, {
    DatabaseImportMode importMode = DatabaseImportMode.defaultMode,
  }) async {
    _eventBus.fire(BiocentralDatabaseSyncEvent(entities, importMode));
  }

  void updateDatabases() async {
    _eventBus.fire(BiocentralDatabaseUpdatedEvent());
  }

  void finishedResumableCommand(BiocentralCommandLog finishedCommand) async {
    _eventBus.fire(BiocentralResumableCommandFinishedEvent(finishedCommand));
  }
}
