import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_bus/event_bus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:biocentral/plugins/prediction_models/domain/prediction_model_repository.dart';

sealed class LoadModelDialogEvent {}

final class LoadModelDialogSelectionEvent extends LoadModelDialogEvent {
  final PlatformFile? selectedConfigFile;
  final PlatformFile? selectedOutputFile;
  final PlatformFile? selectedLoggingFile;
  final PlatformFile? selectedCheckpointFile;

  LoadModelDialogSelectionEvent(
      {required this.selectedConfigFile,
      required this.selectedOutputFile,
      required this.selectedLoggingFile,
      required this.selectedCheckpointFile,});
}

final class LoadModelDialogLoadEvent extends LoadModelDialogEvent {
  final DatabaseImportMode databaseImportMode;

  LoadModelDialogLoadEvent(this.databaseImportMode);
}

@immutable
final class LoadModelDialogState extends Equatable {
  final PlatformFile? selectedConfigFile;
  final PlatformFile? selectedOutputFile;
  final PlatformFile? selectedLoggingFile;
  final PlatformFile? selectedCheckpointFile;

  final LoadModelDialogStatus status;

  const LoadModelDialogState(this.status,
      {required this.selectedConfigFile,
      required this.selectedOutputFile,
      required this.selectedLoggingFile,
      required this.selectedCheckpointFile,});

  const LoadModelDialogState.initial()
      : selectedConfigFile = null,
        selectedOutputFile = null,
        selectedLoggingFile = null,
        selectedCheckpointFile = null,
        status = LoadModelDialogStatus.initial;

  const LoadModelDialogState.selecting(
      {required this.selectedConfigFile,
      required this.selectedOutputFile,
      required this.selectedLoggingFile,
      required this.selectedCheckpointFile,})
      : status = LoadModelDialogStatus.selecting;

  const LoadModelDialogState.loading(
      {required this.selectedConfigFile,
      required this.selectedOutputFile,
      required this.selectedLoggingFile,
      required this.selectedCheckpointFile,})
      : status = LoadModelDialogStatus.loading;

  const LoadModelDialogState.loaded(
      {required this.selectedConfigFile,
      required this.selectedOutputFile,
      required this.selectedLoggingFile,
      required this.selectedCheckpointFile,})
      : status = LoadModelDialogStatus.loaded;

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
      emit(LoadModelDialogState.selecting(
          selectedConfigFile: event.selectedConfigFile ?? state.selectedConfigFile,
          selectedOutputFile: event.selectedOutputFile ?? state.selectedOutputFile,
          selectedLoggingFile: event.selectedLoggingFile ?? state.selectedLoggingFile,
          selectedCheckpointFile: event.selectedCheckpointFile ?? state.selectedCheckpointFile,),);
    });
    on<LoadModelDialogLoadEvent>((event, emit) async {
      emit(LoadModelDialogState.loading(
          selectedConfigFile: state.selectedConfigFile,
          selectedOutputFile: state.selectedOutputFile,
          selectedLoggingFile: state.selectedLoggingFile,
          selectedCheckpointFile: state.selectedCheckpointFile,),);

      final FileData? configFileData =
          (await _biocentralProjectRepository.handleLoad(platformFile: state.selectedConfigFile, ignoreIfNoFile: true))
              .getOrElse((l) => null);
      final FileData? outputFileData =
          (await _biocentralProjectRepository.handleLoad(platformFile: state.selectedOutputFile, ignoreIfNoFile: true))
              .getOrElse((l) => null);
      final FileData? loggingFileData =
          (await _biocentralProjectRepository.handleLoad(platformFile: state.selectedLoggingFile, ignoreIfNoFile: true))
              .getOrElse((l) => null);

      final Uint8List? checkpointBytes = (await _biocentralProjectRepository.handleBytesLoad(
              platformFile: state.selectedCheckpointFile, ignoreIfNoFile: true,))
          .getOrElse((l) => null);
      final Map<String, Uint8List>? checkpoints =
          checkpointBytes != null ? {state.selectedCheckpointFile!.name: checkpointBytes} : null;
      await _predictionModelRepository.addModelFromBiotrainerFiles(
          configFile: configFileData?.content,
          outputFile: outputFileData?.content,
          loggingFile: loggingFileData?.content,
          checkpointFiles: checkpoints,);
      _eventBus.fire(BiocentralDatabaseUpdatedEvent());
      emit(LoadModelDialogState.loaded(
          selectedConfigFile: state.selectedConfigFile,
          selectedOutputFile: state.selectedOutputFile,
          selectedLoggingFile: state.selectedLoggingFile,
          selectedCheckpointFile: state.selectedCheckpointFile,),);
    });
  }
}
