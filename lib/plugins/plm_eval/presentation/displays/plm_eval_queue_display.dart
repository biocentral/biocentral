import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/plugins/prediction_models/presentation/displays/prediction_model_display.dart';
import 'package:flutter/material.dart';

class PLMEvalQueueDisplay extends StatelessWidget {
  final AutoEvalProgress? autoEvalProgress;

  const PLMEvalQueueDisplay({required this.autoEvalProgress, super.key});

  @override
  Widget build(BuildContext context) {
    Widget expansionTileWrapper(children) => ExpansionTile(
      title: const Text('Task Queue'),
      children: children,
    );
    if(autoEvalProgress == null || autoEvalProgress!.results.isEmpty) {
      return expansionTileWrapper([]);
    }
    final progress = autoEvalProgress!;

    final datasetNamesToSplits =
    BenchmarkDataset.benchmarkDatasetsByDatasetName(progress.results.keys.toList());
    final Map<String, List<Widget>> datasetGroups = {};
    for (final entry in datasetNamesToSplits.entries) {
      final datasetName = entry.key;
      final groupTasks = <Widget>[];

      for (final splitName in entry.value) {
        final BenchmarkDataset datasetToBuild = BenchmarkDataset(datasetName: datasetName, splitName: splitName);
        final PredictionModel? model = progress.results[datasetToBuild];
        final bool isCurrentProcess = progress.currentTask == datasetToBuild;

        if (model != null) {
          groupTasks.add(
            InputDecorator(
              decoration: InputDecoration(labelText: ' $splitName'),
              child: PredictionModelDisplay(
                predictionModel: model,
                trainingState: isCurrentProcess ? progress.currentModelTrainingState : null,
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

    return expansionTileWrapper(groupedTasks);
  }

}