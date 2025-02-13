import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/bloc/embeddings_commands.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_client.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/model/biocentral_config_option.dart';
import 'package:event_bus/event_bus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

sealed class EmbeddingsCommandEvent {}

final class EmbeddingsCommandLoadEmbeddingsEvent extends EmbeddingsCommandEvent {
  final PlatformFile? platformFile;
  final FileData? fileData;
  final DatabaseImportMode importMode;

  EmbeddingsCommandLoadEmbeddingsEvent({required this.platformFile, required this.importMode, this.fileData});
}

final class EmbeddingsCommandCalculateEmbeddingsEvent extends EmbeddingsCommandEvent {
  final PredefinedEmbedder predefinedEmbedder;
  final EmbeddingType embeddingType;
  final DatabaseImportMode importMode;

  EmbeddingsCommandCalculateEmbeddingsEvent(this.predefinedEmbedder, this.embeddingType, this.importMode);
}

final class EmbeddingsCommandCalculateProjectionsEvent extends EmbeddingsCommandEvent {
  final String embedderName;
  final Map<String, PerSequenceEmbedding> embeddings;
  final String projectionMethod;
  final Map<BiocentralConfigOption, dynamic> projectionConfig;
  final DatabaseImportMode importMode;

  EmbeddingsCommandCalculateProjectionsEvent(
      this.embedderName, this.embeddings, this.importMode, this.projectionMethod, this.projectionConfig);
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

class EmbeddingsCommandBloc extends BiocentralBloc<EmbeddingsCommandEvent, EmbeddingsCommandState>
    with BiocentralSyncBloc, BiocentralUpdateBloc {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralClientRepository _biocentralClientRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralPythonCompanion _pythonCompanion;

  final EmbeddingsRepository _embeddingsRepository;

  EmbeddingsCommandBloc(
    this._biocentralDatabaseRepository,
    this._biocentralClientRepository,
    this._biocentralProjectRepository,
    this._pythonCompanion,
    this._embeddingsRepository,
    EventBus eventBus,
  ) : super(const EmbeddingsCommandState.idle(), eventBus) {
    on<EmbeddingsCommandLoadEmbeddingsEvent>((event, emit) async {
      final BiocentralDatabase? biocentralDatabase = _biocentralDatabaseRepository.getFromType(Protein);

      if (biocentralDatabase == null) {
        return emit(state.setErrored(information: 'Could not find the database for which to load embeddings!'));
      }

      final LoadEmbeddingsFromFileCommand loadEmbeddingsFromFileCommand = LoadEmbeddingsFromFileCommand(
        biocentralProjectRepository: _biocentralProjectRepository,
        biocentralDatabase: biocentralDatabase,
        pythonCompanion: _pythonCompanion,
        platformFile: event.platformFile,
        fileData: event.fileData,
        importMode: event.importMode,
      );
      await loadEmbeddingsFromFileCommand
          .executeWithLogging<EmbeddingsCommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) => syncWithDatabases(r));
      });
    });
    on<EmbeddingsCommandCalculateEmbeddingsEvent>((event, emit) async {
      // TODO IMPORT MODE
      // TODO Generic repository
      final BiocentralDatabase? biocentralDatabase = _biocentralDatabaseRepository.getFromType(Protein);

      if (biocentralDatabase == null) {
        return emit(state.setErrored(information: 'Could not find the database for which to calculate embeddings!'));
      }
      final CalculateEmbeddingsCommand calculateEmbeddingsCommand = CalculateEmbeddingsCommand(
        biocentralProjectRepository: _biocentralProjectRepository,
        biocentralDatabase: biocentralDatabase,
        pythonCompanion: _pythonCompanion,
        embeddingClient: _biocentralClientRepository.getServiceClient<EmbeddingsClient>(),
        embeddingType: event.embeddingType,
        embedderName: event.predefinedEmbedder.name,
        biotrainerName: event.predefinedEmbedder.biotrainerName,
      );
      await calculateEmbeddingsCommand
          .executeWithLogging<EmbeddingsCommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) async {
          final Map<String, BioEntity> updatedDatabase = biocentralDatabase.updateEmbeddings(r);
          syncWithDatabases(updatedDatabase);
        });
      });
    });
    on<EmbeddingsCommandCalculateProjectionsEvent>((event, emit) async {
      final CalculateProjectionsCommand calculateProjectionsCommand = CalculateProjectionsCommand(
        biocentralProjectRepository: _biocentralProjectRepository,
        biocentralDatabaseRepository: _biocentralDatabaseRepository,
        pythonCompanion: _pythonCompanion,
        embeddingsRepository: _embeddingsRepository,
        embeddingsClient: _biocentralClientRepository.getServiceClient<EmbeddingsClient>(),
        embeddings: event.embeddings,
        embedderName: event.embedderName,
        projectionMethod:  event.projectionMethod,
        projectionConfig: event.projectionConfig,
      );
      await calculateProjectionsCommand
          .executeWithLogging<EmbeddingsCommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) async {
          updateDatabases();
        }); // Ignore result here
      });
    });
  }
}
