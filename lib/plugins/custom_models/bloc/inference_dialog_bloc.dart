import 'package:biocentral/plugins/custom_models/domain/prediction_model_repository.dart';
import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class InferenceDialogEvent {}

final class InferenceDialogLoadEvent extends InferenceDialogEvent {}

final class InferenceDialogSelectModelEvent extends InferenceDialogEvent {
  final PredictionModel selectedModel;

  InferenceDialogSelectModelEvent(this.selectedModel);
}

final class InferenceDialogSelectEntitiesEvent extends InferenceDialogEvent {
  final Set<String> selectedEntityIDs;

  InferenceDialogSelectEntitiesEvent(this.selectedEntityIDs);
}

@immutable
final class InferenceDialogState extends Equatable {
  final Set<PredictionModel> availableModels;
  final Set<String> availableEntityIDs;
  final PredictionModel? selectedModel;
  final Set<String> selectedEntityIDs;

  const InferenceDialogState(
    this.availableModels,
    this.availableEntityIDs,
    this.selectedModel,
    this.selectedEntityIDs,
  );

  const InferenceDialogState.initial()
      : availableModels = const {},
        availableEntityIDs = const {},
        selectedModel = null,
        selectedEntityIDs = const {};

  const InferenceDialogState.loaded(this.availableModels, this.selectedModel)
      : availableEntityIDs = const {},
        selectedEntityIDs = const {};

  InferenceDialogState withHierarchy(InferenceDialogState oldState) {
    // APPLY STATE CONFIGURATION LOGIC
    if (selectedModel == null) {
      return InferenceDialogState.loaded(availableModels, selectedModel);
    }
    return this;
  }

  @override
  List<Object?> get props => [
        availableModels,
        availableEntityIDs,
        selectedModel,
        selectedEntityIDs,
      ];
}

class InferenceDialogBloc extends Bloc<InferenceDialogEvent, InferenceDialogState> {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final CustomModelRepository _predictionModelRepository;

  InferenceDialogBloc(this._biocentralDatabaseRepository, this._predictionModelRepository)
      : super(const InferenceDialogState.initial()) {
    on<InferenceDialogLoadEvent>((event, emit) async {
      final availableModels =
          _predictionModelRepository.predictionModelsToList().where((model) => model.modelHash != null).toSet();
      final selectedModel = state.selectedModel ?? availableModels.firstOrNull;
      if(selectedModel != null) {
        emit(InferenceDialogState.loaded(availableModels, selectedModel));
        _changeModelSelection(selectedModel, emit);
      }
    });

    on<InferenceDialogSelectModelEvent>((event, emit) async {
      final selectedModel = event.selectedModel;

      _changeModelSelection(selectedModel, emit);
    });
    on<InferenceDialogSelectEntitiesEvent>((event, emit) async {
      final selectedEntityIDs = event.selectedEntityIDs;
      emit(
        InferenceDialogState(state.availableModels, state.availableEntityIDs, state.selectedModel, selectedEntityIDs)
            .withHierarchy(state),
      );
    });
  }

  void _changeModelSelection(PredictionModel selectedModel, dynamic emit) {
    final databaseType = _biocentralDatabaseRepository.getAvailableTypes()[selectedModel.databaseType];
    final database = _biocentralDatabaseRepository.getFromType(databaseType);
    if (database == null) {
      // TODO Error Handling
      return;
    }

    final availableEntityIDs = database.databaseToMap().keys.toSet();
    final selectedEntityIDs = Set<String>.from(availableEntityIDs); // Select all ids initially
    emit(
      InferenceDialogState(state.availableModels, availableEntityIDs, selectedModel, selectedEntityIDs)
          .withHierarchy(state),
    );
  }
}
