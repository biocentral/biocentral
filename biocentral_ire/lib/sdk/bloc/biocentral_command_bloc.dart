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

  BiocentralCommandExecuteEvent({
    required this.command,
    required this.visualizeResult,
    required this.autoAccept,
  }); // Function to visualize result (progress)
}

final class BiocentralCommandAcceptResultEvent extends BiocentralCommandEvent {
  final BiocentralCommandLog log;

  BiocentralCommandAcceptResultEvent(this.log);
}

final class BiocentralCommandDiscardResultEvent extends BiocentralCommandEvent {
  final BiocentralCommandLog log;

  BiocentralCommandDiscardResultEvent(this.log);
}

@immutable
class BiocentralCommandState extends Equatable {
  final BiocentralCommand? _currentCommand; // Command to be executed, should not be used in UI
  final BiocentralCommandLog? currentCommandLog;
  final Widget Function(BiocentralCommandLog)? visualizeResult; // Function to visualize result (progress)

  const BiocentralCommandState(this._currentCommand, this.currentCommandLog, this.visualizeResult);

  const BiocentralCommandState.idle() : _currentCommand = null, currentCommandLog = null, visualizeResult = null;

  const BiocentralCommandState.start(this._currentCommand, this.visualizeResult) : currentCommandLog = null;

  BiocentralCommandState update(BiocentralCommandLog commandLog) {
    return BiocentralCommandState(_currentCommand, commandLog, visualizeResult);
  }

  /// Whether another command can begin, including after a terminal failure.
  bool isIdle() {
    return _currentCommand == null;
  }

  bool isOperating() {
    return currentCommandLog?.commandStatus == BiocentralCommandStatus.operating;
  }

  /// Whether execution or an unaccepted successful result occupies the runner.
  bool isBusy() {
    return _currentCommand != null;
  }

  bool isFinished() {
    return currentCommandLog?.commandStatus == BiocentralCommandStatus.finished;
  }

  bool isErrored() {
    return currentCommandLog?.commandStatus == BiocentralCommandStatus.errored;
  }

  @override
  List<Object?> get props => [_currentCommand, currentCommandLog, visualizeResult];
}

class BiocentralCommandBloc extends Bloc<BiocentralCommandEvent, BiocentralCommandState> {
  final EventBus _eventBus;
  final BiocentralCommandLogRepository _commandLogRepository;
  bool _executing = false;

  BiocentralCommandBloc(this._eventBus, this._commandLogRepository) : super(const BiocentralCommandState.idle()) {
    on<BiocentralCommandExecuteEvent>((event, emit) async {
      if (state.isBusy()) {
        _commandLogRepository.logCommand(
          event.command.initLog().errored(
            error: 'Another command is running or awaiting acceptance. Finish it in Activity first.',
          ),
        );
        return;
      }
      final commandState = BiocentralCommandState.start(event.command, event.visualizeResult);
      _executing = true;
      emit(commandState);
      BiocentralCommandLog? latest;
      try {
        await emit.forEach<BiocentralCommandLog>(
          event.command.execute(),
          onData: (log) {
            latest = log;
            return commandState.update(log);
          },
        );
        if (emit.isDone) {
          return;
        }
        _executing = false;
        final log = latest;
        if (log == null || (!state.isFinished() && !state.isErrored())) {
          throw StateError('Command ended without a terminal result.');
        }
        if (state.isErrored()) {
          _commandLogRepository.logCommand(log);
          emit(BiocentralCommandState(null, log, event.visualizeResult));
        } else if (event.autoAccept) {
          add(BiocentralCommandAcceptResultEvent(log));
        }
      } catch (error) {
        _executing = false;
        if (emit.isDone) {
          return;
        }
        final log = (latest ?? event.command.initLog()).errored(error: error.toString());
        _commandLogRepository.logCommand(log);
        emit(BiocentralCommandState(null, log, event.visualizeResult));
      }
    });

    on<BiocentralCommandAcceptResultEvent>((event, emit) {
      if (_executing || !identical(event.log, state.currentCommandLog) || !state.isFinished() || !state.isBusy()) {
        return;
      }
      try {
        state._currentCommand!.acceptResult(event.log);
        _commandLogRepository.logCommand(event.log);
        emit(const BiocentralCommandState.idle());
      } catch (error) {
        final log = event.log.errored(error: error.toString());
        _commandLogRepository.logCommand(log);
        emit(BiocentralCommandState(null, log, state.visualizeResult));
      }
    });

    on<BiocentralCommandDiscardResultEvent>((event, emit) {
      if (_executing || !identical(event.log, state.currentCommandLog) || state.isOperating()) {
        return;
      }
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
