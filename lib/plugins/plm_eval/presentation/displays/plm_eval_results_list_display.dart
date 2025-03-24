import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_evaluation_bloc.dart';
import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_hub_bloc.dart';
import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/plugins/plm_eval/presentation/displays/plm_eval_queue_display.dart';
import 'package:biocentral/plugins/plm_eval/presentation/displays/plm_eval_results_display.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_task_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PLMEvalResultsListDisplay extends StatefulWidget {
  const PLMEvalResultsListDisplay({
    super.key,
  });

  @override
  State<PLMEvalResultsListDisplay> createState() => _PLMEvalResultsListDisplayState();
}

class _PLMEvalResultsListDisplayState extends State<PLMEvalResultsListDisplay> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<PLMEvalHubBloc, PLMEvalHubState>(
      builder: (context, state) {
        return Column(
          children: [
            ...state.resumableCommands.map((commandLog) => buildResumableEvaluations(commandLog)),
            ...state.sessionResults.map((sessionResult) => buildPLMEvalSessionResultDisplay(sessionResult)),
            ...state.persistentResults.map((persistentResult) => buildPLMEvalPersistentResultDisplay(persistentResult)),
          ],
        );
      },
    );
  }

  Widget buildResumableEvaluations(BiocentralCommandLog commandLog) {
    final PLMEvalEvaluationBloc plmEvalCommandBloc = BlocProvider.of<PLMEvalEvaluationBloc>(context);
    return BiocentralTaskDisplay.resumable(
        commandLog, () => plmEvalCommandBloc.add(PLMEvalEvaluationResumeEvent(commandLog)));
  }

  Widget buildPLMEvalPersistentResultDisplay(PLMEvalPersistentResult persistentResult) {
    return BiocentralTaskDisplay(
      title: 'Loaded evaluation results for: ${persistentResult.modelName}',
      leadingIcon: const Icon(Icons.check),
      children: [buildResultsView(persistentResult: persistentResult)],
    );
  }

  Widget buildPLMEvalSessionResultDisplay(AutoEvalProgress sessionResult) {
    return BiocentralTaskDisplay(
      title: 'Evaluation Results for ${sessionResult.modelName}',
      leadingIcon: const Icon(Icons.check),
      children: [buildResultsView(sessionResult: sessionResult), buildTaskQueue(sessionResult)],
    );
  }

  Widget buildResultsView({AutoEvalProgress? sessionResult, PLMEvalPersistentResult? persistentResult}) {
    final results = sessionResult?.results ?? persistentResult?.results ?? {};
    final Map<String, Map<String, Set<BiocentralMLMetric>>> metrics = {};
    for (final entry in results.entries) {
      metrics.putIfAbsent(entry.key.datasetName, () => {});
      if (entry.value != null && entry.value?.biotrainerTrainingResult != null) {
        metrics[entry.key.datasetName]?[entry.key.splitName] = entry.value!.biotrainerTrainingResult!.testSetMetrics;
      }
    }
    return ExpansionTile(title: const Text('Results'), children: [PLMEvalResultsDisplay(metrics: metrics)]);
  }

  Widget buildTaskQueue(AutoEvalProgress sessionResult) {
    return PLMEvalQueueDisplay(autoEvalProgress: sessionResult);
  }

  @override
  bool get wantKeepAlive => true;
}
