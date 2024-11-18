import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:equatable/equatable.dart';
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
final class ColumnWizardBlocState extends Equatable {
  final Map<String, Map<String, dynamic>> columns;

  final Map<String, ColumnWizard>? columnWizards;
  final Widget Function(ColumnWizard)? customBuildFunction;
  final String? selectedColumn;
  final ColumnOperationType? selectedOperationType;

  final ColumnWizardBlocStatus status;

  const ColumnWizardBlocState(
    this.columns,
    this.columnWizards,
    this.customBuildFunction,
    this.selectedColumn,
    this.selectedOperationType,
    this.status,
  );

  const ColumnWizardBlocState.initial()
      : columns = const {},
        customBuildFunction = null,
        columnWizards = null,
        selectedColumn = null,
        selectedOperationType = null,
        status = ColumnWizardBlocStatus.initial;

  ColumnWizard? get columnWizard => columnWizards?[selectedColumn];

  @override
  List<Object?> get props =>
      [columns, columnWizards, customBuildFunction, selectedColumn, selectedOperationType, status];

  ColumnWizardBlocState copyWith({Map<String, dynamic>? copyMap}) {
    return ColumnWizardBlocState(
      copyMapExtractor(copyMap, 'columns', columns),
      copyMapExtractor(copyMap, 'columnWizards', columnWizards),
      copyMapExtractor(copyMap, 'customBuildFunction', customBuildFunction),
      copyMapExtractor(copyMap, 'selectedColumn', selectedColumn),
      copyMapExtractor(copyMap, 'selectedOperationType', selectedOperationType),
      copyMapExtractor(copyMap, 'status', status),
    );
  }
}

enum ColumnWizardBlocStatus { initial, loading, loaded, selected }

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
      final Map<String, ColumnWizard> columnWizards = state.columnWizards ?? {};
      Widget Function(ColumnWizard)? customBuildFunction;

      ColumnWizard? columnWizard = columnWizards[event.selectedColumn];
      if (columnWizard == null) {
        columnWizard = await _columnWizardRepository.getColumnWizardForColumn(
          columnName: event.selectedColumn,
          valueMap: state.columns[event.selectedColumn] ?? {},
        );
        columnWizards[event.selectedColumn] = columnWizard;
      }
      customBuildFunction = _columnWizardRepository.getCustomBuildFunctionForColumnWizard(columnWizard);

      emit(
        state.copyWith(
          copyMap: {
            'selectedColumn': event.selectedColumn,
            'columnWizards': columnWizards,
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
  }
}
