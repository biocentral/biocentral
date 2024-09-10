import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/biocentral_column_wizard_repository.dart';
import '../domain/biocentral_database.dart';
import '../model/column_wizard_abstract.dart';
import '../model/column_wizard_operations.dart';

sealed class ColumnWizardDialogEvent {}

final class ColumnWizardDialogLoadEvent extends ColumnWizardDialogEvent {}

final class ColumnWizardDialogSelectColumnEvent extends ColumnWizardDialogEvent {
  final String selectedColumn;

  ColumnWizardDialogSelectColumnEvent(this.selectedColumn);
}

final class ColumnWizardDialogSelectOperationEvent extends ColumnWizardDialogEvent {
  final ColumnOperationType selectedOperationType;

  ColumnWizardDialogSelectOperationEvent(this.selectedOperationType);
}

final class ColumnWizardDialogCalculateEvent extends ColumnWizardDialogEvent {
  final ColumnWizardOperation columnWizardOperation;

  ColumnWizardDialogCalculateEvent(this.columnWizardOperation);
}

@immutable
final class ColumnWizardDialogState extends Equatable {
  final Map<String, Map<String, dynamic>> columns;

  final Map<String, ColumnWizard>? columnWizards;
  final String? selectedColumn;
  final ColumnOperationType? selectedOperationType;

  final ColumnWizardDialogStatus status;

  const ColumnWizardDialogState(
      this.columns, this.columnWizards, this.selectedColumn, this.selectedOperationType, this.status);

  const ColumnWizardDialogState.initial()
      : columns = const {},
        columnWizards = null,
        selectedColumn = null,
        selectedOperationType = null,
        status = ColumnWizardDialogStatus.initial;

  ColumnWizard? get columnWizard => columnWizards?[selectedColumn];

  @override
  List<Object?> get props => [columns, columnWizards?.keys, selectedColumn, selectedOperationType, status];

  ColumnWizardDialogState copyWith({Map<String, dynamic>? copyMap}) {
    return ColumnWizardDialogState(
        copyMap?["columns"] ?? columns,
        copyMap?["columnWizards"] ?? columnWizards,
        copyMap?["selectedColumn"] ?? selectedColumn,
        copyMap?["selectedOperationType"] ?? selectedOperationType,
        copyMap?["status"] ?? status);
  }
}

enum ColumnWizardDialogStatus { initial, loading, loaded, selected }

class ColumnWizardDialogBloc extends Bloc<ColumnWizardDialogEvent, ColumnWizardDialogState> {
  final BiocentralDatabase _biocentralDatabase;
  final BiocentralColumnWizardRepository _columnWizardRepository;

  ColumnWizardDialogBloc(this._biocentralDatabase, this._columnWizardRepository)
      : super(const ColumnWizardDialogState.initial()) {
    on<ColumnWizardDialogLoadEvent>((event, emit) async {
      emit(state.copyWith(copyMap: {"status": ColumnWizardDialogStatus.loading}));
      final Map<String, Map<String, dynamic>> columns = _biocentralDatabase.getColumns();
      emit(state.copyWith(copyMap: {"columns": columns, "status": ColumnWizardDialogStatus.loaded}));
    });
    on<ColumnWizardDialogSelectColumnEvent>((event, emit) async {
      emit(state.copyWith(copyMap: {"selectedColumn": event.selectedColumn}));
      Map<String, ColumnWizard> columnWizards = state.columnWizards ?? {};
      if (!columnWizards.containsKey(event.selectedColumn)) {
        ColumnWizard columnWizard = await _columnWizardRepository.getColumnWizardForColumn(
            columnName: event.selectedColumn, valueMap: state.columns[event.selectedColumn] ?? {});
        columnWizards[event.selectedColumn] = columnWizard;
      }
      emit(state.copyWith(copyMap: {"columnWizards": columnWizards, "status": ColumnWizardDialogStatus.selected}));
    });
    on<ColumnWizardDialogSelectOperationEvent>((event, emit) async {
      emit(state.copyWith(copyMap: {
        "selectedOperationType": event.selectedOperationType,
        "status": ColumnWizardDialogStatus.selected
      }));
    });
  }
}
