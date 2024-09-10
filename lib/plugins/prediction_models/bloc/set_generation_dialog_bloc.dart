import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import '../model/set_generator.dart';
import 'prediction_model_events.dart';

sealed class SetGenerationDialogEvent {}

final class SetGenerationDialogSelectDatabaseTypeEvent extends SetGenerationDialogEvent {
  final Type selectedDatabaseType;

  SetGenerationDialogSelectDatabaseTypeEvent(this.selectedDatabaseType);
}

final class SetGenerationDialogSelectMethodEvent extends SetGenerationDialogEvent {
  final SplitSetGenerationMethod? selectedMethod;

  SetGenerationDialogSelectMethodEvent(this.selectedMethod);
}

final class SetGenerationDialogCalculateEvent extends SetGenerationDialogEvent {
  SetGenerationDialogCalculateEvent();
}

@immutable
final class SetGenerationDialogState extends BiocentralCommandState<SetGenerationDialogState> {
  final Set<SplitSetGenerationMethod> availableMethods;
  final Type? selectedDatabaseType;
  final SplitSetGenerationMethod? selectedMethod;

  final SetGenerationDialogStep currentStep;

  const SetGenerationDialogState(super.stateInformation, super.status, this.availableMethods, this.selectedDatabaseType,
      this.selectedMethod, this.currentStep);

  const SetGenerationDialogState.idle()
      : availableMethods = const {},
        selectedDatabaseType = null,
        selectedMethod = null,
        currentStep = SetGenerationDialogStep.initial,
        super.idle();

  @override
  SetGenerationDialogState newState(
      BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return SetGenerationDialogState(
        stateInformation, status, availableMethods, selectedDatabaseType, selectedMethod, currentStep);
  }

  @override
  SetGenerationDialogState copyWith({required Map<String, dynamic> copyMap}) {
    return SetGenerationDialogState(
        stateInformation,
        status,
        copyMap["availableMethods"] ?? availableMethods,
        copyMap["selectedDatabaseType"] ?? selectedDatabaseType,
        copyMap["selectedMethod"] ?? selectedMethod,
        copyMap["currentStep"] ?? currentStep);
  }

  @override
  List<Object?> get props =>
      [stateInformation, status, availableMethods, selectedDatabaseType, selectedMethod, currentStep];
}

enum SetGenerationDialogStep {
  initial,
  selectedDatabaseType,
  loadedMethods,
  selectedMethod,
}

class SetGenerationDialogBloc extends BiocentralBloc<SetGenerationDialogEvent, SetGenerationDialogState> {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final EventBus _eventBus;

  SetGenerationDialogBloc(this._biocentralDatabaseRepository, this._eventBus)
      : super(const SetGenerationDialogState.idle(), _eventBus) {
    on<SetGenerationDialogSelectDatabaseTypeEvent>((event, emit) async {
      emit(state.setOperating(information: "Loading available methods..").copyWith(copyMap: {
        "selectedDatabaseType": event.selectedDatabaseType,
        "currentStep": SetGenerationDialogStep.selectedDatabaseType
      }));

      // TODO Load from server
      Set<SplitSetGenerationMethod> availableMethods = {SplitSetGenerationMethod.random};
      emit(state.setIdle(information: "Finished loading available methods!").copyWith(
          copyMap: {"availableMethods": availableMethods, "currentStep": SetGenerationDialogStep.loadedMethods}));
    });
    on<SetGenerationDialogSelectMethodEvent>((event, emit) async {
      emit(state.copyWith(
          copyMap: {"selectedMethod": event.selectedMethod, "currentStep": SetGenerationDialogStep.selectedMethod}));
    });
    on<SetGenerationDialogCalculateEvent>((event, emit) async {
      if (state.selectedMethod == null) {
        emit(state.setErrored(information: "No selected method to calculate sets!"));
      } else {
        // TODO SET NAMES
        SplitSetGenerationMethod method = state.selectedMethod!;

        emit(state.setOperating(information: "Calculating sets with method $method.."));

        BiocentralDatabase? database = _biocentralDatabaseRepository.getFromType(state.selectedDatabaseType);

        if (database == null) {
          emit(state.setErrored(information: "Could not find database to calculate sets!"));
        } else {
          Map<String, SplitSet> ids = SetGenerator.holdOut(train: 0.8, validation: 0.1, test: 0.1)
              .splitByMethod(method, database.databaseToMap().keys.toList());
          String columnName = "SET_${method.name.toUpperCase()}";
          await database.addCustomAttribute(columnName, ids.map((key, value) => MapEntry(key, value.name)));
          _eventBus.fire(SetGeneratedEvent(columnName: columnName));
          _eventBus.fire(BiocentralDatabaseUpdatedEvent());
          emit(state.setFinished(information: "Finished calculating sets!"));
        }
      }
    });
  }
}
