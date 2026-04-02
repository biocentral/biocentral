import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_command_log_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class BiocentralCommandLogEvent {}

final class _BiocentralCommandLogLoadEvent extends BiocentralCommandLogEvent {
  final List<BiocentralCommandLog> commandLog;

  _BiocentralCommandLogLoadEvent(this.commandLog);
}

@immutable
final class BiocentralCommandLogState extends Equatable {
  final List<BiocentralCommandLog> commandLogs;

  const BiocentralCommandLogState(this.commandLogs);

  const BiocentralCommandLogState.initial() : commandLogs = const [];

  const BiocentralCommandLogState.loaded(this.commandLogs);

  @override
  List<Object?> get props => [commandLogs];
}

class BiocentralCommandLogBloc extends Bloc<BiocentralCommandLogEvent, BiocentralCommandLogState> {
  final BiocentralCommandLogRepository _commandLogRepository;

  BiocentralCommandLogBloc(this._commandLogRepository) : super(const BiocentralCommandLogState.initial()) {
    on<_BiocentralCommandLogLoadEvent>((event, emit) async {
      emit(BiocentralCommandLogState.loaded(event.commandLog));
    });

    _setupSubscription();
  }

  void _setupSubscription() {
    // Load initial
    final initialCommandLog = _commandLogRepository.getCommandLog();
    add(_BiocentralCommandLogLoadEvent(initialCommandLog));

    _commandLogRepository.databaseStream.listen((commandLogs) {
      add(_BiocentralCommandLogLoadEvent(commandLogs));
    });
  }
}
