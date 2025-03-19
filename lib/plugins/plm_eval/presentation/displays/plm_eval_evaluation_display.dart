import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_command_bloc.dart';
import 'package:biocentral/plugins/plm_eval/presentation/displays/plm_eval_queue_display.dart';
import 'package:biocentral/plugins/plm_eval/presentation/displays/plm_eval_results_display.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_task_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PLMEvalEvaluationDisplay extends StatefulWidget {
  const PLMEvalEvaluationDisplay({
    super.key,
  });

  @override
  State<PLMEvalEvaluationDisplay> createState() => _PLMEvalEvaluationDisplayState();
}

class _PLMEvalEvaluationDisplayState extends State<PLMEvalEvaluationDisplay> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<PLMEvalCommandBloc, PLMEvalCommandState>(
      builder: (context, state) {
        if(state.modelID == null || state.autoEvalProgress == null) {
          return Container();
        }
        return BiocentralTaskDisplay(
          title: 'Evaluating ${state.modelID}',
          leadingIcon: const CircularProgressIndicator(),
          trailing: BiocentralStatusIndicator(state: state),
          children: [buildResultsView(state), buildTaskQueue(state)],
        );
      },
    );
  }

  Widget buildResultsView(PLMEvalCommandState state) {
    final Map<String, Map<String, Set<BiocentralMLMetric>>> metrics = {};
    if (state.autoEvalProgress != null) {
      for (final entry in state.autoEvalProgress!.results.entries) {
        metrics.putIfAbsent(entry.key.datasetName, () => {});
        if (entry.value != null && entry.value?.biotrainerTrainingResult != null) {
          metrics[entry.key.datasetName]?[entry.key.splitName] = entry.value!.biotrainerTrainingResult!.testSetMetrics;
        }
      }
    }
    return ExpansionTile(title: const Text('Results'), children: [PLMEvalResultsDisplay(metrics: metrics)]);
  }

  Widget buildTaskQueue(PLMEvalCommandState state) {
    return PLMEvalQueueDisplay(autoEvalProgress: state.autoEvalProgress);
  }

  @override
  bool get wantKeepAlive => true;
}
