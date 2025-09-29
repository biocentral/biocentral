import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_leaderboard_bloc.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_leaderboard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ranking_system/ranking_system.dart';


class PLMEvalLeaderboardSelectionView extends StatefulWidget {
  const PLMEvalLeaderboardSelectionView({super.key});

  @override
  State<PLMEvalLeaderboardSelectionView> createState() => _PLMEvalLeaderboardSelectionViewState();
}

class _PLMEvalLeaderboardSelectionViewState extends State<PLMEvalLeaderboardSelectionView> {
  PLMLeaderboardKind _selection = PLMLeaderboardKind.mixed;

  @override
  Widget build(BuildContext context) {
    final plmEvalLeaderboardBloc = BlocProvider.of<PLMEvalLeaderboardBloc>(context);

    return BlocBuilder<PLMEvalLeaderboardBloc, PLMEvalLeaderboardState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              BiocentralDiscreteSelection<PLMLeaderboardKind>(
                title: 'Leaderboard Selection',
                selectableValues: PLMLeaderboardKind.values,
                displayConversion: (kind) => kind.name,
                initialValue: PLMLeaderboardKind.mixed,
                onChangedCallback: (PLMLeaderboardKind? value) {
                  setState(() {
                    if (value != null) {
                      _selection = value;
                    }
                  });
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () => plmEvalLeaderboardBloc.add(PLMEvalLeaderboardDownloadEvent()),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Leaderboard'),
              ),
              buildLeaderboardFromSelection(state),
            ].withPadding(const Padding(padding: EdgeInsets.all(10.0))),
          ),
        );
      },
    );
  }

  Widget buildLeaderboardFromSelection(PLMEvalLeaderboardState state) {
    switch (_selection) {
      case PLMLeaderboardKind.mixed:
        final mixedRanking = state.mixedLeaderboard.ranking;
        if(mixedRanking == null) {
          return const Text('Mixed ranking not available!');
        }
        return LeaderboardView(
          ranking: mixedRanking,
          includeCategoryRanking: true,
          title: const Text('Total Embedder Model Ranking'),
        );
      case PLMLeaderboardKind.remote:
        final remoteRanking = state.remoteLeaderboard.ranking;
        if(remoteRanking == null) {
          return const Text('Remote ranking not available!');
        }
        return LeaderboardView(
          ranking: remoteRanking,
          includeCategoryRanking: true,
          title: const Text('Remote Embedder Model Ranking'),
        );
      case PLMLeaderboardKind.local:
        final localRanking = state.localLeaderboard.ranking;
        if(localRanking == null) {
          return const Text('Local ranking not available!');
        }
        return LeaderboardView(
            ranking: localRanking,
            includeCategoryRanking: true,
            title: const Text('Local Embedder Model Ranking'),
        );
    }
  }
}
