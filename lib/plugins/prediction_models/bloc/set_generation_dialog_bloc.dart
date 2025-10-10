import 'package:biocentral/plugins/prediction_models/bloc/prediction_model_events.dart';
import 'package:biocentral/plugins/prediction_models/model/set_generator.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_database_column.dart';
import 'package:biocentral/sdk/model/split_set.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

class SetGenerationSTO {
  // State Transfer Object
  Type? selectedDatabaseType;
  BiocentralDatabaseColumn? selectedSetColumn;
  SplitSetGenerationMode? mode;
  SplitSet? subsplitSource;
  SplitSet? subsplitTarget;
  SplitSetGenerationMethod? method;
  SplitRatio? splitRatio;

  SetGenerationSTO({
    this.selectedDatabaseType,
    this.selectedSetColumn,
    this.mode,
    this.subsplitSource,
    this.subsplitTarget,
    this.method,
    this.splitRatio,
  });

  SetGenerationSTO.empty();
}

sealed class SetGenerationDialogEvent {}

final class SetGenerationDialogUpdateEvent extends SetGenerationDialogEvent {
  final SetGenerationSTO stoUpdate;

  SetGenerationDialogUpdateEvent(this.stoUpdate);
}

final class SetGenerationDialogCalculateEvent extends SetGenerationDialogEvent {
  SetGenerationDialogCalculateEvent();
}

@immutable
final class SetGenerationDialogState extends BiocentralCommandState<SetGenerationDialogState> {
  final Set<SplitSetGenerationMethod> availableMethods;
  final Map<BiocentralDatabaseColumn, Set<SplitSet>> availableSourceSets;
  final Type? selectedDatabaseType;
  final int? selectedDatabaseLength;
  final SplitSetGenerationMode? mode;
  final BiocentralDatabaseColumn? selectedSetColumn;
  final SplitSet? subsplitSource;
  final SplitSet? subsplitTarget;
  final SplitSetGenerationMethod? method;
  final SplitRatio? splitRatio;

  const SetGenerationDialogState(
    super.stateInformation,
    super.status,
    this.availableMethods,
    this.selectedDatabaseType,
    this.selectedDatabaseLength,
    this.selectedSetColumn,
    this.availableSourceSets,
    this.mode,
    this.subsplitSource,
    this.subsplitTarget,
    this.method,
    this.splitRatio,
  );

  const SetGenerationDialogState.idle()
      : availableMethods = const {},
        selectedDatabaseType = null,
        selectedDatabaseLength = null,
        selectedSetColumn = null,
        availableSourceSets = const {},
        mode = null,
        subsplitSource = null,
        subsplitTarget = null,
        method = null,
        splitRatio = null,
        super.idle();

  @override
  SetGenerationDialogState newState(
    BiocentralCommandStateInformation stateInformation,
    BiocentralCommandStatus status,
  ) {
    return SetGenerationDialogState(
      stateInformation,
      status,
      availableMethods,
      selectedDatabaseType,
      selectedDatabaseLength,
      selectedSetColumn,
      availableSourceSets,
      mode,
      subsplitSource,
      subsplitTarget,
      method,
      splitRatio,
    );
  }

  @override
  SetGenerationDialogState copyWith({required Map<String, dynamic> copyMap}) {
    // TODO IGNORED AT THE MOMENT
    return SetGenerationDialogState(
      stateInformation,
      status,
      availableMethods,
      selectedDatabaseType,
      selectedDatabaseLength,
      selectedSetColumn,
      availableSourceSets,
      mode,
      subsplitSource,
      subsplitTarget,
      method,
      splitRatio,
    );
  }

  SetGenerationDialogState withHierarchy(SetGenerationDialogState oldState) {
    // APPLY STATE CONFIGURATION LOGIC
    if (selectedDatabaseType == null) {
      return const SetGenerationDialogState.idle();
    }
    if (mode == null || mode != oldState.mode) {
      return SetGenerationDialogState(
        stateInformation,
        status,
        availableMethods,
        selectedDatabaseType,
        selectedDatabaseLength,
        null,
        availableSourceSets,
        mode,
        null,
        null,
        null,
        null,
      );
    }
    BiocentralDatabaseColumn? selectedSetColumn = this.selectedSetColumn;
    SplitSet? subsplitSource = this.subsplitSource;
    SplitSet? subsplitTarget = this.subsplitTarget;
    SplitRatio? splitRatio = this.splitRatio;

    if (mode != SplitSetGenerationMode.subsplitExisting) {
      subsplitSource = null;
      subsplitTarget = null;
      selectedSetColumn = null;
    }
    if (selectedSetColumn == null) {
      subsplitSource = null;
      subsplitTarget = null;
    }
    if (subsplitSource == null) {
      subsplitTarget = null;
    }
    if (method == null) {
      splitRatio = null;
    }
    if (mode != null && method != null) {
      splitRatio ??= SplitRatio.defaultForMode(mode!);
      ;
    }
    return SetGenerationDialogState(
      stateInformation,
      status,
      availableMethods,
      selectedDatabaseType,
      selectedDatabaseLength,
      selectedSetColumn,
      availableSourceSets,
      mode,
      subsplitSource,
      subsplitTarget,
      method,
      splitRatio,
    );
  }

  @override
  List<Object?> get props => [
        stateInformation,
        status,
        availableMethods,
        selectedDatabaseType,
        selectedSetColumn,
        availableSourceSets,
        mode,
        subsplitSource,
        subsplitTarget,
        method,
        splitRatio
      ];

