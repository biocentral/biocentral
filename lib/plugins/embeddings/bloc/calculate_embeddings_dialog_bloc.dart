import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';

mixin class CalculateEmbeddingsDialogEvent {}

class CalculateEmbeddingsDialogUpdateUIEvent extends BiocentralSimpleMultiTypeUIUpdateEvent
    with CalculateEmbeddingsDialogEvent {
  CalculateEmbeddingsDialogUpdateUIEvent(super.updates);
}

@immutable
final class CalculateEmbeddingsDialogState extends BiocentralSimpleMultiTypeUIState<CalculateEmbeddingsDialogState> {
  final PredefinedEmbedder? selectedEmbedder;
  final EmbeddingType? selectedEmbeddingType;
  final DatabaseImportMode? selectedImportMode;
  final CalculateEmbeddingsDialogStatus status;

  const CalculateEmbeddingsDialogState(
      this.selectedEmbedder, this.selectedEmbeddingType, this.selectedImportMode, this.status,);

  const CalculateEmbeddingsDialogState.initial()
      : selectedEmbedder = null,
        selectedEmbeddingType = null,
        selectedImportMode = null,
        status = CalculateEmbeddingsDialogStatus.initial;

  const CalculateEmbeddingsDialogState.selected(
      this.selectedEmbedder, this.selectedEmbeddingType, this.selectedImportMode,)
      : status = CalculateEmbeddingsDialogStatus.selected;

  @override
  List<Object?> get props => [selectedEmbedder, selectedEmbeddingType, selectedImportMode, status];

  @override
  CalculateEmbeddingsDialogState updateFromUIEvent(BiocentralSimpleMultiTypeUIUpdateEvent event) {
    return CalculateEmbeddingsDialogState.selected(getValueFromEvent(selectedEmbedder, event),
        getValueFromEvent(selectedEmbeddingType, event), getValueFromEvent(selectedImportMode, event),);
  }
}

enum CalculateEmbeddingsDialogStatus { initial, selected }

class CalculateEmbeddingsDialogBloc extends Bloc<CalculateEmbeddingsDialogEvent, CalculateEmbeddingsDialogState> {
  CalculateEmbeddingsDialogBloc() : super(const CalculateEmbeddingsDialogState.initial()) {
    on<CalculateEmbeddingsDialogUpdateUIEvent>((event, emit) async {
      emit(state.updateFromUIEvent(event));
    });
  }
}
