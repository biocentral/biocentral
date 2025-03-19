import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_leaderboard_bloc.dart';
import 'package:biocentral/plugins/plm_eval/presentation/displays/plm_eval_evaluation_display.dart';
import 'package:biocentral/plugins/plm_eval/presentation/displays/plm_eval_results_list_display.dart';
import 'package:biocentral/plugins/plm_eval/presentation/views/plm_eval_leaderboard_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PLMEvalHubView extends StatefulWidget {
  const PLMEvalHubView({super.key});

  @override
  State<PLMEvalHubView> createState() => _PLMEvalHubViewState();
}

class _PLMEvalHubViewState extends State<PLMEvalHubView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.fact_check_outlined), text: 'Evaluations'),
                  Tab(icon: Icon(Icons.sports_score), text: 'Leaderboard'),
                ],
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Flexible(
              flex: 5,
              child: TabBarView(
                children: [
                  buildEvaluationsView(),
                  buildLeaderboardView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEvaluationsView() {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            PLMEvalEvaluationDisplay(),
            PLMEvalResultsListDisplay(),
          ],
        ),
      ),
    );
  }

  Widget buildLeaderboardView() {
    return BlocBuilder<PLMEvalLeaderboardBloc, PLMEvalLeaderboardState>(builder: (context, state) {
      if (state.status == PLMEvalLeaderBoardStatus.loaded) {
        return PLMEvalLeaderboardView(leaderboard: state.leaderboard);
      }
      return const CircularProgressIndicator();
    });
  }
}
