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

@immutable
final class PLMEvalLeaderboardState extends Equatable {
  final PLMLeaderboard remoteLeaderboard;
  final PLMLeaderboard localLeaderboard;
  final PLMLeaderboard mixedLeaderboard;

  final PLMEvalLeaderBoardStatus status;

  const PLMEvalLeaderboardState(this.remoteLeaderboard, this.localLeaderboard, this.mixedLeaderboard, this.status);

  const PLMEvalLeaderboardState.initial()
      : remoteLeaderboard = const PLMLeaderboard.empty(),
        localLeaderboard = const PLMLeaderboard.empty(),
        mixedLeaderboard = const PLMLeaderboard.empty(),
        status = PLMEvalLeaderBoardStatus.initial;

  const PLMEvalLeaderboardState.downloading(this.localLeaderboard, this.mixedLeaderboard)
      : remoteLeaderboard = const PLMLeaderboard.empty(),
        status = PLMEvalLeaderBoardStatus.downloading;

  const PLMEvalLeaderboardState.loaded(this.remoteLeaderboard, this.localLeaderboard, this.mixedLeaderboard)
      : status = PLMEvalLeaderBoardStatus.loaded;

  const PLMEvalLeaderboardState.downloadErrored(this.localLeaderboard)
      : remoteLeaderboard = const PLMLeaderboard.empty(),
        mixedLeaderboard = const PLMLeaderboard.empty(),
        status = PLMEvalLeaderBoardStatus.downloadErrored;

  @override
  List<Object?> get props => [remoteLeaderboard, localLeaderboard, mixedLeaderboard, status];
}

enum PLMEvalLeaderBoardStatus { initial, downloading, loaded, downloadErrored }

class PLMEvalLeaderboardBloc extends Bloc<PLMEvalLeaderboardEvent, PLMEvalLeaderboardState> {
  final BiocentralClientRepository _biocentralClientRepository;
  final PLMEvalRepository _plmEvalRepository;

  PLMEvalLeaderboardBloc(this._biocentralClientRepository, this._plmEvalRepository)
      : super(const PLMEvalLeaderboardState.initial()) {
    on<PLMEvalLeaderboardLoadLocalEvent>((event, emit) async {
      final allAvailableResults = _plmEvalRepository.getAllResultsAsPersistent();
      final localLeaderboard = PLMLeaderboard.fromPersistentResults(allAvailableResults);
      emit(
        PLMEvalLeaderboardState.loaded(
          state.remoteLeaderboard,
          localLeaderboard,
          PLMLeaderboard.mixed(state.remoteLeaderboard, localLeaderboard),
        ),
      );
    });
    on<PLMEvalLeaderboardDownloadEvent>((event, emit) async {
      emit(PLMEvalLeaderboardState.downloading(state.localLeaderboard, state.mixedLeaderboard));
      final plmEvalClient = _biocentralClientRepository.getServiceClient<PLMEvalClient>();
      final leaderboardEither = await plmEvalClient.downloadPLMLeaderboardData();
      leaderboardEither.match(
        (left) => emit(PLMEvalLeaderboardState.downloadErrored(state.localLeaderboard)),
        (remoteLeaderboard) => emit(
          PLMEvalLeaderboardState.loaded(
            remoteLeaderboard,
            state.localLeaderboard,
            PLMLeaderboard.mixed(remoteLeaderboard, state.localLeaderboard),
          ),
        ),
      );
    });
  }
}
