import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:bloc/bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

sealed class PLMSelectionDialogEvent {}

final class PLMSelectionDialogValidateEvent extends PLMSelectionDialogEvent {
  final String? plmSelection;
  final XFile? onnxSelection;

  PLMSelectionDialogValidateEvent({this.plmSelection, this.onnxSelection});
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
  final BiocentralClientRepository _biocentralClientRepository;

  PLMSelectionDialogBloc(this._biocentralClientRepository) : super(const PLMSelectionDialogState.initial()) {
    on<PLMSelectionDialogValidateEvent>((event, emit) async {
      if(event.plmSelection == null && event.onnxSelection == null) {
        return emit(const PLMSelectionDialogState.errored('Nothing provided to validate!'));
      }
      final plmSelection = event.plmSelection;
      final onnxSelection = event.onnxSelection;
      final Either<String, XFile> selectionEither = plmSelection != null ? left(plmSelection) : right(onnxSelection!);

      emit(PLMSelectionDialogState.checking(selectionEither));
      final plmEvalClient = _biocentralClientRepository.getServiceClient<PLMEvalClient>();

      if(plmSelection != null) {
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
        });
      }
      
      if(onnxSelection != null) {
        // TODO [Error Handling] Improve checking of onnx file
        if(!onnxSelection.extension.contains('onnx')) {
          return emit(
            const PLMSelectionDialogState.errored('ONNX Model must be saved in an .onnx file!'),
          );
        }
        emit(PLMSelectionDialogState.validated(selectionEither, [], []));
      }

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
    });
  }
}
