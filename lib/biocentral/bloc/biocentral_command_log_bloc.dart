import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class BiocentralCommandLogEvent {}

final class BiocentralCommandLogLoadEvent extends BiocentralCommandLogEvent {}

@immutable
final class BiocentralCommandLogState extends Equatable {
  final List<BiocentralCommandLog> commandLogs;
  final BiocentralCommandLogStatus status;

  const BiocentralCommandLogState(this.commandLogs, this.status);

  const BiocentralCommandLogState.initial()
      : commandLogs = const [],
        status = BiocentralCommandLogStatus.initial;

  const BiocentralCommandLogState.loading(this.commandLogs) : status = BiocentralCommandLogStatus.loading;

  const BiocentralCommandLogState.loaded(this.commandLogs) : status = BiocentralCommandLogStatus.loaded;

  @override
  List<Object?> get props => [commandLogs, status];
}

enum BiocentralCommandLogStatus { initial, loading, empty, loaded }

class BiocentralCommandLogBloc extends Bloc<BiocentralCommandLogEvent, BiocentralCommandLogState> {
  final BiocentralProjectRepository _biocentralProjectRepository;

  BiocentralCommandLogBloc(this._biocentralProjectRepository) : super(const BiocentralCommandLogState.initial()) {
    on<BiocentralCommandLogLoadEvent>((event, emit) async {
      emit(BiocentralCommandLogState.loaded(_biocentralProjectRepository.getCommandLog()));
    });
  }
}
