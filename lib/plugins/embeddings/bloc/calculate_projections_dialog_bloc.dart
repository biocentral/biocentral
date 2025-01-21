import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_client.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/model/biocentral_config_option.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

mixin class CalculateProjectionsDialogEvent {}

class CalculateProjectionsDialogGetConfigEvent with CalculateProjectionsDialogEvent {}

class CalculateProjectionsDialogSelectEntityTypeEvent with CalculateProjectionsDialogEvent {
  final Type? selectedEntityType;

  CalculateProjectionsDialogSelectEntityTypeEvent(this.selectedEntityType);
}

class CalculateProjectionsDialogUpdateUIEvent extends BiocentralSimpleMultiTypeUIUpdateEvent
    with CalculateProjectionsDialogEvent {
  CalculateProjectionsDialogUpdateUIEvent(super.updates);
}

@immutable
final class CalculateProjectionsDialogState extends BiocentralSimpleMultiTypeUIState<CalculateProjectionsDialogState> {
  final EmbeddingsColumnWizard? embeddingsColumnWizard;
  final String? selectedEmbedderName;
  final EmbeddingType? selectedEmbeddingType;
  final DatabaseImportMode? selectedImportMode;

  final Map<String, List<BiocentralConfigOption>> projectionConfig;

  final CalculateProjectionsDialogStatus status;

  const CalculateProjectionsDialogState(
    this.embeddingsColumnWizard,
    this.selectedEmbedderName,
    this.selectedEmbeddingType,
    this.selectedImportMode,
    this.projectionConfig,
    this.status,
  );

  const CalculateProjectionsDialogState.initial()
      : embeddingsColumnWizard = null,
        selectedEmbedderName = null,
        selectedEmbeddingType = null,
        selectedImportMode = null,
        projectionConfig = const {},
        status = CalculateProjectionsDialogStatus.initial;

  const CalculateProjectionsDialogState.errored()
      : embeddingsColumnWizard = null,
        selectedEmbedderName = null,
        selectedEmbeddingType = null,
        selectedImportMode = null,
        projectionConfig = const {},
        status = CalculateProjectionsDialogStatus.errored;

  const CalculateProjectionsDialogState.loadedConfig(this.projectionConfig)
      : embeddingsColumnWizard = null,
        selectedEmbedderName = null,
        selectedEmbeddingType = null,
        selectedImportMode = null,
        status = CalculateProjectionsDialogStatus.loadedConfig;

  const CalculateProjectionsDialogState.selected(
    this.embeddingsColumnWizard,
    this.selectedEmbedderName,
    this.selectedEmbeddingType,
    this.selectedImportMode,
    this.projectionConfig,
  ) : status = CalculateProjectionsDialogStatus.selected;

  CalculateProjectionsDialogState withEmbeddingsColumnWizard(EmbeddingsColumnWizard newEmbColumnWizard) {
    return CalculateProjectionsDialogState(
      newEmbColumnWizard,
      selectedEmbedderName,
      selectedEmbeddingType,
      selectedImportMode,
      projectionConfig,
      status,
    );
  }

  @override
  List<Object?> get props =>
      [selectedEmbedderName, selectedEmbeddingType, selectedImportMode, projectionConfig, status];

  @override
  CalculateProjectionsDialogState updateFromUIEvent(BiocentralSimpleMultiTypeUIUpdateEvent event) {
    if (embeddingsColumnWizard == null) {
      return const CalculateProjectionsDialogState.initial();
    }
    return CalculateProjectionsDialogState.selected(
        embeddingsColumnWizard,
        getValueFromEvent(selectedEmbedderName, event),
        getValueFromEvent(selectedEmbeddingType, event),
        getValueFromEvent(selectedImportMode, event),
        projectionConfig);
  }
}

enum CalculateProjectionsDialogStatus { initial, loadedConfig, selected, errored }

class CalculateProjectionsDialogBloc extends Bloc<CalculateProjectionsDialogEvent, CalculateProjectionsDialogState> {
  final BiocentralClientRepository _biocentralClientRepository;

  final EmbeddingsRepository _embeddingsRepository;

  CalculateProjectionsDialogBloc(this._biocentralClientRepository, this._embeddingsRepository)
      : super(const CalculateProjectionsDialogState.initial()) {
    on<CalculateProjectionsDialogGetConfigEvent>((event, emit) async {
      final embeddingsClient = _biocentralClientRepository.getServiceClient<EmbeddingsClient>();
      final projectionConfigEither = await embeddingsClient.getProjectionConfig();
      projectionConfigEither.match((error) {
        emit(const CalculateProjectionsDialogState.errored());
      }, (projectionConfig) {
        emit(CalculateProjectionsDialogState.loadedConfig(projectionConfig));
      });
    });
    on<CalculateProjectionsDialogSelectEntityTypeEvent>((event, emit) async {
      final EmbeddingsColumnWizard? embeddingsColumnWizard =
          _embeddingsRepository.getEmbeddingsColumnWizardByType(event.selectedEntityType);
      if (embeddingsColumnWizard != null) {
        emit(state.withEmbeddingsColumnWizard(embeddingsColumnWizard));
      }
    });
    on<CalculateProjectionsDialogUpdateUIEvent>((event, emit) async {
      emit(state.updateFromUIEvent(event));
    });
  }
}
