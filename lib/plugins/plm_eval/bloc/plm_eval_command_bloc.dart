import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_commands.dart';
import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
import 'package:biocentral/plugins/plm_eval/domain/plm_eval_repository.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import '../data/plm_eval_service_api.dart';

sealed class PLMEvalCommandEvent {}

final class PLMEvalCommandStartAutoEvalEvent extends PLMEvalCommandEvent {
  final String modelID;
  final List<BenchmarkDataset> benchmarkDatasets;
  final bool recommendedOnly;

  PLMEvalCommandStartAutoEvalEvent(this.modelID, this.benchmarkDatasets, this.recommendedOnly);
}

final class PLMEvalCommandPublishResultsEvent extends PLMEvalCommandEvent {
  PLMEvalCommandPublishResultsEvent();
}

@immutable
final class PLMEvalCommandState extends BiocentralCommandState<PLMEvalCommandState> {
  final String? modelID;
  final AutoEvalProgress? autoEvalProgress;

  const PLMEvalCommandState(
    super.stateInformation,
    super.status,
    this.modelID,
    this.autoEvalProgress,
  );

  const PLMEvalCommandState.idle()
      : modelID = null,
        autoEvalProgress = null,
        super.idle();

  @override
  List<Object?> get props => [modelID, autoEvalProgress, status];

  @override
  PLMEvalCommandState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return PLMEvalCommandState(
      stateInformation,
      status,
      modelID,
      autoEvalProgress,
    );
  }

  @override
  PLMEvalCommandState setIdle({String? information}) {
    return const PLMEvalCommandState.idle();
  }

  @override
  PLMEvalCommandState copyWith({required Map<String, dynamic> copyMap}) {
    return PLMEvalCommandState(
      stateInformation,
      status,
      copyMap['modelID'] ?? modelID,
      copyMap['autoEvalProgress'] ?? autoEvalProgress,
    );
  }
}

// TODO [Refactoring] Make BiocentralBloc
class PLMEvalCommandBloc extends BiocentralBloc<PLMEvalCommandEvent, PLMEvalCommandState> with BiocentralUpdateBloc {
  final BiocentralProjectRepository _projectRepository;
  final BiocentralClientRepository _clientRepository;
  final PLMEvalRepository _plmEvalRepository;

  PLMEvalCommandBloc(
    this._projectRepository,
    this._clientRepository,
    this._plmEvalRepository,
    EventBus eventBus,
  ) : super(const PLMEvalCommandState.idle(), eventBus) {
    on<PLMEvalCommandStartAutoEvalEvent>((event, emit) async {
      final autoEvalCommand = AutoEvalPLMCommand(
        plmEvalClient: _clientRepository.getServiceClient<PLMEvalClient>(),
        plmEvalRepository: _plmEvalRepository,
        modelID: event.modelID,
        recommendedOnly: event.recommendedOnly,
        benchmarkDatasets: event.benchmarkDatasets,
      );
      await autoEvalCommand.executeWithLogging<PLMEvalCommandState>(_projectRepository, state).forEach((either) {
        either.match((l) => emit(l), (r) {
          updateDatabases();
        }); // Ignore result here
      });
    });
    on<PLMEvalCommandPublishResultsEvent>((event, emit) async {
      emit(state.setOperating(information: 'Publishing results..'));

      final publishingResults = state.autoEvalProgress?.convertResultsForPublishing(state.modelID);
      if (publishingResults == null || publishingResults.isEmpty) {
        return emit(state.setErrored(information: 'Could not publish results!'));
      }
      final plmEvalClient = _clientRepository.getServiceClient<PLMEvalClient>();

      final publishingEither = await plmEvalClient.publishResults(publishingResults);
      // TODO Handle publishing result
    });
  }
}
