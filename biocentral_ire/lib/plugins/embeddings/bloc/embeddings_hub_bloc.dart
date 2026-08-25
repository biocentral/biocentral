import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/plugins/embeddings/domain/projections_repository.dart';
import 'package:biocentral/plugins/embeddings/model/projection.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

sealed class EmbeddingsHubEvent {}

final class _EmbeddingsHubUpdateEmbeddingsInternalEvent extends EmbeddingsHubEvent {
  final EmbeddingsDatabaseDTO dto;

  _EmbeddingsHubUpdateEmbeddingsInternalEvent(this.dto);
}

final class _EmbeddingsHubUpdateProjectionsInternalEvent extends EmbeddingsHubEvent {
  final List<Projection> projections;

  _EmbeddingsHubUpdateProjectionsInternalEvent(this.projections);
}

final class _EmbeddingsHubUpdateEntityDatabaseInternalEvent extends EmbeddingsHubEvent {
  final Map<String, BioEntity> entityMap;

  _EmbeddingsHubUpdateEntityDatabaseInternalEvent(this.entityMap);
}

final class EmbeddingsHubSelectEntityTypeEvent extends EmbeddingsHubEvent {
  final Type? entityType;

  EmbeddingsHubSelectEntityTypeEvent(this.entityType);
}

final class EmbeddingsHubReloadEvent extends EmbeddingsHubEvent {}

final class EmbeddingsHubVisualizeOnProtspaceEvent extends EmbeddingsHubEvent {
  final Map<ProjectionData, List<Map<String, dynamic>>>? projectionData;

  EmbeddingsHubVisualizeOnProtspaceEvent(this.projectionData);
}

final class EmbeddingsHubSaveProjectionPlotEvent extends EmbeddingsHubEvent {
  final Uint8List? imageBytes;

  EmbeddingsHubSaveProjectionPlotEvent(this.imageBytes);
}

@immutable
final class EmbeddingsHubState extends Equatable {
  final Type? selectedEntityType;
  final EmbeddingsDatabaseDTO? dto;
  final List<Projection> projections;
  final Map<String, BioEntity> entityMap;

  final EmbeddingsHubStatus status;

  const EmbeddingsHubState(
    this.status,
    this.dto,
    this.selectedEntityType,
    this.projections,
    this.entityMap,
  );

  const EmbeddingsHubState.initial()
      : status = EmbeddingsHubStatus.initial,
        selectedEntityType = null,
        dto = null,
        projections = const [],
        entityMap = const {};

  const EmbeddingsHubState.loaded(
    this.selectedEntityType,
    this.dto,
    this.projections,
    this.entityMap,
  ) : status = EmbeddingsHubStatus.loaded;

  List<Map<String, String>> getPointData() =>
      entityMap.values.map((entity) => entity.toMap().map((k, v) => MapEntry(k.toString(), v.toString()))).toList();

  @override
  List<Object?> get props => [
        selectedEntityType,
        dto,
        projections,
        entityMap,
        status,
      ];
}

enum EmbeddingsHubStatus { initial, loaded }

class EmbeddingsHubBloc extends Bloc<EmbeddingsHubEvent, EmbeddingsHubState> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralColumnWizardRepository _biocentralColumnWizardRepository;
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final EmbeddingsRepository _embeddingsRepository;
  final ProjectionsRepository _projectionsRepository;

  EmbeddingsHubBloc(
    this._biocentralProjectRepository,
    this._biocentralColumnWizardRepository,
    this._biocentralDatabaseRepository,
    this._embeddingsRepository,
    this._projectionsRepository,
  ) : super(const EmbeddingsHubState.initial()) {
    on<_EmbeddingsHubUpdateEmbeddingsInternalEvent>((event, emit) {
      emit(EmbeddingsHubState.loaded(state.selectedEntityType, event.dto, state.projections, state.entityMap));
    });
    on<_EmbeddingsHubUpdateProjectionsInternalEvent>((event, emit) {
      emit(EmbeddingsHubState.loaded(state.selectedEntityType, state.dto, event.projections, state.entityMap));
    });
    on<_EmbeddingsHubUpdateEntityDatabaseInternalEvent>((event, emit) {
      emit(EmbeddingsHubState.loaded(state.selectedEntityType, state.dto, state.projections, event.entityMap));
    });
    on<EmbeddingsHubSelectEntityTypeEvent>((event, emit) {
      // TODO Make generic for selected entity type (current only protein)
      emit(EmbeddingsHubState.loaded(event.entityType, state.dto, state.projections, state.entityMap));
    });

    on<EmbeddingsHubSaveProjectionPlotEvent>((event, emit) async {
      if (event.imageBytes != null) {
        // TODO Error handling, State handling, Custom File name
        final saveEither = await _biocentralProjectRepository.handleImageSave(imageBytes: event.imageBytes!);
        saveEither.match((saveError) {}, (fullPath) {});
      }
    });

    _setupSubscriptions();

    /*
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

        // TODO
        //_embeddingsRepository.updateEmbeddingsColumnWizardForType(event.entityType!, embeddingsColumnWizard);

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

        // TODO
        //_embeddingsRepository.updateEmbeddingsColumnWizardForType(state.selectedEntityType!, embeddingsColumnWizard);
        emit(
          EmbeddingsHubState.loaded(
            state.selectedEntityType,
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
          contentFunction: () async => ProtspaceFileHandler.createProtspaceHTML(event.projectionData!),
        );
        saveEither.match((saveError) {}, (fullPath) {
          final url = 'file://$fullPath';
          emit(state.copyWith(protspaceURL: url));
        });
      }
    });

     */
  }

  void _setupSubscriptions() {
    _embeddingsRepository.databaseStream.listen((dto) {
      add(_EmbeddingsHubUpdateEmbeddingsInternalEvent(dto));
    });
    _projectionsRepository.databaseStream.listen((projections) {
      add(_EmbeddingsHubUpdateProjectionsInternalEvent(projections));
    });
    // TODO Generic
    final proteinRepository = _biocentralDatabaseRepository.getFromType(Protein);
    proteinRepository?.databaseStream.listen((entityMap) {
      add(_EmbeddingsHubUpdateEntityDatabaseInternalEvent(entityMap));
    });
  }
}
