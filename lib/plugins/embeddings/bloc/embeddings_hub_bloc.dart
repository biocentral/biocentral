import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_service_api.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

final class EmbeddingsHubVisualizeOnProtspaceEvent extends EmbeddingsHubEvent {
  final Map<ProjectionData, List<Map<String, dynamic>>>? projectionData;

  EmbeddingsHubVisualizeOnProtspaceEvent(this.projectionData);
}

@immutable
final class EmbeddingsHubState extends Equatable {
  final Type? selectedEntityType;

  final EmbeddingsColumnWizard? embeddingsColumnWizard;
  final String? selectedEmbedderName;
  final EmbeddingType? selectedEmbeddingType;

  final String? selectedEntityID;

  final Map<ProjectionData, List<Map<String, dynamic>>>? projectionData;

  final String? protspaceURL;

  final EmbeddingsHubStatus status;

  const EmbeddingsHubState(
    this.status,
    this.embeddingsColumnWizard,
    this.selectedEmbedderName,
    this.selectedEmbeddingType,
    this.selectedEntityType,
    this.selectedEntityID,
    this.projectionData,
    this.protspaceURL,
  );

  const EmbeddingsHubState.initial()
      : status = EmbeddingsHubStatus.initial,
        selectedEntityType = null,
        selectedEmbedderName = null,
        selectedEmbeddingType = null,
        selectedEntityID = null,
        projectionData = null,
        embeddingsColumnWizard = null,
        protspaceURL = null;

  const EmbeddingsHubState.loading(
    this.selectedEntityType,
    this.embeddingsColumnWizard,
    this.selectedEmbedderName,
    this.selectedEmbeddingType,
    this.selectedEntityID,
    this.protspaceURL,
  )   : projectionData = null,
        status = EmbeddingsHubStatus.loading;

  const EmbeddingsHubState.loaded(
    this.selectedEntityType,
    this.embeddingsColumnWizard,
    this.selectedEmbedderName,
    this.selectedEmbeddingType,
    this.selectedEntityID,
    this.projectionData,
    this.protspaceURL,
  ) : status = EmbeddingsHubStatus.loaded;

  EmbeddingsHubState copyWith({
    Type? selectedEntityType,
    EmbeddingsColumnWizard? embeddingsColumnWizard,
    String? selectedEmbedderName,
    EmbeddingType? selectedEmbeddingType,
    String? selectedEntityID,
    Map<ProjectionData, List<Map<String, dynamic>>>? projectionData,
    String? protspaceURL,
    EmbeddingsHubStatus? status,
  }) {
    return EmbeddingsHubState(
      status ?? this.status,
      embeddingsColumnWizard ?? this.embeddingsColumnWizard,
      selectedEmbedderName ?? this.selectedEmbedderName,
      selectedEmbeddingType ?? this.selectedEmbeddingType,
      selectedEntityType ?? this.selectedEntityType,
      selectedEntityID ?? this.selectedEntityID,
      projectionData ?? this.projectionData,
      protspaceURL ?? this.protspaceURL,
    );
  }

  @override
  List<Object?> get props => [
        embeddingsColumnWizard,
        selectedEntityType,
        selectedEmbedderName,
        selectedEmbeddingType,
        selectedEntityID,
        protspaceURL,
        status,
      ];
}

enum EmbeddingsHubStatus { initial, loading, loaded }

