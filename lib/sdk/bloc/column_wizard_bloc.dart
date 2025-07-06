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

  // TODO Could merge columnWizards and temporaryOperationHistory
  final Map<String, List<ColumnWizardHistoryEntry>>? columnWizardHistory;
  final Widget Function(ColumnWizard)? customBuildFunction;
  final String? selectedColumn;
  final ColumnOperationType? selectedOperationType;

  final ColumnWizardBlocStatus status;

  const ColumnWizardBlocState(
    this.columns,
    this.columnWizardHistory,
    this.customBuildFunction,
    this.selectedColumn,
    this.selectedOperationType,
    this.status,
  );

  const ColumnWizardBlocState.initial()
      : columns = const {},
        customBuildFunction = null,
        columnWizardHistory = null,
        selectedColumn = null,
        selectedOperationType = null,
        status = ColumnWizardBlocStatus.initial;

  ColumnWizard? get columnWizard => columnWizardHistory?[selectedColumn]?.lastOrNull?.resultWizard;

  @override
  List<Object?> get props => [
        columns,
        columnWizardHistory,
        customBuildFunction,
        selectedColumn,
        selectedOperationType,
        status
      ];

  ColumnWizardBlocState copyWith({Map<String, dynamic>? copyMap}) {
    return ColumnWizardBlocState(
      copyMapExtractor(copyMap, 'columns', columns),
      copyMapExtractor(copyMap, 'columnWizardHistory', columnWizardHistory),
      copyMapExtractor(copyMap, 'customBuildFunction', customBuildFunction),
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
      final columnWizardHistory = state.columnWizardHistory ?? {};
      Widget Function(ColumnWizard)? customBuildFunction;  // TODO

      ColumnWizard? columnWizard = state.columnWizard;
      if (columnWizard == null) {
        columnWizard = await _columnWizardRepository.getColumnWizardForColumn(
          columnName: event.selectedColumn,
          valueMap: state.columns[event.selectedColumn] ?? {},
        );
        columnWizardHistory.putIfAbsent(event.selectedColumn, () => []);
        columnWizardHistory[event.selectedColumn]?.add(ColumnWizardHistoryEntry(columnWizard, null));
      }
      customBuildFunction = _columnWizardRepository.getCustomBuildFunctionForColumnWizard(columnWizard);

      emit(
        state.copyWith(
          copyMap: {
            'selectedColumn': event.selectedColumn,
            'columnWizardHistory': columnWizardHistory,
            'customBuildFunction': customBuildFunction,
            'status': ColumnWizardBlocStatus.selected,
          },
        ),
      );
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

      final updatedHistory = Map<String, List<ColumnWizardHistoryEntry>>.from(state.columnWizardHistory ?? {});
      updatedHistory.putIfAbsent(state.selectedColumn!, () => []);
      updatedHistory[state.selectedColumn!]
          ?.add(ColumnWizardHistoryEntry(updatedColumnWizard, event.columnWizardOperation));
      emit(
        state.copyWith(
          copyMap: {'columnWizardHistory': updatedHistory, 'status': ColumnWizardBlocStatus.calculated},
        ),
      );
      // Save queue of operations
      // DISPLAY => History => Undo
      // Only in the end apply to dataset and log
    });
  }
}