  Set<SplitSet> get availableSplitSetsForSelection => availableSourceSets[selectedSetColumn] ?? {};
}

class SetGenerationDialogBloc extends BiocentralBloc<SetGenerationDialogEvent, SetGenerationDialogState> {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final EventBus _eventBus;

  SetGenerationDialogBloc(this._biocentralDatabaseRepository, this._eventBus)
      : super(const SetGenerationDialogState.idle(), _eventBus) {
    on<SetGenerationDialogUpdateEvent>((event, emit) async {
      Set<BiocentralDatabaseColumn>? existingSetColumns;
      final Set<SplitSetGenerationMethod> availableMethods = {SplitSetGenerationMethod.random};
      Map<BiocentralDatabaseColumn, Set<SplitSet>>? availableSourceSets;
      int? selectedDatabaseLength;

      if (event.stoUpdate.selectedDatabaseType != null &&
          event.stoUpdate.selectedDatabaseType != state.selectedDatabaseType) {
        final BiocentralDatabase? database =
            _biocentralDatabaseRepository.getFromType(event.stoUpdate.selectedDatabaseType);

        if (database != null) {
          existingSetColumns = database.getAvailableSetColumnsForAllEntities();
          selectedDatabaseLength = database.databaseToList().length;
        }

        existingSetColumns ??= {};

        // Get available sets from the selected column for subsplitting
        availableSourceSets = Map.fromEntries(
          existingSetColumns
              .map((column) => MapEntry(column, column.detectSplitSets()))
              .where((entry) => entry.value.length <= 2),
        );
      }

      emit(
        SetGenerationDialogState(
          state.stateInformation,
          state.status,
          availableMethods,
          event.stoUpdate.selectedDatabaseType ?? state.selectedDatabaseType,
          selectedDatabaseLength ?? state.selectedDatabaseLength,
          event.stoUpdate.selectedSetColumn ?? state.selectedSetColumn,
          availableSourceSets ?? state.availableSourceSets,
          event.stoUpdate.mode ?? state.mode,
          event.stoUpdate.subsplitSource ?? state.subsplitSource,
          event.stoUpdate.subsplitTarget ?? state.subsplitTarget,
          event.stoUpdate.method ?? state.method,
          event.stoUpdate.splitRatio ?? state.splitRatio,
        ).withHierarchy(state),
      );
    });

    on<SetGenerationDialogCalculateEvent>((event, emit) async {
      final BiocentralDatabase? database = _biocentralDatabaseRepository.getFromType(state.selectedDatabaseType);

      if (database == null) {
        return emit(state.setErrored(information: 'Could not find database to calculate sets!'));
      }

      if (state.mode == SplitSetGenerationMode.generateNew) {
        if (state.method == null || state.splitRatio == null) {
          return emit(state.setErrored(information: 'No selected method to calculate sets!'));
        }

        final SplitSetGenerationMethod method = state.method!;
        emit(state.setOperating(information: 'Calculating sets with method $method..'));

        final Map<String, SplitSet> ids = SetGenerator(splitRatio: state.splitRatio!)
            .splitByMethod(method: method, ids: database.databaseToMap().keys.toList());
        final String columnName = 'SET_${method.name.toUpperCase()}';
        await database.addCustomAttribute(columnName, ids.map((key, value) => MapEntry(key, value.name)));
        _eventBus.fire(SetGeneratedEvent(columnName: columnName));
        _eventBus.fire(BiocentralDatabaseUpdatedEvent());
        emit(state.setFinished(information: 'Finished calculating sets!'));
      } else {
        // Subsplit mode
        if (state.selectedSetColumn == null ||
            state.subsplitSource == null ||
            state.subsplitTarget == null ||
            state.method == null ||
            state.splitRatio == null) {
          return emit(state.setErrored(information: 'Missing configuration for subsplit!'));
        }

        emit(state.setOperating(information: 'Creating subsplit...'));

        final String sourceColumnName = state.selectedSetColumn!.name;
        final SplitSet subsplitSource = state.subsplitSource!;
        final SplitSet subsplitTarget = state.subsplitTarget!;
        final SplitRatio splitRatio = state.splitRatio!;

        final existingIds = state.selectedSetColumn!.ids;
        final Map<String, SplitSet> subsplitResult = SetGenerator(splitRatio: splitRatio).splitByMethod(
          method: state.method!,
          ids: existingIds,
          subsplitSource: subsplitSource,
          subsplitTarget: subsplitTarget,
        );

        // TODO This adds the remaining sets values to the subsplit
        subsplitResult.addAll(
          Map.fromEntries(
            state.selectedSetColumn!.values.entries
                .where((entry) =>
                    entry.value.toString() != subsplitSource.name && entry.value.toString() != subsplitTarget.name)
                .map(
                  (entry) => MapEntry(
                    entry.key,
                    SplitSet.values.firstWhere((splitVal) => splitVal.name == entry.value.toString()),
                  ),
                ),
          ),
        );

        final String newColumnName = '${sourceColumnName}_SUBSPLIT';
        await database.addCustomAttribute(newColumnName, subsplitResult.map((key, value) => MapEntry(key, value.name)));
        _eventBus.fire(SetGeneratedEvent(columnName: newColumnName));
        _eventBus.fire(BiocentralDatabaseUpdatedEvent());
        emit(state.setFinished(information: 'Finished creating subsplit!'));
      }
    });
  }
}
