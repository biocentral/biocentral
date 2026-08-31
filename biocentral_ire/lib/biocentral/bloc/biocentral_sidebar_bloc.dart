import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum BiocentralSideBarDisplayMode {
  none,
  help,
  commandLog;

  static BiocentralSideBarDisplayMode defaultMode() {
    return BiocentralSideBarDisplayMode.none;
  }
}

sealed class BiocentralSideBarEvent {}

final class BiocentralSideBarChangeVisibilityEvent extends BiocentralSideBarEvent {
  final BiocentralSideBarDisplayMode displayMode;
  final bool force; // Forces to show the side bar, does not toggle it to be invisible if already visible
  final String? showHelp;

  BiocentralSideBarChangeVisibilityEvent({required this.displayMode, this.force = false, this.showHelp});
}

@immutable
final class BiocentralSideBarState extends Equatable {
  final BiocentralSideBarDisplayMode displayMode;
  final String? showHelp;

  const BiocentralSideBarState(this.displayMode, this.showHelp);

  int? selectionIndex() {
    switch (displayMode) {
      case BiocentralSideBarDisplayMode.none:
        return null;
      case BiocentralSideBarDisplayMode.help:
        return 0;
      case BiocentralSideBarDisplayMode.commandLog:
        return 1;
    }
  }

  @override
  List<Object?> get props => [displayMode, showHelp];
}

class BiocentralSideBarBloc extends Bloc<BiocentralSideBarEvent, BiocentralSideBarState> {
  BiocentralSideBarBloc() : super(BiocentralSideBarState(BiocentralSideBarDisplayMode.defaultMode(), null)) {
    on<BiocentralSideBarChangeVisibilityEvent>((event, emit) async {
      if (event.force) {
        return emit(BiocentralSideBarState(event.displayMode, event.showHelp));
      }
      var newDisplayMode = event.displayMode;
      final currentDisplayMode = state.displayMode;
      if (newDisplayMode == currentDisplayMode) {
        // TOGGLE DISABLE
        newDisplayMode = BiocentralSideBarDisplayMode.none;
      }
      emit(BiocentralSideBarState(newDisplayMode, event.showHelp));
    });
  }
}
