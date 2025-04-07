import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
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

final class PLMEvalLeaderboardChangeMetricEvent extends PLMEvalLeaderboardEvent {
  final String datasetName;
  final String metric;

  PLMEvalLeaderboardChangeMetricEvent(this.datasetName, this.metric);
}

@immutable
final class PLMEvalLeaderboardState extends Equatable {
  final PLMLeaderboard remoteLeaderboard;
  final PLMLeaderboard localLeaderboard;
  final PLMLeaderboard mixedLeaderboard;

  final Map<String, String> recommendedMetrics;

  final PLMEvalLeaderBoardStatus status;

  const PLMEvalLeaderboardState(
      this.remoteLeaderboard, this.localLeaderboard, this.mixedLeaderboard, this.recommendedMetrics, this.status);

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

  const PLMEvalLeaderboardState.publishing(
    this.remoteLeaderboard,
    this.localLeaderboard,
    this.mixedLeaderboard,
    this.recommendedMetrics,
  ) : status = PLMEvalLeaderBoardStatus.publishing;

  const PLMEvalLeaderboardState.publishingErrored(
    this.remoteLeaderboard,
    this.localLeaderboard,
    this.mixedLeaderboard,
    this.recommendedMetrics,
  ) : status = PLMEvalLeaderBoardStatus.publishingErrored;

  PLMEvalLeaderboardState changeMetric(String datasetName, String metric) {
    final changedMetrics = Map.of(recommendedMetrics);
    changedMetrics[datasetName] = metric;
    return PLMEvalLeaderboardState(remoteLeaderboard, localLeaderboard, mixedLeaderboard, changedMetrics, status);
  }

  Set<String> getPublishableModels() {
    // TODO Improve check for only huggingface models
    final localModels = localLeaderboard.modelNameToEntries.keys
        .where((modelName) => modelName.contains('/') && !modelName.contains('onnx') || modelName == 'one_hot_encoding')
        .toSet();
    final remoteModels = remoteLeaderboard.modelNameToEntries.keys.toSet();
    return localModels.where((model) => !remoteModels.contains(model)).toSet();
  }

  @override
  List<Object?> get props => [remoteLeaderboard, localLeaderboard, mixedLeaderboard, recommendedMetrics, status];
}

enum PLMEvalLeaderBoardStatus { initial, downloading, downloadErrored, loaded, publishing, publishingErrored }

class PLMEvalLeaderboardBloc extends Bloc<PLMEvalLeaderboardEvent, PLMEvalLeaderboardState> {
  final BiocentralClientRepository _clientRepository;
  final PLMEvalRepository _plmEvalRepository;

  PLMEvalLeaderboardBloc(this._clientRepository, this._plmEvalRepository)
      : super(const PLMEvalLeaderboardState.initial()) {
    on<PLMEvalLeaderboardLoadLocalEvent>((event, emit) async {
      final allAvailableResults = _plmEvalRepository.getAllResultsAsPersistent();
      final localLeaderboard = PLMLeaderboard.fromPersistentResults(allAvailableResults);
      emit(
        PLMEvalLeaderboardState.loaded(
          state.remoteLeaderboard,
          localLeaderboard,
          PLMLeaderboard.mixed(state.remoteLeaderboard, localLeaderboard),
          state.recommendedMetrics,
        ),
      );
    });
    on<PLMEvalLeaderboardDownloadEvent>((event, emit) async {
      emit(PLMEvalLeaderboardState.downloading(state.localLeaderboard));
      final plmEvalClient = _clientRepository.getServiceClient<PLMEvalClient>();
      final leaderboardEither = await plmEvalClient.downloadPLMLeaderboardData();
      leaderboardEither.match(
        (left) => emit(PLMEvalLeaderboardState.downloadErrored(state.localLeaderboard)),
        (remoteLeaderboard) => emit(
          PLMEvalLeaderboardState.loaded(
            remoteLeaderboard.$1,
            state.localLeaderboard,
            PLMLeaderboard.mixed(remoteLeaderboard.$1, state.localLeaderboard),
            remoteLeaderboard.$2,
          ),
        ),
      );
    });
    on<PLMEvalLeaderboardPublishEvent>((event, emit) async {
      emit(
        PLMEvalLeaderboardState.publishing(
          state.remoteLeaderboard,
          state.localLeaderboard,
          state.mixedLeaderboard,
          state.recommendedMetrics,
        ),
      );

      // TODO [Error handling] Embedder Name must be unique here, make sure that redundant evaluations are not possible
      final resultForModelName = _plmEvalRepository
          .getAllResultsAsPersistent()
          .where((result) => result.modelName == event.modelName)
          .firstOrNull;

      if (resultForModelName == null) {
        return emit(
          PLMEvalLeaderboardState.publishingErrored(
            state.remoteLeaderboard,
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
            state.mixedLeaderboard,
            state.recommendedMetrics,
          ),
        ),
        (newLeaderboard) => emit(
          PLMEvalLeaderboardState.loaded(
            newLeaderboard.$1,
            state.localLeaderboard,
            PLMLeaderboard.mixed(newLeaderboard.$1, state.localLeaderboard),
            newLeaderboard.$2,
          ),
        ),
      );
    });
    on<PLMEvalLeaderboardChangeMetricEvent>((event, emit) async {
      emit(state.changeMetric(event.datasetName, event.metric));
    });
  }
}
