import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../domain/embeddings_repository.dart';
import '../model/embeddings_column_wizard.dart';

mixin class CalculateUMAPDialogEvent {}

class CalculateUMAPDialogSelectEntityTypeEvent with CalculateUMAPDialogEvent {
  final Type? selectedEntityType;

  CalculateUMAPDialogSelectEntityTypeEvent(this.selectedEntityType);
}

class CalculateUMAPDialogUpdateUIEvent extends BiocentralSimpleMultiTypeUIUpdateEvent with CalculateUMAPDialogEvent {
  CalculateUMAPDialogUpdateUIEvent(super.updates);
}

@immutable
final class CalculateUMAPDialogState extends BiocentralSimpleMultiTypeUIState<CalculateUMAPDialogState> {
  final EmbeddingsColumnWizard? embeddingsColumnWizard;

  final String? selectedEmbedderName;
  final EmbeddingType? selectedEmbeddingType;
  final DatabaseImportMode? selectedImportMode;
  final CalculateUMAPDialogStatus status;

  const CalculateUMAPDialogState(this.embeddingsColumnWizard, this.selectedEmbedderName, this.selectedEmbeddingType,
      this.selectedImportMode, this.status);

  const CalculateUMAPDialogState.initial()
      : embeddingsColumnWizard = null,
        selectedEmbedderName = null,
        selectedEmbeddingType = null,
        selectedImportMode = null,
        status = CalculateUMAPDialogStatus.initial;

  const CalculateUMAPDialogState.selected(
      this.embeddingsColumnWizard, this.selectedEmbedderName, this.selectedEmbeddingType, this.selectedImportMode)
      : status = CalculateUMAPDialogStatus.selected;

  CalculateUMAPDialogState withEmbeddingsColumnWizard(EmbeddingsColumnWizard newEmbColumnWizard) {
    return CalculateUMAPDialogState(
        newEmbColumnWizard, selectedEmbedderName, selectedEmbeddingType, selectedImportMode, status);
  }

  @override
  List<Object?> get props => [selectedEmbedderName, selectedEmbeddingType, selectedImportMode, status];

  @override
  CalculateUMAPDialogState updateFromUIEvent(BiocentralSimpleMultiTypeUIUpdateEvent event) {
    if (embeddingsColumnWizard == null) {
      return const CalculateUMAPDialogState.initial();
    }
    return CalculateUMAPDialogState.selected(embeddingsColumnWizard, getValueFromEvent(selectedEmbedderName, event),
        getValueFromEvent(selectedEmbeddingType, event), getValueFromEvent(selectedImportMode, event));
  }
}

enum CalculateUMAPDialogStatus { initial, selected }

class CalculateUMAPDialogBloc extends Bloc<CalculateUMAPDialogEvent, CalculateUMAPDialogState> {
  final EmbeddingsRepository _embeddingsRepository;

  CalculateUMAPDialogBloc(this._embeddingsRepository) : super(const CalculateUMAPDialogState.initial()) {
    on<CalculateUMAPDialogSelectEntityTypeEvent>((event, emit) async {
      EmbeddingsColumnWizard? embeddingsColumnWizard =
          _embeddingsRepository.getEmbeddingsColumnWizardByType(event.selectedEntityType);
      if (embeddingsColumnWizard != null) {
        emit(state.withEmbeddingsColumnWizard(embeddingsColumnWizard));
      }
    });
    on<CalculateUMAPDialogUpdateUIEvent>((event, emit) async {
      emit(state.updateFromUIEvent(event));
    });
  }
}
