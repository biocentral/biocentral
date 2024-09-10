import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../domain/embeddings_repository.dart';
import '../model/embeddings_column_wizard.dart';

sealed class EmbeddingsHubEvent {}

final class EmbeddingsHubLoadEvent extends EmbeddingsHubEvent {
  final Type? entityType;

  EmbeddingsHubLoadEvent(this.entityType);
}

final class EmbeddingsHubReloadEvent extends EmbeddingsHubEvent {}

final class EmbeddingsHubSelectEmbedderEvent extends EmbeddingsHubEvent {
  final String? embedderName;

  EmbeddingsHubSelectEmbedderEvent(this.embedderName);
}

final class EmbeddingsHubSelectEmbeddingTypeEvent extends EmbeddingsHubEvent {
  final EmbeddingType? embeddingType;

  EmbeddingsHubSelectEmbeddingTypeEvent(this.embeddingType);
}

final class EmbeddingsHubSelectEntityIDEvent extends EmbeddingsHubEvent {
  final String? entityID;

  EmbeddingsHubSelectEntityIDEvent(this.entityID);
}

@immutable
final class EmbeddingsHubState extends Equatable {
  final Type? selectedEntityType;

  final EmbeddingsColumnWizard? embeddingsColumnWizard;
  final String? selectedEmbedderName;
  final EmbeddingType? selectedEmbeddingType;

  final String? selectedEntityID;

  final Map<UMAPData, List<Map<String, String>>>? umapData;

  final EmbeddingsHubStatus status;

  const EmbeddingsHubState(this.status, this.embeddingsColumnWizard, this.selectedEmbedderName,
      this.selectedEmbeddingType, this.selectedEntityType, this.selectedEntityID, this.umapData);

  const EmbeddingsHubState.initial()
      : status = EmbeddingsHubStatus.initial,
        selectedEntityType = null,
        selectedEmbedderName = null,
        selectedEmbeddingType = null,
        selectedEntityID = null,
        umapData = null,
        embeddingsColumnWizard = null;

  const EmbeddingsHubState.loading(this.selectedEntityType, this.embeddingsColumnWizard, this.selectedEmbedderName,
      this.selectedEmbeddingType, this.selectedEntityID)
      : umapData = null,
        status = EmbeddingsHubStatus.loading;

  const EmbeddingsHubState.loaded(this.selectedEntityType, this.embeddingsColumnWizard, this.selectedEmbedderName,
      this.selectedEmbeddingType, this.selectedEntityID, this.umapData)
      : status = EmbeddingsHubStatus.loaded;

  @override
  List<Object?> get props => [
        embeddingsColumnWizard,
        selectedEntityType,
        selectedEmbedderName,
        selectedEmbeddingType,
        selectedEntityID,
        status
      ];
}

enum EmbeddingsHubStatus { initial, loading, loaded }

class EmbeddingsHubBloc extends Bloc<EmbeddingsHubEvent, EmbeddingsHubState> {
  final BiocentralColumnWizardRepository _biocentralColumnWizardRepository;
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final EmbeddingsRepository _embeddingsRepository;

  EmbeddingsHubBloc(
      this._biocentralColumnWizardRepository, this._biocentralDatabaseRepository, this._embeddingsRepository)
      : super(const EmbeddingsHubState.initial()) {
    on<EmbeddingsHubLoadEvent>((event, emit) async {
      if (event.entityType != null) {
        emit(const EmbeddingsHubState.initial());
        emit(EmbeddingsHubState.loading(event.entityType, state.embeddingsColumnWizard, state.selectedEmbedderName,
            state.selectedEmbeddingType, state.selectedEntityID));

        // TODO Improve error handling
        EmbeddingsColumnWizard embeddingsColumnWizard =
            await _biocentralColumnWizardRepository.getColumnWizardForColumn<EmbeddingsColumnWizard>(
                columnName: "embeddings",
                valueMap: _biocentralDatabaseRepository.getFromType(event.entityType!)?.getAllEmbeddings() ?? {},
                columnType: EmbeddingManager);

        _embeddingsRepository.updateEmbeddingsColumnWizardForType(event.entityType!, embeddingsColumnWizard);

        emit(EmbeddingsHubState.loaded(
            event.entityType,
            embeddingsColumnWizard,
            state.selectedEmbedderName,
            state.selectedEmbeddingType,
            state.selectedEntityID,
            _loadUMAPData(state.selectedEmbedderName, state.selectedEmbeddingType)));
      }
    });

    on<EmbeddingsHubReloadEvent>((event, emit) async {
      if (state.selectedEntityType != null) {
        emit(EmbeddingsHubState.loading(state.selectedEntityType, state.embeddingsColumnWizard,
            state.selectedEmbedderName, state.selectedEmbeddingType, state.selectedEntityID));

        EmbeddingsColumnWizard embeddingsColumnWizard =
            await _biocentralColumnWizardRepository.getColumnWizardForColumn<EmbeddingsColumnWizard>(
                columnName: "embeddings",
                valueMap:
                    _biocentralDatabaseRepository.getFromType(state.selectedEntityType!)?.getAllEmbeddings() ?? {},
                columnType: EmbeddingManager);

        _embeddingsRepository.updateEmbeddingsColumnWizardForType(state.selectedEntityType!, embeddingsColumnWizard);
        emit(EmbeddingsHubState.loaded(
            state.selectedEntityType,
            embeddingsColumnWizard,
            state.selectedEmbedderName,
            state.selectedEmbeddingType,
            state.selectedEntityID,
            _loadUMAPData(state.selectedEmbedderName, state.selectedEmbeddingType)));
      }
    });

    on<EmbeddingsHubSelectEmbedderEvent>((event, emit) async {
      emit(EmbeddingsHubState.loaded(state.selectedEntityType, state.embeddingsColumnWizard, event.embedderName,
          state.selectedEmbeddingType, null, _loadUMAPData(event.embedderName, state.selectedEmbeddingType)));
    });
    on<EmbeddingsHubSelectEmbeddingTypeEvent>((event, emit) async {
      emit(EmbeddingsHubState.loaded(state.selectedEntityType, state.embeddingsColumnWizard, state.selectedEmbedderName,
          event.embeddingType, null, _loadUMAPData(state.selectedEmbedderName, event.embeddingType)));
    });
    on<EmbeddingsHubSelectEntityIDEvent>((event, emit) async {
      emit(EmbeddingsHubState.loaded(state.selectedEntityType, state.embeddingsColumnWizard, state.selectedEmbedderName,
          state.selectedEmbeddingType, event.entityID, state.umapData));
    });
  }

  Map<UMAPData, List<Map<String, String>>>? _loadUMAPData(String? embedderName, EmbeddingType? embeddingType) {
    if (embedderName != null && embeddingType != null && embeddingType == EmbeddingType.perSequence) {
      return _embeddingsRepository.getUMAPDataMap(embedderName);
    }
    return null;
  }
}
