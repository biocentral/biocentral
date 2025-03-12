import 'package:biocentral/plugins/prediction_models/domain/prediction_model_repository.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';

sealed class ModelHubEvent {}

final class ModelHubLoadEvent extends ModelHubEvent {}

final class ModelHubLoadModelEvent extends ModelHubEvent {
  final XFile? configFile;
  final XFile? outputFile;
  final XFile? loggingFile;
  final XFile? checkpointFile; // TODO [Optimization] Support multiple checkpoints

  final DatabaseImportMode importMode;

  ModelHubLoadModelEvent({
    required this.configFile,
    required this.outputFile,
    required this.loggingFile,
    required this.checkpointFile,
    required this.importMode,
  });
}

@immutable
final class ModelHubState extends BiocentralCommandState<ModelHubState> {
  final List<PredictionModel> predictionModels;

  const ModelHubState(super.stateInformation, super.status, this.predictionModels);

  const ModelHubState.idle()
      : predictionModels = const [],
        super.idle();

  @override
  ModelHubState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return ModelHubState(stateInformation, status, predictionModels);
  }

  @override
  ModelHubState copyWith({required Map<String, dynamic> copyMap}) {
    return ModelHubState(stateInformation, status, copyMap['predictionModels'] ?? predictionModels);
  }

  @override
  List<Object?> get props => [predictionModels, stateInformation, status];
}

class ModelHubBloc extends Bloc<ModelHubEvent, ModelHubState> {
  final BiocentralProjectRepository _projectRepository;
  final PredictionModelRepository _predictionModelRepository;

  ModelHubBloc(this._projectRepository, this._predictionModelRepository) : super(const ModelHubState.idle()) {
    on<ModelHubLoadEvent>((event, emit) async {
      emit(state.setOperating(information: 'Loading models..'));

      final List<PredictionModel> predictionModels = _predictionModelRepository.predictionModelsToList();

      emit(
        state
            .setFinished(information: 'Finished loading models!')
            .copyWith(copyMap: {'predictionModels': predictionModels}),
      );
    });
    on<ModelHubLoadModelEvent>((event, emit) async {
      emit(state.setOperating(information: 'Loading model..'));

      final LoadedFileData? configFileData =
          (await _projectRepository.handleLoad(xFile: event.configFile, ignoreIfNoFile: true)).getOrElse((l) => null);
      final LoadedFileData? outputFileData =
          (await _projectRepository.handleLoad(xFile: event.outputFile, ignoreIfNoFile: true)).getOrElse((l) => null);
      final LoadedFileData? loggingFileData =
          (await _projectRepository.handleLoad(xFile: event.loggingFile, ignoreIfNoFile: true)).getOrElse((l) => null);

      final Uint8List? checkpointBytes = (await _projectRepository.handleBytesLoad(
        xFile: event.checkpointFile,
        ignoreIfNoFile: true,
      ))
          .getOrElse((l) => null);
      final Map<String, Uint8List>? checkpoints =
          checkpointBytes != null ? {event.checkpointFile!.name: checkpointBytes} : null;
      final updatedModels = await _predictionModelRepository.addModelFromBiotrainerFiles(
        configFile: configFileData?.content,
        outputFile: outputFileData?.content,
        loggingFile: loggingFileData?.content,
        checkpointFiles: checkpoints,
      );
      emit(
        state
            .setFinished(information: 'Finished loading model!')
            .copyWith(copyMap: {'predictionModels': updatedModels}),
      );
    });
  }
}
