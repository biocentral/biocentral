import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/ppi_client.dart';
import '../domain/ppi_repository.dart';
import '../model/ppi_database_test.dart';
import 'ppi_commands.dart';

sealed class PPICommandEvent {}

final class PPICommandLoadFromFileEvent extends PPICommandEvent {
  PlatformFile? platformFile;
  FileData? fileData;

  DatabaseImportMode importMode;

  PPICommandLoadFromFileEvent({this.platformFile, this.fileData, this.importMode = DatabaseImportMode.overwrite});
}

final class PPICommandSaveToFileEvent extends PPICommandEvent {
  String? filePath;

  PPICommandSaveToFileEvent({required this.filePath});
}

final class PPICommandImportWithHVIToolkitEvent extends PPICommandEvent {
  FileData fileData;
  String databaseFormat;
  DatabaseImportMode importMode;

  PPICommandImportWithHVIToolkitEvent(
      {required this.fileData, required this.databaseFormat, this.importMode = DatabaseImportMode.overwrite});
}

final class PPICommandRemoveDuplicatesEvent extends PPICommandEvent {
  PPICommandRemoveDuplicatesEvent();
}

final class PPICommandRunDatabaseTestEvent extends PPICommandEvent {
  final PPIDatabaseTest testToRun;

  PPICommandRunDatabaseTestEvent(this.testToRun);
}

final class PPICommandColumnWizardOperationEvent extends PPICommandEvent {
  final ColumnWizard columnWizard;
  final ColumnWizardOperation columnWizardOperation;

  PPICommandColumnWizardOperationEvent(this.columnWizard, this.columnWizardOperation);
}

@immutable
final class PPICommandState extends BiocentralCommandState<PPICommandState> {
  const PPICommandState(super.stateInformation, super.status);

  const PPICommandState.idle() : super.idle();

  @override
  PPICommandState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return PPICommandState(stateInformation, status);
  }

  @override
  List<Object?> get props => [stateInformation, status];
}

class PPICommandBloc extends BiocentralBloc<PPICommandEvent, PPICommandState> with BiocentralSyncBloc {
  final PPIRepository _ppiRepository;
  final BiocentralClientRepository _biocentralClientRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;

  PPICommandBloc(
      this._ppiRepository, this._biocentralClientRepository, this._biocentralProjectRepository, EventBus eventBus)
      : super(const PPICommandState.idle(), eventBus) {
    on<PPICommandLoadFromFileEvent>((event, emit) async {
      LoadPPIsFromFileCommand loadPPIsFromFileCommand = LoadPPIsFromFileCommand(
          biocentralProjectRepository: _biocentralProjectRepository,
          ppiRepository: _ppiRepository,
          platformFile: event.platformFile,
          fileData: event.fileData,
          importMode: event.importMode);
      await loadPPIsFromFileCommand
          .executeWithLogging<PPICommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) => syncWithDatabases(r));
      });
    });

    on<PPICommandSaveToFileEvent>((event, emit) async {
      emit(state.setOperating(information: "Saving interactions to file.."));

      String convertedInteractions = await _ppiRepository.convertToString("fasta");
      final saveEither =
          await _biocentralProjectRepository.handleSave(fileName: "interactions.fasta", content: convertedInteractions);
      saveEither.match((l) => emit(state.setErrored(information: "Error saving interactions!")),
          (r) => emit(state.setFinished(information: "Finished saving interactions to file!")));
    });

    on<PPICommandRemoveDuplicatesEvent>((event, emit) async {
      RemoveDuplicatedPPIsCommand removeDuplicatedPPIsCommand = RemoveDuplicatedPPIsCommand(
          biocentralProjectRepository: _biocentralProjectRepository, ppiRepository: _ppiRepository);
      await removeDuplicatedPPIsCommand.executeWithLogging(_biocentralProjectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) => syncWithDatabases(_ppiRepository.databaseToMap()));
      });
    });

    on<PPICommandImportWithHVIToolkitEvent>((event, emit) async {
      ImportPPIsCommand importPPIsCommand = ImportPPIsCommand(
          ppiClient: _biocentralClientRepository.getServiceClient<PPIClient>(),
          loadedDataset: event.fileData.content,
          datasetFormat: event.databaseFormat);
      importPPIsCommand.executeWithLogging(_biocentralProjectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) {
          syncWithDatabases(r, importMode: event.importMode);
        });
      });
    });

    on<PPICommandRunDatabaseTestEvent>((event, emit) async {
      RunPPIDatabaseTestCommand runPPIDatabaseTestCommand = RunPPIDatabaseTestCommand(
          biocentralProjectRepository: _biocentralProjectRepository,
          ppiRepository: _ppiRepository,
          ppiClient: _biocentralClientRepository.getServiceClient<PPIClient>(),
          testToRun: event.testToRun);
      await runPPIDatabaseTestCommand.executeWithLogging(_biocentralProjectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) => null); // Ignore result here..
      });
    });

    on<PPICommandColumnWizardOperationEvent>((event, emit) async {
      ColumnWizardOperationCommand columnWizardOperationCommand = ColumnWizardOperationCommand(
          columnWizard: event.columnWizard, columnWizardOperation: event.columnWizardOperation);
      columnWizardOperationCommand.executeWithLogging(_biocentralProjectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) async {
          Map<String, BioEntity> entityMap = await _ppiRepository.handleColumnWizardOperationResult(r);
          syncWithDatabases(entityMap);
        });
      });
    });
  }
}
