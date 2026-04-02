import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

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

class _ProteinDatabaseUpdatedInternalEvent extends ProteinDatabaseGridEvent {
  final Map<String, Protein> proteins;

  _ProteinDatabaseUpdatedInternalEvent(this.proteins);
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
    on<_ProteinDatabaseUpdatedInternalEvent>((event, emit) {
      final proteins = event.proteins.values.toList();
      final additionalColumns = _proteinRepository.getAllCustomAttributeKeys();

      emit(ProteinDatabaseGridState.loaded(
        proteins,
        additionalColumns,
        state.selectedProtein,
      ),);
    });

    _setupSubscription();

    on<ProteinDatabaseGridLoadEvent>((event, emit) async {
      // TODO Event is currently kept - can probably be removed
      add(_ProteinDatabaseUpdatedInternalEvent(_proteinRepository.databaseToMap()));
    });

    on<ProteinDatabaseGridSelectionEvent>((event, emit) async {
      final int? rowIndex = event.selectedEvent!.rowIdx;
      if (rowIndex != null) {
        final Protein? selectedProtein = _proteinRepository.getEntityByRow(rowIndex);
        emit(ProteinDatabaseGridState.selected(state.proteins, state.additionalColumns, selectedProtein));
      }
    });
  }

  void _setupSubscription() {
    // We use a private event to pipe stream changes back into the Bloc's event loop
    _proteinRepository.databaseStream.listen((proteins) {
      add(_ProteinDatabaseUpdatedInternalEvent(proteins));
    });
  }
}
