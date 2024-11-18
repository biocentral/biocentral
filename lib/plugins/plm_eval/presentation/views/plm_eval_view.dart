import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_leaderboard_bloc.dart';
import 'package:biocentral/plugins/plm_eval/presentation/views/plm_eval_leaderboard_view.dart';
import 'package:biocentral/plugins/plm_eval/presentation/views/plm_eval_pipeline_view.dart';
import 'package:biocentral/plugins/plm_eval/presentation/views/plm_eval_results_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_command_bloc.dart';

class PLMEvalView extends StatefulWidget {
  const PLMEvalView({super.key});

  @override
  State<PLMEvalView> createState() => _PLMEvalViewState();
}

class _PLMEvalViewState extends State<PLMEvalView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final PLMEvalCommandBloc plmCommandBloc = BlocProvider.of<PLMEvalCommandBloc>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.fact_check_outlined), text: 'Evaluation'),
                  Tab(icon: Icon(Icons.auto_graph), text: 'Results'),
                  Tab(icon: Icon(Icons.sports_score), text: 'Leaderboard'),
                ],
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Flexible(
              flex: 5,
              child: BlocBuilder<PLMEvalCommandBloc, PLMEvalCommandState>(
                builder: (context, state) {
                  return TabBarView(
                    children: [
                      buildEvaluationPipeline(state),
                      buildResultsTable(state),
                      buildLeaderboardView(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEvaluationPipeline(PLMEvalCommandState state) {
    if (state.modelID == null && state.autoEvalProgress == null) {
      return Container();
    }
    return PLMEvalPipelineView(modelName: state.modelID!, progress: state.autoEvalProgress!);
  }

  Widget buildResultsTable(PLMEvalCommandState state) {
    if (state.modelID == null && state.autoEvalProgress == null) {
      return Container();
    }
    final Map<String, Map<String, Set<BiocentralMLMetric>>> metrics = {};
    for(final entry in state.autoEvalProgress!.results.entries) {
      metrics.putIfAbsent(entry.key.datasetName, () => {});
      if(entry.value != null && entry.value?.biotrainerTrainingResult != null) {
        metrics[entry.key.datasetName]?[entry.key.splitName] = entry.value!.biotrainerTrainingResult!.testSetMetrics;
      }
    }
    return PLMEvalResultsView(metrics: metrics);
  }

  Widget buildLeaderboardView() {
    return BlocBuilder<PLMEvalLeaderboardBloc, PLMEvalLeaderboardState>(builder: (context, state) {
      if(state.status == PLMEvalLeaderBoardStatus.loaded) {
        return PLMEvalLeaderboardView(leaderboard: state.leaderboard);
      }
      return const CircularProgressIndicator();
    });
  }
}
