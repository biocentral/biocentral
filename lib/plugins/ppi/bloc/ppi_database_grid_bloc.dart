import 'package:bio_flutter/bio_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../domain/ppi_repository.dart';

sealed class PPIDatabaseGridEvent {
  PlutoGridOnSelectedEvent? selectedEvent;

  PPIDatabaseGridEvent({this.selectedEvent});
}

final class PPIDatabaseGridLoadEvent extends PPIDatabaseGridEvent {
  PPIDatabaseGridLoadEvent();
}

final class PPIDatabaseGridSelectionEvent extends PPIDatabaseGridEvent {
  PPIDatabaseGridSelectionEvent({required super.selectedEvent});
}

@immutable
final class PPIDatabaseGridState extends Equatable {
  final List<ProteinProteinInteraction> ppis;
  final Set<String>? additionalColumns;
  final ProteinProteinInteraction? selectedPPI;
  final PPIDatabaseGridStatus status;

  const PPIDatabaseGridState(this.ppis, this.status, this.selectedPPI, this.additionalColumns);

  const PPIDatabaseGridState.initial()
      : ppis = const [],
        additionalColumns = const {},
        selectedPPI = null,
        status = PPIDatabaseGridStatus.initial;

  const PPIDatabaseGridState.loading(this.ppis, this.additionalColumns, this.selectedPPI)
      : status = PPIDatabaseGridStatus.loading;

  const PPIDatabaseGridState.loaded(this.ppis, this.additionalColumns, this.selectedPPI)
      : status = PPIDatabaseGridStatus.loaded;

  const PPIDatabaseGridState.selected(this.ppis, this.additionalColumns, this.selectedPPI)
      : status = PPIDatabaseGridStatus.selected;

  @override
  List<Object?> get props => [ppis, selectedPPI, status];
}

enum PPIDatabaseGridStatus { initial, loading, loaded, selected }

class PPIDatabaseGridBloc extends Bloc<PPIDatabaseGridEvent, PPIDatabaseGridState> {
  final PPIRepository _ppiRepository;

  PPIDatabaseGridBloc(this._ppiRepository) : super(const PPIDatabaseGridState.initial()) {
    on<PPIDatabaseGridLoadEvent>((event, emit) async {
      emit(PPIDatabaseGridState.loading(state.ppis, state.additionalColumns, state.selectedPPI));
      List<ProteinProteinInteraction> ppis = _ppiRepository.databaseToList();
      Set<String>? additionalColumns = _ppiRepository.getAllCustomAttributeKeys();
      emit(PPIDatabaseGridState.loaded(ppis, additionalColumns, state.selectedPPI));
    });

    on<PPIDatabaseGridSelectionEvent>((event, emit) async {
      int? rowIndex = event.selectedEvent!.rowIdx;
      if (rowIndex != null) {
        ProteinProteinInteraction? selectedPPI = _ppiRepository.getEntityByRow(rowIndex);
        emit(PPIDatabaseGridState.selected(state.ppis, state.additionalColumns, selectedPPI));
      }
    });
  }
}
