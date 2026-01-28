import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum BiocentralDisplayMode { visualize, analyze }

sealed class BiocentralDisplayModeEvent {}

final class BiocentralDisplayModeChangedEvent extends BiocentralDisplayModeEvent {
  final BiocentralDisplayMode newMode;

  BiocentralDisplayModeChangedEvent({required this.newMode});
}

@immutable
final class BiocentralDisplayModeState extends Equatable {
  final BiocentralDisplayMode displayMode;

  const BiocentralDisplayModeState(this.displayMode);

  const BiocentralDisplayModeState.initial() : displayMode = BiocentralDisplayMode.visualize;

  List<bool> get toSelection => BiocentralDisplayMode.values.map((v) => v == displayMode).toList();

  @override
  List<Object?> get props => [displayMode];
}

class BiocentralDisplayModeBloc extends Bloc<BiocentralDisplayModeEvent, BiocentralDisplayModeState> {
  BiocentralDisplayModeBloc() : super(const BiocentralDisplayModeState.initial()) {
    on<BiocentralDisplayModeChangedEvent>((event, emit) async {
      emit(BiocentralDisplayModeState(event.newMode));
    });
  }
}
