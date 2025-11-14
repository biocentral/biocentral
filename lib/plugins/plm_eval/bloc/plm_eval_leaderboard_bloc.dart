import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/domain/plm_eval_repository.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_leaderboard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class PLMEvalLeaderboardEvent {}

final class PLMEvalLeaderboardLoadLocalEvent extends PLMEvalLeaderboardEvent {}

final class PLMEvalLeaderboardDownloadEvent extends PLMEvalLeaderboardEvent {}

final class PLMEvalLeaderboardPublishEvent extends PLMEvalLeaderboardEvent {
  final String modelName;

  PLMEvalLeaderboardPublishEvent(this.modelName);
}

@immutable
final class PLMEvalLeaderboardState extends Equatable {
  final PLMLeaderboard remoteLeaderboard;
  final PLMLeaderboard localLeaderboard; // TODO
  final PLMLeaderboard mixedLeaderboard;

  final Map<String, String> recommendedMetrics;

  final PLMEvalLeaderBoardStatus status;

  const PLMEvalLeaderboardState(
    this.remoteLeaderboard,
    this.localLeaderboard,
    this.mixedLeaderboard,
    this.recommendedMetrics,
    this.status,
  );

  const PLMEvalLeaderboardState.initial()
      : remoteLeaderboard = const PLMLeaderboard.empty(),
        localLeaderboard = const PLMLeaderboard.empty(),
        mixedLeaderboard = const PLMLeaderboard.empty(),
        recommendedMetrics = const {},
        status = PLMEvalLeaderBoardStatus.initial;

  const PLMEvalLeaderboardState.downloading(this.localLeaderboard)
      : remoteLeaderboard = const PLMLeaderboard.empty(),
        mixedLeaderboard = const PLMLeaderboard.empty(),
        recommendedMetrics = const {},
        status = PLMEvalLeaderBoardStatus.downloading;

  const PLMEvalLeaderboardState.downloadErrored(this.localLeaderboard)
      : remoteLeaderboard = const PLMLeaderboard.empty(),
        mixedLeaderboard = const PLMLeaderboard.empty(),
        recommendedMetrics = const {},
        status = PLMEvalLeaderBoardStatus.downloadErrored;

  const PLMEvalLeaderboardState.loaded(
    this.remoteLeaderboard,
    this.localLeaderboard,
    this.mixedLeaderboard,
    this.recommendedMetrics,
  ) : status = PLMEvalLeaderBoardStatus.loaded;

  /* TODO Re-enable publishing
  Set<String> getPublishableModels() {
    // TODO Improve check for only huggingface models
    final localModels = localLeaderboard.modelNameToEntries.keys
        .where(
          (embedderName) =>
              embedderName.contains('/') && !embedderName.contains('onnx') ||
              embedderName == 'one_hot_encoding' ||
              embedderName == 'random_embedder',
        )
        .toSet();
    final remoteModels = remoteLeaderboard.modelNameToEntries.keys.toSet();
    return localModels.where((model) => !remoteModels.contains(model)).toSet();
  }
   */

  @override
  List<Object?> get props => [remoteLeaderboard, localLeaderboard, mixedLeaderboard, recommendedMetrics, status];
}

enum PLMEvalLeaderBoardStatus { initial, downloading, downloadErrored, loaded, publishing, publishingErrored }

class PLMEvalLeaderboardBloc extends Bloc<PLMEvalLeaderboardEvent, PLMEvalLeaderboardState> {
  final BiocentralAPIRepository _apiRepository;
  final PLMEvalRepository _plmEvalRepository;

  PLMEvalLeaderboardBloc(this._apiRepository, this._plmEvalRepository)
      : super(const PLMEvalLeaderboardState.initial()) {
    on<PLMEvalLeaderboardLoadLocalEvent>((event, emit) async {
      final localResults = _plmEvalRepository.getAllResultsAsPersistent();
      final localLeaderboard = PLMLeaderboard.fromResults(localResults, state.recommendedMetrics);
      emit(
        PLMEvalLeaderboardState.loaded(
          state.remoteLeaderboard,
          localLeaderboard,
          PLMLeaderboard.mixed(
              remote: state.remoteLeaderboard, local: localLeaderboard, recommendedMetrics: state.recommendedMetrics,),
          state.recommendedMetrics,
        ),
      );
    });
    on<PLMEvalLeaderboardDownloadEvent>((event, emit) async {
      emit(PLMEvalLeaderboardState.downloading(state.localLeaderboard));
      final leaderboardEither = await _apiRepository
          .getHubServerClient()
          .downloadPLMLeaderboardData()
          .then((either) => parseLeaderboardFromResponse(either));
      leaderboardEither.match(
        (left) => emit(PLMEvalLeaderboardState.downloadErrored(state.localLeaderboard)),
        (remoteLeaderboard) => emit(
          PLMEvalLeaderboardState.loaded(
            remoteLeaderboard.$1,
            state.localLeaderboard,
            PLMLeaderboard.mixed(
                remote: remoteLeaderboard.$1, local: state.localLeaderboard, recommendedMetrics: remoteLeaderboard.$2,),
            remoteLeaderboard.$2,
          ),
        ),
      );
    });
    /* TODO: Re-enable publishing (Involves change to add publish button)
    on<PLMEvalLeaderboardPublishEvent>((event, emit) async {
      emit(
        PLMEvalLeaderboardState.publishing(
          state.remoteLeaderboard,
          state.localLeaderboard,
          state.localLeaderboard,
          state.mixedLeaderboard,
          state.recommendedMetrics,
        ),
      );

      // TODO [Error handling] Embedder Name must be unique here, make sure that redundant evaluations are not possible
      final resultForModelName = _plmEvalRepository
          .getAllResultsAsPersistent()
          .where((result) => result.embedderName == event.modelName)
          .firstOrNull;

      if (resultForModelName == null) {
        return emit(
          PLMEvalLeaderboardState.publishingErrored(
            state.remoteLeaderboard,
            state.localLeaderboard,
            state.localLeaderboard,
            state.mixedLeaderboard,
            state.recommendedMetrics,
          ),
        );
      }

      final plmEvalClient = _clientRepository.getServiceClient<PLMEvalClient>();

      final publishingEither = await plmEvalClient.publishResult(resultForModelName);
      publishingEither.match(
        (error) => emit(
          PLMEvalLeaderboardState.publishingErrored(
            state.remoteLeaderboard,
            state.localLeaderboard,
            state.localLeaderboard,
            state.mixedLeaderboard,
            state.recommendedMetrics,
          ),
        ),
        (newLeaderboard) => emit(
          PLMEvalLeaderboardState.loaded(
            newLeaderboard.$1,
            state.localLeaderboard,
            state.localLeaderboard,
            PLMLeaderboard.mixed(newLeaderboard.$1, state.localLeaderboard),
            newLeaderboard.$2,
          ),
        ),
      );
    });
     */
  }
}
