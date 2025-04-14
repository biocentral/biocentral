import 'package:biocentral/plugins/plm_eval/presentation/displays/plm_eval_evaluation_display.dart';
import 'package:biocentral/plugins/plm_eval/presentation/displays/plm_eval_results_list_display.dart';
import 'package:biocentral/plugins/plm_eval/presentation/views/plm_eval_leaderboard_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: constraints.maxHeight * 0.125,
                  child: TabBar(
                    labelColor: Theme.of(context).colorScheme.onSurface,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    tabs: [
                      Tab(icon: Icon(Icons.fact_check_outlined), text: 'Evaluations'),
                      Tab(icon: Icon(Icons.sports_score), text: 'Leaderboard'),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
                SizedBox(
                  height: constraints.maxHeight * 0.8,
                  child: TabBarView(
                    children: [
                      buildEvaluationsView(),
                      buildLeaderboardView(),
                    ],
                  ),
                ),
              ],
            );
          },
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
    return const PLMEvalLeaderboardSelectionView();
  }
}
