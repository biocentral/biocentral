import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:biocentral/plugins/plm_eval/model/plm_leaderboard.dart';

sealed class PLMEvalLeaderboardEvent {}

final class PLMEvalLeaderboardLoadEvent extends PLMEvalLeaderboardEvent {}

@immutable
final class PLMEvalLeaderboardState extends Equatable {
  final PLMLeaderboard leaderboard;

  final PLMEvalLeaderBoardStatus status;

  const PLMEvalLeaderboardState(this.leaderboard, this.status);

  const PLMEvalLeaderboardState.initial()
      : leaderboard = const PLMLeaderboard.empty(),
        status = PLMEvalLeaderBoardStatus.initial;

  const PLMEvalLeaderboardState.loading()
      : leaderboard = const PLMLeaderboard.empty(),
        status = PLMEvalLeaderBoardStatus.loading;

  const PLMEvalLeaderboardState.loaded(this.leaderboard) : status = PLMEvalLeaderBoardStatus.loaded;

  const PLMEvalLeaderboardState.errored()
      : leaderboard = const PLMLeaderboard.empty(),
        status = PLMEvalLeaderBoardStatus.errored;

  @override
  List<Object?> get props => [leaderboard, status];
}

enum PLMEvalLeaderBoardStatus { initial, loading, loaded, errored }

class PLMEvalLeaderboardBloc extends Bloc<PLMEvalLeaderboardEvent, PLMEvalLeaderboardState> {
  final BiocentralClientRepository _biocentralClientRepository;

  PLMEvalLeaderboardBloc(this._biocentralClientRepository) : super(const PLMEvalLeaderboardState.initial()) {
    on<PLMEvalLeaderboardLoadEvent>((event, emit) async {
      emit(const PLMEvalLeaderboardState.loading());
      final plmEvalClient = _biocentralClientRepository.getServiceClient<PLMEvalClient>();
      final leaderboardEither = await plmEvalClient.downloadPLMLeaderboardData();
      leaderboardEither.match(
        (left) => emit(const PLMEvalLeaderboardState.errored()),
        (leaderboard) => emit(PLMEvalLeaderboardState.loaded(leaderboard)),
      );
    });
  }
}
