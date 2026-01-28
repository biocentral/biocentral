import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class BiocentralSideBarEvent {}

final class BiocentralSideBarChangeVisibilityEvent extends BiocentralSideBarEvent {
  final bool? showSidebar; // If not provided, toggles the visibility on or off
  final String? showHelp;

  BiocentralSideBarChangeVisibilityEvent({this.showSidebar, this.showHelp});
}

@immutable
final class BiocentralSideBarState extends Equatable {
  final bool showSidebar;
  final String? showHelp;

  const BiocentralSideBarState(this.showSidebar, this.showHelp);

  const BiocentralSideBarState.opened(this.showHelp) : showSidebar = true;

  const BiocentralSideBarState.closed(this.showHelp) : showSidebar = false;

  @override
  List<Object?> get props => [showSidebar, showHelp];
}

class BiocentralSideBarBloc extends Bloc<BiocentralSideBarEvent, BiocentralSideBarState> {
  BiocentralSideBarBloc() : super(const BiocentralSideBarState.closed(null)) {
    on<BiocentralSideBarChangeVisibilityEvent>((event, emit) async {
      emit(BiocentralSideBarState(event.showSidebar ?? !state.showSidebar, event.showHelp));
    });
  }
}
