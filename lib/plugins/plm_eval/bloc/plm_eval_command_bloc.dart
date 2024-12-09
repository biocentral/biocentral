import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../data/plm_eval_service_api.dart';

sealed class PLMEvalCommandEvent {}

final class PLMEvalCommandStartAutoEvalEvent extends PLMEvalCommandEvent {
  final String modelID;
  final List<BenchmarkDataset> datasets;
  final bool recommendedOnly;

  PLMEvalCommandStartAutoEvalEvent(this.modelID, this.datasets, this.recommendedOnly);
}

@immutable
final class PLMEvalCommandState extends Equatable {
  final String? modelID;
  final AutoEvalProgress? autoEvalProgress;

  final PLMEvalCommandStatus status;

  const PLMEvalCommandState(this.status, this.modelID, this.autoEvalProgress);

  const PLMEvalCommandState.initial()
      : modelID = null,
        autoEvalProgress = null,
        status = PLMEvalCommandStatus.initial;

  const PLMEvalCommandState.starting(this.modelID, this.autoEvalProgress) : status = PLMEvalCommandStatus.starting;

  const PLMEvalCommandState.running(this.modelID, this.autoEvalProgress) : status = PLMEvalCommandStatus.running;

  const PLMEvalCommandState.finished(this.modelID, this.autoEvalProgress) : status = PLMEvalCommandStatus.finished;

  const PLMEvalCommandState.errored(this.modelID, this.autoEvalProgress) : status = PLMEvalCommandStatus.errored;

  @override
  List<Object?> get props => [modelID, autoEvalProgress, status];
}

enum PLMEvalCommandStatus { initial, starting, running, finished, errored }

class PLMEvalCommandBloc extends Bloc<PLMEvalCommandEvent, PLMEvalCommandState> {
  final BiocentralClientRepository _biocentralClientRepository;

  PLMEvalCommandBloc(this._biocentralClientRepository) : super(const PLMEvalCommandState.initial()) {
    on<PLMEvalCommandStartAutoEvalEvent>((event, emit) async {
      final AutoEvalProgress initialProgress = AutoEvalProgress.fromDatasets(event.datasets);
      emit(PLMEvalCommandState.starting(event.modelID, initialProgress));

      final plmEvalClient = _biocentralClientRepository.getServiceClient<PLMEvalClient>();
      final startAutoEvalEither = await plmEvalClient.startAutoEval(event.modelID, event.recommendedOnly);

      String? taskID;
      await startAutoEvalEither.match((l) async {
        // TODO ERROR MESSAGES NOT CORRECTLY SET!
        return emit(
          PLMEvalCommandState.errored('Start of autoeval workflow failed! Error: ${l.error}', initialProgress),
        );
      }, (tID) async {
        taskID = tID;
        emit(PLMEvalCommandState.running(event.modelID, initialProgress));
      });

      if (taskID == null) {
        return emit(
          PLMEvalCommandState.errored('Could not get a valid task ID for autoeval workflow!', initialProgress),
        );
      }

      AutoEvalProgress? currentProgress;
      await for (AutoEvalProgress? progress in plmEvalClient.autoEvalProgressStream(taskID!, initialProgress)) {
        currentProgress = progress;
        emit(PLMEvalCommandState.running(event.modelID, currentProgress));
      }
      emit(PLMEvalCommandState.finished(event.modelID, currentProgress));
    });
  }
}
