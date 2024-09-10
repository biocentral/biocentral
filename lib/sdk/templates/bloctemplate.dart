import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class TemplateEvent {}

final class TemplateAppStartedEvent extends TemplateEvent {}

@immutable
final class TemplateState extends Equatable {
  final TemplateStatus status;

  const TemplateState(this.status);

  const TemplateState.initial() : status = TemplateStatus.initial;

  const TemplateState.loading() : status = TemplateStatus.loading;

  const TemplateState.empty() : status = TemplateStatus.empty;

  const TemplateState.loaded() : status = TemplateStatus.loaded;

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

enum TemplateStatus { initial, loading, empty, loaded }

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  TemplateBloc() : super(const TemplateState.initial()) {
    on<TemplateAppStartedEvent>((event, emit) async {
      emit(const TemplateState.loading());
    });
  }
}
