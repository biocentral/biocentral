import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../data/protein_client.dart';
import '../domain/protein_repository.dart';
import 'proteins_commands.dart';

sealed class ProteinsCommandEvent {
  ProteinsCommandEvent();
}

final class ProteinsCommandLoadProteinsFromFileEvent extends ProteinsCommandEvent {
  final PlatformFile? platformFile;
  final FileData? fileData;
  final DatabaseImportMode importMode;

  ProteinsCommandLoadProteinsFromFileEvent({this.platformFile, this.fileData, required this.importMode});
}

final class ProteinsCommandLoadCustomAttributesFromFileEvent extends ProteinsCommandEvent {
  final PlatformFile? platformFile;
  final DatabaseImportMode importMode;

  ProteinsCommandLoadCustomAttributesFromFileEvent({this.platformFile, this.importMode = DatabaseImportMode.overwrite});
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

class ProteinsCommandBloc extends BiocentralBloc<ProteinsCommandEvent, ProteinsCommandState> with BiocentralSyncBloc {
  final ProteinRepository _proteinRepository;
  final BiocentralClientRepository _biocentralClientRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;

  ProteinsCommandBloc(
      this._proteinRepository, this._biocentralClientRepository, this._biocentralProjectRepository, EventBus eventBus)
      : super(const ProteinsCommandState.idle(), eventBus) {
    on<ProteinsCommandLoadProteinsFromFileEvent>((event, emit) async {
      LoadProteinsFromFileCommand loadProteinsFromFileCommand = LoadProteinsFromFileCommand(
          biocentralProjectRepository: _biocentralProjectRepository,
          proteinRepository: _proteinRepository,
          platformFile: event.platformFile,
          fileData: event.fileData,
          importMode: event.importMode);
      await loadProteinsFromFileCommand
          .executeWithLogging<ProteinsCommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) => syncWithDatabases(r));
      });
    });

    on<ProteinsCommandLoadCustomAttributesFromFileEvent>((event, emit) async {
      LoadCustomAttributesFromFileCommand loadCustomAttributesFromFileCommand = LoadCustomAttributesFromFileCommand(
          biocentralProjectRepository: _biocentralProjectRepository,
          proteinRepository: _proteinRepository,
          platformFile: event.platformFile,
          fileData: null,
          importMode: event.importMode);
      await loadCustomAttributesFromFileCommand
          .executeWithLogging<ProteinsCommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) => syncWithDatabases(r));
      });
    });

    on<ProteinsCommandSaveToFileEvent>((event, emit) async {
      emit(state.setOperating(information: "Saving proteins to file.."));

      String convertedProteins = await _proteinRepository.convertToString("fasta");
      final saveEither =
          await _biocentralProjectRepository.handleSave(fileName: "proteins.fasta", content: convertedProteins);
      saveEither.match((l) => emit(state.setErrored(information: "Error saving proteins!")),
          (r) => emit(state.setFinished(information: "Finished saving proteins!")));
    });

    on<ProteinsCommandRetrieveTaxonomyEvent>((event, emit) async {
      RetrieveTaxonomyCommand retrieveTaxonomyCommand = RetrieveTaxonomyCommand(
          biocentralProjectRepository: _biocentralProjectRepository,
          proteinRepository: _proteinRepository,
          proteinClient: _biocentralClientRepository.getServiceClient<ProteinClient>(),
          importMode: DatabaseImportMode.overwrite);
      await retrieveTaxonomyCommand
          .executeWithLogging<ProteinsCommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) => syncWithDatabases(r));
      });
    });

    on<ProteinsCommandColumnWizardOperationEvent>((event, emit) async {
      ColumnWizardOperationCommand columnWizardOperationCommand = ColumnWizardOperationCommand(
          columnWizard: event.columnWizard, columnWizardOperation: event.columnWizardOperation);
      columnWizardOperationCommand.executeWithLogging(_biocentralProjectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) async {
          Map<String, BioEntity> entityMap = await _proteinRepository.handleColumnWizardOperationResult(r);
          syncWithDatabases(entityMap);
        });
      });
    });
  }
}
