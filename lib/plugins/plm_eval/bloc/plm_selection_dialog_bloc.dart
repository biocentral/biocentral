import 'package:biocentral/plugins/embeddings/model/onnx_embedder.dart';
import 'package:biocentral/plugins/embeddings/model/onnx_runtime_wrapper.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:bloc/bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

sealed class PLMSelectionDialogEvent {}

final class PLMSelectionDialogValidateHuggingfaceEvent extends PLMSelectionDialogEvent {
  final String? plmSelection;

  PLMSelectionDialogValidateHuggingfaceEvent({this.plmSelection});
}

final class PLMSelectionDialogValidateONNXEvent extends PLMSelectionDialogEvent {
  final XFile? onnxFile;

  PLMSelectionDialogValidateONNXEvent({this.onnxFile});
}

@immutable
final class PLMSelectionDialogState extends Equatable {
  final Either<String, XFile>? modelSelection;
  final String? errorMessage;
  final List<PLMEvalTaskInformation> tasks;

  final PLMSelectionDialogStatus status;

  const PLMSelectionDialogState(this.status, this.modelSelection, this.errorMessage, this.tasks);

  const PLMSelectionDialogState.initial()
      : modelSelection = null,
        errorMessage = null,
        tasks = const [],
        status = PLMSelectionDialogStatus.initial;

  const PLMSelectionDialogState.checking(this.modelSelection)
      : errorMessage = null,
        tasks = const [],
        status = PLMSelectionDialogStatus.checking;

  const PLMSelectionDialogState.validated(this.modelSelection, this.tasks)
      : errorMessage = null,
        status = PLMSelectionDialogStatus.validated;

  const PLMSelectionDialogState.evaluationAlreadyAvailable(
    this.modelSelection,
    this.tasks,
  )   : errorMessage = null,
        status = PLMSelectionDialogStatus.evaluationAlreadyAvailable;

  const PLMSelectionDialogState.errored(this.errorMessage)
      : modelSelection = null,
        tasks = const [],
        status = PLMSelectionDialogStatus.errored;

  @override
  List<Object?> get props => [modelSelection, errorMessage, tasks, status];
}

enum PLMSelectionDialogStatus { initial, checking, validated, evaluationAlreadyAvailable, errored }

class PLMSelectionDialogBloc extends Bloc<PLMSelectionDialogEvent, PLMSelectionDialogState> {
  final BiocentralProjectRepository _projectRepository;
  final BiocentralAPIRepository _apiRepository;

  PLMSelectionDialogBloc(this._projectRepository, this._apiRepository)
      : super(const PLMSelectionDialogState.initial()) {
    on<PLMSelectionDialogValidateHuggingfaceEvent>((event, emit) async {
      if (event.plmSelection == null) {
        return emit(const PLMSelectionDialogState.errored('Nothing provided to validate!'));
      }
      final plmSelection = event.plmSelection?.replaceAll('https://huggingface.co', '');
      final Either<String, XFile> selectionEither = left(plmSelection!);

      emit(PLMSelectionDialogState.checking(selectionEither));

      if (plmSelection.isEmpty) {
        return emit(const PLMSelectionDialogState.errored('Provided model name is empty!'));
      }
      final validateError = await _apiRepository.getBiocentralAPI().validateModelID(modelID: plmSelection);
      if (validateError != null) {
        return emit(PLMSelectionDialogState.errored('Validation of model id failed! Error: $validateError'));
      }
      emit(PLMSelectionDialogState.validated(selectionEither, []));
      await _getDatasets(emit, selectionEither);
    });
    on<PLMSelectionDialogValidateONNXEvent>((event, emit) async {
      if (event.onnxFile == null) {
        return emit(const PLMSelectionDialogState.errored('Nothing provided to validate!'));
      }
      final onnxSelection = event.onnxFile;
      final Either<String, XFile> selectionEither = right(onnxSelection!);

      emit(PLMSelectionDialogState.checking(selectionEither));

      // TODO Verify tokenizer config

      if (!onnxSelection.extension.contains('onnx')) {
        return emit(
          const PLMSelectionDialogState.errored('ONNX Model must be saved in an .onnx file!'),
        );
      }
      OrtEnv.instance.init();
      final onnxLoadEither = await _projectRepository.handleBytesLoad(xFile: onnxSelection);
      await onnxLoadEither.match((l) async {
        emit(PLMSelectionDialogState.errored('Validation of model id failed! Error: ${l.error}'));
      }, (onnxBytes) async {
        // TODO [Refactoring] Improve Web ONNX Handling
        if (kIsWeb) {
          emit(PLMSelectionDialogState.validated(selectionEither, []));
          await _getDatasets(emit, selectionEither);
        } else {
          final sessionOptions = OrtSessionOptions();
          final OrtSession session = OrtSession.fromBuffer(onnxBytes!, sessionOptions);

          final (isValid, error) = ONNXEmbedder.validateFromSession(session);
          if (!isValid) {
            emit(PLMSelectionDialogState.errored(error));
          } else {
            emit(PLMSelectionDialogState.validated(selectionEither, []));
            await _getDatasets(emit, selectionEither);
          }
        }
      });
    });
  }

  Future<void> _getDatasets(dynamic emit, Either<String, XFile> selectionEither) async {

    final plmEvalInformation = await _apiRepository.getBiocentralAPI().getPlmEvalInformation();
    if(plmEvalInformation == null) {
      return emit(const PLMSelectionDialogState.errored('Could not retrieve plm eval information!'));
    }
    return emit(PLMSelectionDialogState.validated(selectionEither, plmEvalInformation.tasks.toList()));
  }
}
