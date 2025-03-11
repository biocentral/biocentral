import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/ppi/bloc/ppi_commands.dart';
import 'package:biocentral/plugins/ppi/data/ppi_client.dart';
import 'package:biocentral/plugins/ppi/domain/ppi_repository.dart';
import 'package:biocentral/plugins/ppi/model/ppi_database_test.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:cross_file/cross_file.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

sealed class PPICommandEvent {}

final class PPICommandLoadFromFileEvent extends PPICommandEvent {
  XFile? xFile;
  LoadedFileData? fileData;

  DatabaseImportMode importMode;

  PPICommandLoadFromFileEvent({this.xFile, this.fileData, this.importMode = DatabaseImportMode.overwrite});
}

final class PPICommandSaveToFileEvent extends PPICommandEvent {
  String? filePath;

  PPICommandSaveToFileEvent({required this.filePath});
}

final class PPICommandImportWithHVIToolkitEvent extends PPICommandEvent {
  LoadedFileData fileData;
  String databaseFormat;
  DatabaseImportMode importMode;

  PPICommandImportWithHVIToolkitEvent({
    required this.fileData,
    required this.databaseFormat,
    this.importMode = DatabaseImportMode.overwrite,
  });
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

class PPICommandBloc extends BiocentralBloc<PPICommandEvent, PPICommandState>
    with BiocentralSyncBloc, Effects<ReOpenColumnWizardEffect> {
  final PPIRepository _ppiRepository;
  final BiocentralClientRepository _biocentralClientRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;

  PPICommandBloc(
    this._ppiRepository,
    this._biocentralClientRepository,
    this._biocentralProjectRepository,
    EventBus eventBus,
  ) : super(const PPICommandState.idle(), eventBus) {
    on<PPICommandLoadFromFileEvent>((event, emit) async {
      final LoadPPIsFromFileCommand loadPPIsFromFileCommand = LoadPPIsFromFileCommand(
        biocentralProjectRepository: _biocentralProjectRepository,
        ppiRepository: _ppiRepository,
        xFile: event.xFile,
        fileData: event.fileData,
        importMode: event.importMode,
      );
      await loadPPIsFromFileCommand
          .executeWithLogging<PPICommandState>(_biocentralProjectRepository, state)
          .forEach((either) {
        either.match((l) => emit(l), (r) {
          syncWithDatabases(r);
        });
      });
    });

    on<PPICommandSaveToFileEvent>((event, emit) async {
      emit(state.setOperating(information: 'Saving interactions to file..'));

      final String convertedInteractions = await _ppiRepository.convertToString('fasta');
      final saveEither = await _biocentralProjectRepository.handleExternalSave(
          fileName: 'interactions.fasta', content: convertedInteractions);
      saveEither.match(
        (l) => emit(state.setErrored(information: 'Error saving interactions!')),
        (r) => emit(state.setFinished(information: 'Finished saving interactions to file!')),
      );
    });

    on<PPICommandRemoveDuplicatesEvent>((event, emit) async {
      final RemoveDuplicatedPPIsCommand removeDuplicatedPPIsCommand = RemoveDuplicatedPPIsCommand(
        biocentralProjectRepository: _biocentralProjectRepository,
        ppiRepository: _ppiRepository,
      );
      await removeDuplicatedPPIsCommand.executeWithLogging(_biocentralProjectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) => syncWithDatabases(_ppiRepository.databaseToMap()));
      });
    });

    on<PPICommandImportWithHVIToolkitEvent>((event, emit) async {
      final ImportPPIsCommand importPPIsCommand = ImportPPIsCommand(
        ppiClient: _biocentralClientRepository.getServiceClient<PPIClient>(),
        loadedDataset: event.fileData.content,
        datasetFormat: event.databaseFormat,
      );
      importPPIsCommand.executeWithLogging(_biocentralProjectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) {
          syncWithDatabases(r, importMode: event.importMode);
        });
      });
    });

    on<PPICommandRunDatabaseTestEvent>((event, emit) async {
      final RunPPIDatabaseTestCommand runPPIDatabaseTestCommand = RunPPIDatabaseTestCommand(
        biocentralProjectRepository: _biocentralProjectRepository,
        ppiRepository: _ppiRepository,
        ppiClient: _biocentralClientRepository.getServiceClient<PPIClient>(),
        testToRun: event.testToRun,
      );
      await runPPIDatabaseTestCommand.executeWithLogging(_biocentralProjectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) => null); // Ignore result here..
      });
    });

    on<PPICommandColumnWizardOperationEvent>((event, emit) async {
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
          final Map<String, BioEntity> entityMap = await _ppiRepository.handleColumnWizardOperationResult(r);
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