class EmbeddingsHubBloc extends Bloc<EmbeddingsHubEvent, EmbeddingsHubState> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralColumnWizardRepository _biocentralColumnWizardRepository;
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final EmbeddingsRepository _embeddingsRepository;

  EmbeddingsHubBloc(
    this._biocentralProjectRepository,
    this._biocentralColumnWizardRepository,
    this._biocentralDatabaseRepository,
    this._embeddingsRepository,
  ) : super(const EmbeddingsHubState.initial()) {
    on<EmbeddingsHubLoadEvent>((event, emit) async {
      if (event.entityType != null) {
        emit(const EmbeddingsHubState.initial());
        emit(
          EmbeddingsHubState.loading(
            event.entityType,
            state.embeddingsColumnWizard,
            state.selectedEmbedderName,
            state.selectedEmbeddingType,
            state.selectedEntityID,
            state.protspaceURL,
          ),
        );

        // TODO Improve error handling
        final EmbeddingsColumnWizard embeddingsColumnWizard =
            await _biocentralColumnWizardRepository.getColumnWizardForColumn<EmbeddingsColumnWizard>(
          columnName: 'embeddings',
          valueMap: _biocentralDatabaseRepository.getFromType(event.entityType!)?.getAllEmbeddings() ?? {},
          columnType: EmbeddingManager,
        );

        _embeddingsRepository.updateEmbeddingsColumnWizardForType(event.entityType!, embeddingsColumnWizard);

        emit(
          EmbeddingsHubState.loaded(
            event.entityType,
            embeddingsColumnWizard,
            state.selectedEmbedderName,
            state.selectedEmbeddingType,
            state.selectedEntityID,
            _loadProjectionData(state.selectedEmbedderName, state.selectedEmbeddingType),
            state.protspaceURL,
          ),
        );
      }
    });

    on<EmbeddingsHubReloadEvent>((event, emit) async {
      if (state.selectedEntityType != null) {
        emit(
          EmbeddingsHubState.loading(
            state.selectedEntityType,
            state.embeddingsColumnWizard,
            state.selectedEmbedderName,
            state.selectedEmbeddingType,
            state.selectedEntityID,
            state.protspaceURL,
          ),
        );

        final EmbeddingsColumnWizard embeddingsColumnWizard =
            await _biocentralColumnWizardRepository.getColumnWizardForColumn<EmbeddingsColumnWizard>(
          columnName: 'embeddings',
          valueMap: _biocentralDatabaseRepository.getFromType(state.selectedEntityType!)?.getAllEmbeddings() ?? {},
          columnType: EmbeddingManager,
        );

        _embeddingsRepository.updateEmbeddingsColumnWizardForType(state.selectedEntityType!, embeddingsColumnWizard);
        emit(
          EmbeddingsHubState.loaded(
              state.selectedEntityType,
              embeddingsColumnWizard,
              state.selectedEmbedderName,
              state.selectedEmbeddingType,
              state.selectedEntityID,
              _loadProjectionData(state.selectedEmbedderName, state.selectedEmbeddingType),
              state.protspaceURL),
        );
      }
    });

    on<EmbeddingsHubSelectEmbedderEvent>((event, emit) async {
      emit(
        EmbeddingsHubState.loaded(
          state.selectedEntityType,
          state.embeddingsColumnWizard,
          event.embedderName,
          state.selectedEmbeddingType,
          null,
          _loadProjectionData(event.embedderName, state.selectedEmbeddingType),
          state.protspaceURL,
        ),
      );
    });
    on<EmbeddingsHubSelectEmbeddingTypeEvent>((event, emit) async {
      emit(
        EmbeddingsHubState.loaded(
          state.selectedEntityType,
          state.embeddingsColumnWizard,
          state.selectedEmbedderName,
          event.embeddingType,
          null,
          _loadProjectionData(state.selectedEmbedderName, event.embeddingType),
          state.protspaceURL,
        ),
      );
    });
    on<EmbeddingsHubSelectEntityIDEvent>((event, emit) async {
      emit(
        EmbeddingsHubState.loaded(
          state.selectedEntityType,
          state.embeddingsColumnWizard,
          state.selectedEmbedderName,
          state.selectedEmbeddingType,
          event.entityID,
          state.projectionData,
          state.protspaceURL,
        ),
      );
    });

    on<EmbeddingsHubVisualizeOnProtspaceEvent>((event, emit) async {
      // TODO Refactor to separate BLOC
      if (event.projectionData != null) {
        // TODO Error handling, File name
        final saveEither = await _biocentralProjectRepository.handleProjectInternalSave(
            fileName: 'protspace.html',
            type: ProjectionData,
            contentFunction: () async => ProtspaceFileHandler.createProtspaceHTML(event.projectionData!));
        saveEither.match((saveError) {}, (fullPath) {
          final url = 'file://$fullPath';
          emit(state.copyWith(protspaceURL: url));
        });
      }
    });
  }

  Map<ProjectionData, List<Map<String, dynamic>>>? _loadProjectionData(
      String? embedderName, EmbeddingType? embeddingType) {
    if (embedderName != null && embeddingType != null && embeddingType == EmbeddingType.perSequence) {
      return _embeddingsRepository.getProjectionDataMap(embedderName);
    }
    return null;
  }
}
