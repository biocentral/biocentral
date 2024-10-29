import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

import '../data/embeddings_client.dart';
import '../data/predefined_embedders.dart';
import '../domain/embeddings_repository.dart';
import 'embeddings_commands.dart';

sealed class EmbeddingsCommandEvent {}

final class EmbeddingsCommandCalculateEmbeddingsEvent extends EmbeddingsCommandEvent {
  final PredefinedEmbedder predefinedEmbedder;
  final EmbeddingType embeddingType;
  final DatabaseImportMode importMode;

  EmbeddingsCommandCalculateEmbeddingsEvent(this.predefinedEmbedder, this.embeddingType, this.importMode);
}

final class EmbeddingsCommandCalculateUMAPEvent extends EmbeddingsCommandEvent {
  final String embedderName;
  final List<PerSequenceEmbedding> embedding;
  final DatabaseImportMode importMode;

  EmbeddingsCommandCalculateUMAPEvent(this.embedderName, this.embedding, this.importMode);
}

@immutable
final class EmbeddingsCommandState extends BiocentralCommandState<EmbeddingsCommandState> {
  const EmbeddingsCommandState(super.stateInformation, super.status);

  const EmbeddingsCommandState.idle() : super.idle();

  @override
  EmbeddingsCommandState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return EmbeddingsCommandState(stateInformation, status);
  }

  @override
  List<Object?> get props => [stateInformation, status];
}

class EmbeddingsCommandBloc extends BiocentralBloc<EmbeddingsCommandEvent, EmbeddingsCommandState> with BiocentralSyncBloc, BiocentralUpdateBloc {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralClientRepository _biocentralClientRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;

  final EmbeddingsRepository _embeddingsRepository;

  EmbeddingsCommandBloc(this._biocentralDatabaseRepository, this._biocentralClientRepository,
      this._biocentralProjectRepository, this._embeddingsRepository, EventBus eventBus)
      : super(const EmbeddingsCommandState.idle(), eventBus) {
    on<EmbeddingsCommandCalculateEmbeddingsEvent>((event, emit) async {
      // TODO IMPORT MODE
      // TODO Generic repository
      BiocentralDatabase? biocentralDatabase = _biocentralDatabaseRepository.getFromType(Protein);

      if (biocentralDatabase == null) {
        emit(state.setErrored(information: "Could not find the database for which to calculate embeddings!"));
      } else {
        CalculateEmbeddingsCommand calculateEmbeddingsCommand = CalculateEmbeddingsCommand(
            biocentralProjectRepository: _biocentralProjectRepository,
            biocentralDatabase: biocentralDatabase,
            embeddingClient: _biocentralClientRepository.getServiceClient<EmbeddingsClient>(),
            embeddingType: event.embeddingType,
            embedderName: event.predefinedEmbedder.name,
            biotrainerName: event.predefinedEmbedder.biotrainerName);
        await calculateEmbeddingsCommand
            .executeWithLogging<EmbeddingsCommandState>(_biocentralProjectRepository, state)
            .forEach((either) {
          either.match((l) => emit(l), (r) async {
            Map<String, BioEntity> updatedDatabase = biocentralDatabase.updateEmbeddings(r);
            syncWithDatabases(updatedDatabase);
          });
        });
      }
    });
    on<EmbeddingsCommandCalculateUMAPEvent>((event, emit) async {
      CalculateUMAPCommand calculateUMAPCommand = CalculateUMAPCommand(
          biocentralProjectRepository: _biocentralProjectRepository,
          biocentralDatabaseRepository: _biocentralDatabaseRepository,
          embeddingsRepository: _embeddingsRepository,
          embeddingsClient: _biocentralClientRepository.getServiceClient<EmbeddingsClient>(),
          embeddings: event.embedding,
          embedderName: event.embedderName);
      await calculateUMAPCommand
          .executeWithLogging<EmbeddingsCommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) => updateDatabases()); // Ignore result here
      });
    });
  }
}
