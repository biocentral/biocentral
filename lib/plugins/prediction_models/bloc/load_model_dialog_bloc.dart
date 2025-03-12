import 'package:biocentral/plugins/prediction_models/data/biotrainer_output_dir_handler.dart';
import 'package:biocentral/plugins/prediction_models/domain/prediction_model_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/util/path_util.dart';
import 'package:bloc/bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

// TODO [Refactoring] Handling of loading is different than in other plugins (here: in dialog bloc, other: command bloc)
sealed class LoadModelDialogEvent {}

final class LoadModelDialogSelectionEvent extends LoadModelDialogEvent {
  final XFile? selectedConfigFile;
  final XFile? selectedOutputFile;
  final XFile? selectedLoggingFile;
  final XFile? selectedCheckpointFile;

  LoadModelDialogSelectionEvent({
    required this.selectedConfigFile,
    required this.selectedOutputFile,
    required this.selectedLoggingFile,
    required this.selectedCheckpointFile,
  });
}

final class LoadModelDialogDirectorySelectionEvent extends LoadModelDialogEvent {
  final String directoryPath;

  LoadModelDialogDirectorySelectionEvent(this.directoryPath);
}

@immutable
final class LoadModelDialogState extends Equatable {
  final XFile? selectedConfigFile;
  final XFile? selectedOutputFile;
  final XFile? selectedLoggingFile;
  final XFile? selectedCheckpointFile;

  final LoadModelDialogStatus status;

  const LoadModelDialogState(
    this.status, {
    required this.selectedConfigFile,
    required this.selectedOutputFile,
    required this.selectedLoggingFile,
    required this.selectedCheckpointFile,
  });

  const LoadModelDialogState.initial()
      : selectedConfigFile = null,
        selectedOutputFile = null,
        selectedLoggingFile = null,
        selectedCheckpointFile = null,
        status = LoadModelDialogStatus.initial;

  const LoadModelDialogState.selecting({
    required this.selectedConfigFile,
    required this.selectedOutputFile,
    required this.selectedLoggingFile,
    required this.selectedCheckpointFile,
  }) : status = LoadModelDialogStatus.selecting;

  const LoadModelDialogState.loading({
    required this.selectedConfigFile,
    required this.selectedOutputFile,
    required this.selectedLoggingFile,
    required this.selectedCheckpointFile,
  }) : status = LoadModelDialogStatus.loading;

  const LoadModelDialogState.loaded({
    required this.selectedConfigFile,
    required this.selectedOutputFile,
    required this.selectedLoggingFile,
    required this.selectedCheckpointFile,
  }) : status = LoadModelDialogStatus.loaded;

  @override
  List<Object?> get props =>
      [selectedConfigFile, selectedOutputFile, selectedLoggingFile, selectedCheckpointFile, status];
}

enum LoadModelDialogStatus { initial, selecting, loading, loaded }

class LoadModelDialogBloc extends Bloc<LoadModelDialogEvent, LoadModelDialogState> {
  final PredictionModelRepository _predictionModelRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;
  final EventBus _eventBus;

  LoadModelDialogBloc(this._predictionModelRepository, this._biocentralProjectRepository, this._eventBus)
      : super(const LoadModelDialogState.initial()) {
    on<LoadModelDialogSelectionEvent>((event, emit) async {
      emit(
        LoadModelDialogState.selecting(
          selectedConfigFile: event.selectedConfigFile ?? state.selectedConfigFile,
          selectedOutputFile: event.selectedOutputFile ?? state.selectedOutputFile,
          selectedLoggingFile: event.selectedLoggingFile ?? state.selectedLoggingFile,
          selectedCheckpointFile: event.selectedCheckpointFile ?? state.selectedCheckpointFile,
        ),
      );
    });
    on<LoadModelDialogDirectorySelectionEvent>((event, emit) async {
      final directoryPath = event.directoryPath;

      final pathScanResult = PathScanner.scanDirectory(directoryPath);

      final List<XFile> allFiles = [
        ...pathScanResult.baseFiles,
        ...pathScanResult.getAllSubdirectoryFiles().values.reduce((l1, l2) => l1 + l2),
      ];

      final (configFile, outputFile, loggingFile, checkpointFile) =
          BiotrainerOutputDirHandler.scanDirectoryFiles(allFiles);

      emit(
        LoadModelDialogState.selecting(
          selectedConfigFile: configFile ?? state.selectedConfigFile,
          selectedOutputFile: outputFile ?? state.selectedOutputFile,
          selectedLoggingFile: loggingFile ?? state.selectedLoggingFile,
          selectedCheckpointFile: checkpointFile ?? state.selectedCheckpointFile,
        ),
      );
    });
  }
}
