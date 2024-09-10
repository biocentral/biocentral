import 'package:bio_flutter/bio_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../domain/protein_repository.dart';

sealed class ProteinDatabaseGridEvent {
  PlutoGridOnSelectedEvent? selectedEvent;

  ProteinDatabaseGridEvent({this.selectedEvent});
}

final class ProteinDatabaseGridLoadEvent extends ProteinDatabaseGridEvent {
  ProteinDatabaseGridLoadEvent();
}

final class ProteinDatabaseGridSelectionEvent extends ProteinDatabaseGridEvent {
  ProteinDatabaseGridSelectionEvent({required super.selectedEvent});
}

@immutable
final class ProteinDatabaseGridState extends Equatable {
  final List<Protein> proteins;
  final Set<String>? additionalColumns;
  final Protein? selectedProtein;
  final ProteinDatabaseGridStatus status;

  const ProteinDatabaseGridState(this.proteins, this.additionalColumns, this.selectedProtein, this.status);

  const ProteinDatabaseGridState.initial()
      : proteins = const [],
        additionalColumns = const {},
        selectedProtein = null,
        status = ProteinDatabaseGridStatus.initial;

  const ProteinDatabaseGridState.loading(this.proteins, this.additionalColumns, this.selectedProtein)
      : status = ProteinDatabaseGridStatus.loading;

  const ProteinDatabaseGridState.loaded(this.proteins, this.additionalColumns, this.selectedProtein)
      : status = ProteinDatabaseGridStatus.loaded;

  const ProteinDatabaseGridState.selected(this.proteins, this.additionalColumns, this.selectedProtein)
      : status = ProteinDatabaseGridStatus.selected;

  @override
  List<Object?> get props => [proteins, selectedProtein, status];
}

enum ProteinDatabaseGridStatus { initial, loading, loaded, selected }

class ProteinDatabaseGridBloc extends Bloc<ProteinDatabaseGridEvent, ProteinDatabaseGridState> {
  final ProteinRepository _proteinRepository;

  ProteinDatabaseGridBloc(this._proteinRepository) : super(const ProteinDatabaseGridState.initial()) {
    on<ProteinDatabaseGridLoadEvent>((event, emit) async {
      emit(ProteinDatabaseGridState.loading(state.proteins, state.additionalColumns, state.selectedProtein));
      List<Protein> proteins = _proteinRepository.databaseToList();
      // TODO Should be extended to all attributes not only those available for all proteins
      Set<String>? additionalColumns = _proteinRepository.getAllCustomAttributeKeys();
      emit(ProteinDatabaseGridState.loaded(proteins, additionalColumns, state.selectedProtein));
    });

    on<ProteinDatabaseGridSelectionEvent>((event, emit) async {
      int? rowIndex = event.selectedEvent!.rowIdx;
      if (rowIndex != null) {
        Protein? selectedProtein = _proteinRepository.getEntityByRow(rowIndex);
        emit(ProteinDatabaseGridState.selected(state.proteins, state.additionalColumns, selectedProtein));
      }
    });
  }
}
