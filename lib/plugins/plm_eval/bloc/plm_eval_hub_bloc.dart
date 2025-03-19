import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/domain/plm_eval_repository.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:cross_file/cross_file.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

sealed class PLMEvalHubEvent {}

final class PLMEvalHubLoadEvent extends PLMEvalHubEvent {}

final class PLMEvalHubLoadPersistentResultsEvent extends PLMEvalHubEvent {
  final XFile persistentResultFile;

  PLMEvalHubLoadPersistentResultsEvent(this.persistentResultFile);
}

@immutable
final class PLMEvalHubState extends BiocentralCommandState<PLMEvalHubState> {
  final List<AutoEvalProgress> sessionResults;
  final List<PLMEvalPersistentResult> persistentResults;

  const PLMEvalHubState(super.stateInformation, super.status, this.sessionResults, this.persistentResults);

  const PLMEvalHubState.idle()
      : sessionResults = const [],
        persistentResults = const [],
        super.idle();

  @override
  PLMEvalHubState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return PLMEvalHubState(stateInformation, status, sessionResults, persistentResults);
  }

  @override
  PLMEvalHubState copyWith({required Map<String, dynamic> copyMap}) {
    return PLMEvalHubState(
      stateInformation,
      status,
      copyMap['sessionResults'] ?? sessionResults,
      copyMap['persistentResults'] ?? persistentResults,
    );
  }

  @override
  List<Object?> get props => [sessionResults, persistentResults, status];
}

enum PLMEvalHubStatus { initial, loading, loaded, errored }

class PLMEvalHubBloc extends BiocentralBloc<PLMEvalHubEvent, PLMEvalHubState> {
  final BiocentralProjectRepository _projectRepository;
  final PLMEvalRepository _plmEvalRepository;

  PLMEvalHubBloc(this._projectRepository, this._plmEvalRepository, EventBus eventBus)
      : super(const PLMEvalHubState.idle(), eventBus) {
    on<PLMEvalHubLoadEvent>((event, emit) async {
      final sessionResults = _plmEvalRepository.getSessionResults();
      final persistentResults = _plmEvalRepository.getPersistentResults();
      emit(state.copyWith(copyMap: {'sessionResults': sessionResults, 'persistentResults': persistentResults}));
    });
    on<PLMEvalHubLoadPersistentResultsEvent>((event, emit) async {
      // TODO Move to command
      emit(state.setOperating(information: 'Loading plm evaluation result from file..'));
      final contentEither = await _projectRepository.handleLoad(xFile: event.persistentResultFile);

      // TODO [Error handling] Improve loading file error, file is null, file is empty
      contentEither.match(
          (error) => emit(state.setErrored(information: 'Encountered error during loading of plm eval file: $error')),
          (persistentFileContent) {
        final updatedPersistentResults =
            _plmEvalRepository.addPersistentResultsFromFile(persistentFileContent?.content ?? '');
        emit(
          state
              .setFinished(information: 'Finished loading plm evaluation result from file!')
              .copyWith(copyMap: {'persistentResults': updatedPersistentResults}),
        );
      });
    });
  }
}
