import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';

sealed class PLMSelectionDialogEvent {}

final class PLMSelectionDialogSelectedEvent extends PLMSelectionDialogEvent {
  final String plmSelection;

  PLMSelectionDialogSelectedEvent(this.plmSelection);
}

@immutable
final class PLMSelectionDialogState extends Equatable {
  final String? plmHuggingface;
  final String? errorMessage;
  final Map<String, List<String>> availableDatasets;

  final PLMSelectionDialogStatus status;

  const PLMSelectionDialogState(this.status, this.plmHuggingface, this.errorMessage, this.availableDatasets);

  const PLMSelectionDialogState.initial()
      : plmHuggingface = null,
        errorMessage = null,
        availableDatasets = const {},
        status = PLMSelectionDialogStatus.initial;

  const PLMSelectionDialogState.checking(this.plmHuggingface)
      : errorMessage = null,
        availableDatasets = const {},
        status = PLMSelectionDialogStatus.checking;

  const PLMSelectionDialogState.validated(this.plmHuggingface, this.availableDatasets)
      : errorMessage = null,
        status = PLMSelectionDialogStatus.validated;

  const PLMSelectionDialogState.evaluationAlreadyAvailable(this.plmHuggingface, this.availableDatasets)
      : errorMessage = null,
        status = PLMSelectionDialogStatus.evaluationAlreadyAvailable;

  const PLMSelectionDialogState.errored(this.errorMessage)
      : plmHuggingface = null,
        availableDatasets = const {},
        status = PLMSelectionDialogStatus.errored;

  @override
  List<Object?> get props => [plmHuggingface, errorMessage, availableDatasets, status];
}

enum PLMSelectionDialogStatus { initial, checking, validated, evaluationAlreadyAvailable, errored }

class PLMSelectionDialogBloc extends Bloc<PLMSelectionDialogEvent, PLMSelectionDialogState> {
  final BiocentralClientRepository _biocentralClientRepository;

  PLMSelectionDialogBloc(this._biocentralClientRepository) : super(const PLMSelectionDialogState.initial()) {
    on<PLMSelectionDialogSelectedEvent>((event, emit) async {
      if (event.plmSelection.isEmpty) {
        return emit(const PLMSelectionDialogState.errored('Provided model name is empty!'));
      }
      if (event.plmSelection.contains('https://huggingface.co')) {
        return emit(
            const PLMSelectionDialogState.errored('Please only provide the model id, without the huggingface domain!'),);
      }

      emit(PLMSelectionDialogState.checking(event.plmSelection));

      final plmEvalClient = _biocentralClientRepository.getServiceClient<PLMEvalClient>();
      final validateEither = await plmEvalClient.validateModelID(event.plmSelection);
      await validateEither.match((l) async {
        emit(PLMSelectionDialogState.errored('Validation of model id failed! Error: ${l.error}'));
      }, (r) async {
        emit(PLMSelectionDialogState.validated(event.plmSelection, {}));
        final benchmarkDatasetEither = await plmEvalClient.getAvailableBenchmarkDatasets();
        benchmarkDatasetEither.match(
            (l) => emit(
                PLMSelectionDialogState.errored('Could not retrieve available benchmark datasets! Error: ${l.error}'),),
            (datasets) => emit(PLMSelectionDialogState.validated(event.plmSelection, datasets)),);
      });
    });
  }
}
