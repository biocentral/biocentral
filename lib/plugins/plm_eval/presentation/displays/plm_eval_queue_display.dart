import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/plugins/custom_models/presentation/displays/prediction_model_display.dart';
import 'package:flutter/material.dart';

class PLMEvalQueueDisplay extends StatelessWidget {
  final AutoEvalProgressWrapper? progress;

  const PLMEvalQueueDisplay({required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    Widget expansionTileWrapper(children) => ExpansionTile(
          title: const Text('Task Queue'),
          children: children,
        );
    if (this.progress == null || this.progress!.results.isEmpty) {
      return expansionTileWrapper([]);
    }
    final progress = this.progress!;

    final Map<String, List<Widget>> datasetGroups = {};
    for (final taskName in progress.results.keys) {
      final groupTasks = <Widget>[];

      final PredictionModel? model = progress.results[taskName];
      final bool isCurrentProcess = progress.currentTaskName == taskName;

      if (model != null) {
        groupTasks.add(
          InputDecorator(
            decoration: InputDecoration(labelText: ' $taskName'),
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
            title: Text(taskName),
          ),
        );
      }

      datasetGroups[progress.currentFrameworkName] = groupTasks;
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
