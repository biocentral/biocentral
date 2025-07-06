import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ColumnWizardEvent {}

final class ColumnWizardLoadEvent extends ColumnWizardEvent {}

final class ColumnWizardSelectColumnEvent extends ColumnWizardEvent {
  final String selectedColumn;

  ColumnWizardSelectColumnEvent(this.selectedColumn);
}

final class ColumnWizardSelectOperationEvent extends ColumnWizardEvent {
  final ColumnOperationType selectedOperationType;

  ColumnWizardSelectOperationEvent(this.selectedOperationType);
}

final class ColumnWizardCalculateEvent extends ColumnWizardEvent {
  final ColumnWizardOperation columnWizardOperation;

  ColumnWizardCalculateEvent(this.columnWizardOperation);
}

@immutable
final class ColumnWizardHistoryEntry {
  final ColumnWizard resultWizard;
  final ColumnWizardOperation? operation;

  const ColumnWizardHistoryEntry(this.resultWizard, this.operation);
}

@immutable
final class ColumnWizardBlocState extends Equatable {
  final Map<String, Map<String, dynamic>> columns;

  final Map<String, List<ColumnWizardHistoryEntry>>? columnWizardHistory;

  // TODO Maybe refactor buildFunction directly into column wizard
  final Map<Type, Widget Function(ColumnWizard)?>? customBuildFunctions;
  final String? selectedColumn;
  final ColumnOperationType? selectedOperationType;

  final ColumnWizardBlocStatus status;

  const ColumnWizardBlocState(
    this.columns,
    this.columnWizardHistory,
    this.customBuildFunctions,
    this.selectedColumn,
    this.selectedOperationType,
    this.status,
  );

  const ColumnWizardBlocState.initial()
      : columns = const {},
        customBuildFunctions = null,
        columnWizardHistory = null,
        selectedColumn = null,
        selectedOperationType = null,
        status = ColumnWizardBlocStatus.initial;

  ColumnWizard? get columnWizard => columnWizardHistory?[selectedColumn]?.lastOrNull?.resultWizard;

  @override
  List<Object?> get props =>
      [columns, columnWizardHistory, customBuildFunctions, selectedColumn, selectedOperationType, status];

  ColumnWizardBlocState copyWith({Map<String, dynamic>? copyMap}) {
    return ColumnWizardBlocState(
      copyMapExtractor(copyMap, 'columns', columns),
      copyMapExtractor(copyMap, 'columnWizardHistory', columnWizardHistory),
      copyMapExtractor(copyMap, 'customBuildFunctions', customBuildFunctions),
      copyMapExtractor(copyMap, 'selectedColumn', selectedColumn),
      copyMapExtractor(copyMap, 'selectedOperationType', selectedOperationType),
      copyMapExtractor(copyMap, 'status', status),
    );
  }
}

enum ColumnWizardBlocStatus { initial, loading, loaded, selected, calculating, calculated }

class ColumnWizardBloc extends Bloc<ColumnWizardEvent, ColumnWizardBlocState> {
  final BiocentralDatabase _biocentralDatabase;
  final BiocentralColumnWizardRepository _columnWizardRepository;

  ColumnWizardBloc(this._biocentralDatabase, this._columnWizardRepository)
      : super(const ColumnWizardBlocState.initial()) {
    on<ColumnWizardLoadEvent>((event, emit) async {
      emit(const ColumnWizardBlocState.initial().copyWith(copyMap: {'status': ColumnWizardBlocStatus.loading}));
      final Map<String, Map<String, dynamic>> columns = _biocentralDatabase.getColumns();
      emit(state.copyWith(copyMap: {'columns': columns, 'status': ColumnWizardBlocStatus.loaded}));
    });
    on<ColumnWizardSelectColumnEvent>((event, emit) async {
      emit(
        state.copyWith(
          copyMap: {
            'selectedColumn': event.selectedColumn,
          },
        ),
      );

      ColumnWizard? columnWizard = state.columnWizard;
      if (columnWizard == null) {
        columnWizard = await _columnWizardRepository.getColumnWizardForColumn(
          columnName: event.selectedColumn,
          valueMap: state.columns[event.selectedColumn] ?? {},
        );
        final (columnWizardHistory, customBuildFunctions) = _addNewColumnWizard(columnWizard, null);
        emit(
          state.copyWith(
            copyMap: {
              'columnWizardHistory': columnWizardHistory,
              'customBuildFunctions': customBuildFunctions,
              'status': ColumnWizardBlocStatus.selected,
            },
          ),
        );
      }
    });
    on<ColumnWizardSelectOperationEvent>((event, emit) async {
      emit(
        state.copyWith(
          copyMap: {'selectedOperationType': event.selectedOperationType, 'status': ColumnWizardBlocStatus.selected},
        ),
      );
    });

    on<ColumnWizardCalculateEvent>((event, emit) async {
      final ColumnWizard? columnWizardToOperate = state.columnWizard;
      if (columnWizardToOperate == null) {
        // TODO Error Handling
        return;
      }

      emit(
        state.copyWith(copyMap: {'status': ColumnWizardBlocStatus.calculating}),
      );

      final ColumnWizardOperationResult result = await compute(
        event.columnWizardOperation.operate,
        columnWizardToOperate,
      );

      // TODO Should type be added here?
      // TODO columnName
      final updatedColumnWizard = await _columnWizardRepository.getColumnWizardForColumn(
          columnName: state.selectedColumn ?? "", valueMap: result.newColumnValues);

      final (columnWizardHistory, customBuildFunctions) =
          _addNewColumnWizard(updatedColumnWizard, event.columnWizardOperation);
      emit(
        state.copyWith(
          copyMap: {
            'columnWizardHistory': columnWizardHistory,
            'customBuildFunctions': customBuildFunctions,
            'status': ColumnWizardBlocStatus.selected,
          },
        ),
      );
      // Save queue of operations
      // DISPLAY => History => Undo
      // Only in the end apply to dataset and log
    });
  }

  (Map, Map) _addNewColumnWizard(ColumnWizard columnWizard, ColumnWizardOperation? operation) {
    final columnWizardHistory = state.columnWizardHistory ?? {};
    final Map<Type, Widget Function(ColumnWizard)?> customBuildFunctions = state.customBuildFunctions ?? {};
    columnWizardHistory.putIfAbsent(columnWizard.columnName, () => []);
    columnWizardHistory[columnWizard.columnName]?.add(ColumnWizardHistoryEntry(columnWizard, operation));

    customBuildFunctions.putIfAbsent(columnWizard.type, () => null);
    customBuildFunctions[columnWizard.type] =
        _columnWizardRepository.getCustomBuildFunctionForColumnWizard(columnWizard);

    return (columnWizardHistory, customBuildFunctions);
  }
}
