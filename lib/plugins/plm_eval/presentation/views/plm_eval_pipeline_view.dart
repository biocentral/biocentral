import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/plm_eval/presentation/views/plm_eval_results_view.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/plugins/prediction_models/presentation/displays/prediction_model_display.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_task_display.dart';
import 'package:flutter/material.dart';

class PLMEvalPipelineView extends StatefulWidget {
  final String modelName;
  final AutoEvalProgress progress;
  final Map<String, List<String>> _datasetNamesToSplits;

  PLMEvalPipelineView({
    required this.modelName,
    required this.progress,
    super.key,
  }) : _datasetNamesToSplits = BenchmarkDataset.benchmarkDatasetsByDatasetName(progress.results.keys.toList());

  @override
  State<PLMEvalPipelineView> createState() => _PLMEvalPipelineViewState();
}

class _PLMEvalPipelineViewState extends State<PLMEvalPipelineView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(body: SingleChildScrollView(child: buildPLMEvalTaskDisplay()));
  }

  Widget buildPLMEvalTaskDisplay() {
    return BiocentralTaskDisplay(
      title: 'Evaluating ${widget.modelName}',
      leadingIcon: const CircularProgressIndicator(),
      trailing: Text('Evaluation Progress: ${widget.progress.completedTasks}/${widget.progress.totalTasks}'),
      children: [buildResultsView(), buildTaskQueue()],
    );
  }

  Widget buildResultsView() {
    final Map<String, Map<String, Set<BiocentralMLMetric>>> metrics = {};
    for (final entry in widget.progress.results.entries) {
      metrics.putIfAbsent(entry.key.datasetName, () => {});
      if (entry.value != null && entry.value?.biotrainerTrainingResult != null) {
        metrics[entry.key.datasetName]?[entry.key.splitName] = entry.value!.biotrainerTrainingResult!.testSetMetrics;
      }
    }
    return ExpansionTile(title: const Text('Results'), children: [PLMEvalResultsView(metrics: metrics)]);
  }

  Widget buildTaskQueue() {
    final Map<String, List<Widget>> datasetGroups = {};

    for (final entry in widget._datasetNamesToSplits.entries) {
      final datasetName = entry.key;
      final groupTasks = <Widget>[];

      for (final splitName in entry.value) {
        final BenchmarkDataset datasetToBuild = BenchmarkDataset(datasetName: datasetName, splitName: splitName);
        final PredictionModel? model = widget.progress.results[datasetToBuild];
        final bool isCurrentProcess = widget.progress.currentTask == datasetToBuild;

        if (model != null) {
          groupTasks.add(
            InputDecorator(
              decoration: InputDecoration(labelText: ' $splitName'),
              child: PredictionModelDisplay(
                predictionModel: model,
                trainingState: isCurrentProcess ? widget.progress.currentModelTrainingState : null,
              ),
            ),
          );
        } else {
          final Widget leadingWidget = const Icon(Icons.query_builder);
          groupTasks.add(
            ListTile(
              leading: leadingWidget,
              title: Text(datasetToBuild.splitName),
            ),
          );
        }
      }

      datasetGroups[datasetName] = groupTasks;
    }

    final List<Widget> groupedTasks = datasetGroups.entries.map((entry) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ExpansionTile(
          title: Text(
            entry.key,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: entry.value,
        ),
      );
    }).toList();

    return ExpansionTile(
      title: const Text('Task Queue'),
      children: groupedTasks,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
