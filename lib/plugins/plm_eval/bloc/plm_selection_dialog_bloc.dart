import 'package:biocentral/plugins/embeddings/model/onnx_embedder.dart';
import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:onnxruntime/onnxruntime.dart';

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
  final List<BenchmarkDataset> availableDatasets;
  final List<BenchmarkDataset> recommendedDatasets;

  final PLMSelectionDialogStatus status;

  const PLMSelectionDialogState(
      this.status, this.modelSelection, this.errorMessage, this.availableDatasets, this.recommendedDatasets);

  const PLMSelectionDialogState.initial()
      : modelSelection = null,
        errorMessage = null,
        availableDatasets = const [],
        recommendedDatasets = const [],
        status = PLMSelectionDialogStatus.initial;

  const PLMSelectionDialogState.checking(this.modelSelection)
      : errorMessage = null,
        availableDatasets = const [],
        recommendedDatasets = const [],
        status = PLMSelectionDialogStatus.checking;

  const PLMSelectionDialogState.validated(this.modelSelection, this.availableDatasets, this.recommendedDatasets)
      : errorMessage = null,
        status = PLMSelectionDialogStatus.validated;

  const PLMSelectionDialogState.evaluationAlreadyAvailable(
      this.modelSelection, this.availableDatasets, this.recommendedDatasets)
      : errorMessage = null,
        status = PLMSelectionDialogStatus.evaluationAlreadyAvailable;

  const PLMSelectionDialogState.errored(this.errorMessage)
      : modelSelection = null,
        availableDatasets = const [],
        recommendedDatasets = const [],
        status = PLMSelectionDialogStatus.errored;

  @override
  List<Object?> get props => [modelSelection, errorMessage, availableDatasets, status];
}

enum PLMSelectionDialogStatus { initial, checking, validated, evaluationAlreadyAvailable, errored }

class PLMSelectionDialogBloc extends Bloc<PLMSelectionDialogEvent, PLMSelectionDialogState> {
  final BiocentralProjectRepository _projectRepository;
  final BiocentralClientRepository _biocentralClientRepository;

  PLMSelectionDialogBloc(this._projectRepository, this._biocentralClientRepository)
      : super(const PLMSelectionDialogState.initial()) {
    on<PLMSelectionDialogValidateHuggingfaceEvent>((event, emit) async {
      if (event.plmSelection == null) {
        return emit(const PLMSelectionDialogState.errored('Nothing provided to validate!'));
      }
      final plmSelection = event.plmSelection;
      final Either<String, XFile> selectionEither = left(plmSelection!);

      emit(PLMSelectionDialogState.checking(selectionEither));
      final plmEvalClient = _biocentralClientRepository.getServiceClient<PLMEvalClient>();

      if (plmSelection.isEmpty) {
        return emit(const PLMSelectionDialogState.errored('Provided model name is empty!'));
      }
      if (plmSelection.contains('https://huggingface.co')) {
        return emit(
          const PLMSelectionDialogState.errored('Please only provide the model id, without the huggingface domain!'),
        );
      }
      final validateEither = await plmEvalClient.validateModelID(plmSelection);
      await validateEither.match((l) async {
        emit(PLMSelectionDialogState.errored('Validation of model id failed! Error: ${l.error}'));
      }, (r) async {
        emit(PLMSelectionDialogState.validated(selectionEither, [], []));
        await _getDatasets(emit, selectionEither);
      });
    });
    on<PLMSelectionDialogValidateONNXEvent>((event, emit) async {
      if (event.onnxFile == null) {
        return emit(const PLMSelectionDialogState.errored('Nothing provided to validate!'));
      }
      final onnxSelection = event.onnxFile;
      final Either<String, XFile> selectionEither = right(onnxSelection!);

      emit(PLMSelectionDialogState.checking(selectionEither));

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
        final sessionOptions = OrtSessionOptions();
        final OrtSession session = OrtSession.fromBuffer(onnxBytes!, sessionOptions);

        final (isValid, error) = ONNXEmbedder.validateFromSession(session);
        if (!isValid) {
          emit(PLMSelectionDialogState.errored(error));
        } else {
          emit(PLMSelectionDialogState.validated(selectionEither, [], []));
          await _getDatasets(emit, selectionEither);
        }
      });
    });
  }

  Future<void> _getDatasets(emit, Either<String, XFile> selectionEither) async {
    final plmEvalClient = _biocentralClientRepository.getServiceClient<PLMEvalClient>();

    final availableBenchmarkDatasetEither = await plmEvalClient.getAvailableBenchmarkDatasets();
    await availableBenchmarkDatasetEither.match(
      (l) async {
        emit(PLMSelectionDialogState.errored('Could not retrieve available benchmark datasets! Error: ${l.error}'));
      },
      (List<BenchmarkDataset> available) async {
        final recommendedBenchmarkDatasetEither = await plmEvalClient.getRecommendedBenchmarkDatasets();
        recommendedBenchmarkDatasetEither.match(
            (l) => emit(
                  PLMSelectionDialogState.errored(
                      'Could not retrieve recommended benchmark datasets! Error: ${l.error}'),
                ), (List<BenchmarkDataset> recommended) {
          emit(PLMSelectionDialogState.validated(selectionEither, available..sort(), recommended..sort()));
        });
      },
    );
  }
}
