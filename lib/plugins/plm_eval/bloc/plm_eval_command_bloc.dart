import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../data/plm_eval_client.dart';

sealed class PLMEvalCommandEvent {}

final class PLMEvalCommandStartAutoEvalEvent extends PLMEvalCommandEvent {
  final String modelID;

  PLMEvalCommandStartAutoEvalEvent(this.modelID);
}

@immutable
final class PLMEvalCommandState extends Equatable {
  final String? modelID;

  final PLMEvalCommandStatus status;

  const PLMEvalCommandState(this.status, this.modelID);

  const PLMEvalCommandState.initial()
      : modelID = null,
        status = PLMEvalCommandStatus.initial;

  const PLMEvalCommandState.starting(this.modelID) : status = PLMEvalCommandStatus.starting;

  const PLMEvalCommandState.running(this.modelID) : status = PLMEvalCommandStatus.running;

  const PLMEvalCommandState.errored(this.modelID) : status = PLMEvalCommandStatus.errored;

  @override
  List<Object?> get props => [modelID, status];
}

enum PLMEvalCommandStatus { initial, starting, running, errored }

class PLMEvalCommandBloc extends Bloc<PLMEvalCommandEvent, PLMEvalCommandState> {
  final BiocentralClientRepository _biocentralClientRepository;


  PLMEvalCommandBloc(this._biocentralClientRepository) : super(const PLMEvalCommandState.initial()) {
    on<PLMEvalCommandStartAutoEvalEvent>((event, emit) async {
      emit(PLMEvalCommandState.starting(event.modelID));

      final plmEvalClient = _biocentralClientRepository.getServiceClient<PLMEvalClient>();
      final startAutoEvalEither = await plmEvalClient.startAutoEval(event.modelID);

      String? taskID;
      await startAutoEvalEither.match((l) async {
        // TODO ERROR MESSAGES NOT CORRECTLY SET!
        return emit(PLMEvalCommandState.errored("Start of autoeval workflow failed! Error: ${l.error}"));
      }, (tID) async {
        taskID = tID;
        emit(PLMEvalCommandState.running(event.modelID));
      });

      if(taskID == null) {
        return emit(PLMEvalCommandState.errored("Could not get a valid task ID for autoeval workflow!"));
      }

    });
  }
}
