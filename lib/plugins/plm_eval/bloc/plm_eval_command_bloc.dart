import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class PLMEvalCommandEvent {}

final class TemplateAppStartedEvent extends PLMEvalCommandEvent {}

@immutable
final class PLMEvalCommandState extends Equatable {
  final PLMEvalCommandStatus status;

  const PLMEvalCommandState(this.status);

  const PLMEvalCommandState.initial() : status = PLMEvalCommandStatus.initial;

  const PLMEvalCommandState.loading() : status = PLMEvalCommandStatus.loading;

  const PLMEvalCommandState.empty() : status = PLMEvalCommandStatus.empty;

  const PLMEvalCommandState.loaded() : status = PLMEvalCommandStatus.loaded;

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

enum PLMEvalCommandStatus { initial, loading, empty, loaded }

class PLMEvalCommandBloc extends Bloc<PLMEvalCommandEvent, PLMEvalCommandState> {
  PLMEvalCommandBloc() : super(const PLMEvalCommandState.initial()) {
    on<TemplateAppStartedEvent>((event, emit) async {
      emit(const PLMEvalCommandState.loading());
    });
  }
}
