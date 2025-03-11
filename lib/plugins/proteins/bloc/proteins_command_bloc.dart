import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/proteins/bloc/proteins_commands.dart';
import 'package:biocentral/plugins/proteins/data/protein_client.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:cross_file/cross_file.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

sealed class ProteinsCommandEvent {
  ProteinsCommandEvent();
}

final class ProteinsCommandLoadProteinsFromFileEvent extends ProteinsCommandEvent {
  final XFile? xFile;
  final LoadedFileData? fileData;
  final DatabaseImportMode importMode;

  ProteinsCommandLoadProteinsFromFileEvent({required this.importMode, this.xFile, this.fileData});
}

final class ProteinsCommandLoadCustomAttributesFromFileEvent extends ProteinsCommandEvent {
  final XFile? xFile;
  final DatabaseImportMode importMode;

  ProteinsCommandLoadCustomAttributesFromFileEvent({this.xFile, this.importMode = DatabaseImportMode.overwrite});
}

final class ProteinsCommandSaveToFileEvent extends ProteinsCommandEvent {
  final String? filePath;

  ProteinsCommandSaveToFileEvent(this.filePath);
}

final class ProteinsCommandRetrieveTaxonomyEvent extends ProteinsCommandEvent {
  ProteinsCommandRetrieveTaxonomyEvent();
}

final class ProteinsCommandColumnWizardOperationEvent extends ProteinsCommandEvent {
  final ColumnWizard columnWizard;
  final ColumnWizardOperation columnWizardOperation;

  ProteinsCommandColumnWizardOperationEvent(this.columnWizard, this.columnWizardOperation);
}

@immutable
final class ProteinsCommandState extends BiocentralCommandState<ProteinsCommandState> {
  const ProteinsCommandState(super.stateInformation, super.status);

  const ProteinsCommandState.idle() : super.idle();

  @override
  ProteinsCommandState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return ProteinsCommandState(stateInformation, status);
  }

  @override
  List<Object?> get props => [stateInformation, status];
}

class ProteinsCommandBloc extends BiocentralBloc<ProteinsCommandEvent, ProteinsCommandState>
    with BiocentralSyncBloc, Effects<ReOpenColumnWizardEffect> {
  final ProteinRepository _proteinRepository;
  final BiocentralClientRepository _biocentralClientRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;

  ProteinsCommandBloc(
    this._proteinRepository,
    this._biocentralClientRepository,
    this._biocentralProjectRepository,
    EventBus eventBus,
  ) : super(const ProteinsCommandState.idle(), eventBus) {
    on<ProteinsCommandLoadProteinsFromFileEvent>((event, emit) async {
      final LoadProteinsFromFileCommand loadProteinsFromFileCommand = LoadProteinsFromFileCommand(
        biocentralProjectRepository: _biocentralProjectRepository,
        proteinRepository: _proteinRepository,
        xFile: event.xFile,
        fileData: event.fileData,
        importMode: event.importMode,
      );
      await loadProteinsFromFileCommand
          .executeWithLogging<ProteinsCommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) {
          syncWithDatabases(r);
        });
      });
    });

    on<ProteinsCommandLoadCustomAttributesFromFileEvent>((event, emit) async {
      final LoadCustomAttributesFromFileCommand loadCustomAttributesFromFileCommand =
          LoadCustomAttributesFromFileCommand(
        biocentralProjectRepository: _biocentralProjectRepository,
        proteinRepository: _proteinRepository,
        xFile: event.xFile,
        fileData: null,
        importMode: event.importMode,
      );
      await loadCustomAttributesFromFileCommand
          .executeWithLogging<ProteinsCommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) => syncWithDatabases(r));
      });
    });

    on<ProteinsCommandSaveToFileEvent>((event, emit) async {
      emit(state.setOperating(information: 'Saving proteins to file..'));

      final String convertedProteins = await _proteinRepository.convertToString('fasta');
      final saveEither =
          await _biocentralProjectRepository.handleExternalSave(fileName: 'proteins.fasta', content: convertedProteins);
      saveEither.match(
        (l) => emit(state.setErrored(information: 'Error saving proteins!')),
        (r) => emit(state.setFinished(information: 'Finished saving proteins!')),
      );
    });

    on<ProteinsCommandRetrieveTaxonomyEvent>((event, emit) async {
      final RetrieveTaxonomyCommand retrieveTaxonomyCommand = RetrieveTaxonomyCommand(
        biocentralProjectRepository: _biocentralProjectRepository,
        proteinRepository: _proteinRepository,
        proteinClient: _biocentralClientRepository.getServiceClient<ProteinClient>(),
        importMode: DatabaseImportMode.overwrite,
      );
      await retrieveTaxonomyCommand
          .executeWithLogging<ProteinsCommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) => syncWithDatabases(r));
      });
    });

    on<ProteinsCommandColumnWizardOperationEvent>((event, emit) async {
      final ColumnWizardOperationCommand columnWizardOperationCommand = ColumnWizardOperationCommand(
        columnWizard: event.columnWizard,
        columnWizardOperation: event.columnWizardOperation,
      );
      await columnWizardOperationCommand
          .executeWithLogging(_biocentralProjectRepository, state)
          .forEach((either) async {
        await either.match((l) async {
          emit(l);
        }, (r) async {
          final Map<String, BioEntity> entityMap = await _proteinRepository.handleColumnWizardOperationResult(r);
          syncWithDatabases(entityMap);
        });
      });
      final reOpenColumn = event.columnWizardOperation.newColumnName.isEmpty
          ? event.columnWizard.columnName
          : event.columnWizardOperation.newColumnName;
      emitEffect(ReOpenColumnWizardEffect(reOpenColumn));
    });
  }
}
