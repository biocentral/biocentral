import 'package:biocentral/plugins/custom_models/bloc/biotrainer_training_bloc.dart';
import 'package:biocentral/plugins/custom_models/data/custom_models_service_api.dart';
import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_metrics_display.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_line_plot.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_metrics_plot.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_lazy_logs_viewer.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_task_display.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';

class PredictionModelDisplay extends StatefulWidget {
  final PredictionModel predictionModel;
  final BiotrainerTrainingState? trainingState;

  const PredictionModelDisplay({required this.predictionModel, this.trainingState, super.key});

  @override
  State<PredictionModelDisplay> createState() => _PredictionModelDisplayState();
}

class _PredictionModelDisplayState extends State<PredictionModelDisplay> {
  bool _showMetricsAsTable = true;

  @override
  Widget build(BuildContext context) {
    final bool isTraining = widget.trainingState != null;
    return isTraining ? buildTrainingModel() : buildTrainedModel();
  }

  Widget buildTrainedModel() {
    final TrainingResult? trainingResult = widget.predictionModel.holdOutResult;
    final TestResult? testResult = widget.predictionModel.defaultTestResult;
    final String databaseType = widget.predictionModel.databaseType?.capitalize() ?? 'Unknown';
    final String title = "$databaseType-Model: ${widget.predictionModel.modelChoice ?? "Unknown architecture"} - "
        "${widget.predictionModel.embedderName ?? "Unknown Embeddings"} - "
        "${widget.predictionModel.protocol?.name ?? "Unknown protocol"}";

    return buildModelCard(
      title: title,
      leadingIcon: buildSanityCheckIcon(testResult),
      subtitle: Text('Model-ID: ${widget.predictionModel.getReadableModelID()}'),
      childrenWithTitles: {
        'Model Information': buildModelInformation(),
        'Metrics': buildMetricsDisplay(testResult),
        'Loss Curves': buildLossCurves(trainingResult),
        'Checkpoints': buildAvailableCheckpoints(),
        'Training Logs': buildLogResult(),
      },
      childrenNeedIntrinsicHeight: {
        'Model Information': true,
        'Metrics': false,
        'Loss Curves': false,
        'Checkpoints': true,
        'Training Logs': false,
      },
    );
  }

  Widget buildTrainingModel() {
    final String title = "Training ${widget.predictionModel.modelChoice ?? "unknown"} Model..";
    return buildModelCard(
      title: title,
      leadingIcon: const CircularProgressIndicator(),
      trailing: widget.trainingState == null ? Container() : BiocentralStatusIndicator(state: widget.trainingState!),
      subtitle: Text("Task-ID: ${widget.trainingState?.stateInformation.serverTaskID ?? 'Pending..'}"),
      childrenWithTitles: {
        'Loss Curves': buildLossCurves(widget.predictionModel.holdOutResult),
        'Training Logs': buildLogResult(),
      },
      childrenNeedIntrinsicHeight: {
        'Loss Curves': false,
        'Training Logs': false,
      },
    );
  }

  Widget buildModelCard({
    required String title,
    required Widget leadingIcon,
    required Map<String, Widget> childrenWithTitles,
    required Map<String, bool> childrenNeedIntrinsicHeight,
    Widget? trailing,
    Widget? subtitle,
  }) {
    return BiocentralTaskDisplay(
      title: title,
      leadingIcon: leadingIcon,
      trailing: trailing,
      subtitle: subtitle,
      children: childrenWithTitles.entries
          .map(
            (entry) =>
            ExpansionTile(
              title: Text(entry.key),
              children: [
                if (childrenNeedIntrinsicHeight[entry.key] ?? true)
                // Use IntrinsicHeight for text and other simple content
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: SizeConfig.screenHeight(context) * 0.7,
                    ),
                    child: IntrinsicHeight(
                      child: entry.value,
                    ),
                  )
                else
                // Use fixed SizedBox for logs, plots, etc.
                  SizedBox(
                    height: SizeConfig.screenHeight(context) * 0.7,
                    child: entry.value,
                  ),
              ].withPadding(
                const Padding(
                  padding: EdgeInsets.all(10),
                ),
              ),
            ),
      )
          .toList(),
    );
  }

  Widget buildSanityCheckIcon(TestResult? testResult) {
    final Set<String> sanityCheckWarnings = testResult?.sanityCheckWarnings ?? {};
    final String tooltipMessage = sanityCheckWarnings.isEmpty
        ? 'All sanity checks passed!'
        : 'Your model has the following sanity check warnings:\n${sanityCheckWarnings.join('\n')}';

    final Icon sanityCheckIcon = sanityCheckWarnings.isEmpty
        ? const Icon(Icons.check, color: Colors.green)
        : const Icon(Icons.warning, color: Colors.red);

    return BiocentralTooltip(message: tooltipMessage, child: sanityCheckIcon);
  }

  Widget buildModelInformation() {
    final Map<String, String> modelInformation = widget.predictionModel.getModelInformationMap();
    final List<TableRow> rows =
    modelInformation.entries.map((entry) => TableRow(children: [Text(entry.key), Text(entry.value)])).toList();
    return Table(children: rows);
  }

  Widget buildMetricsDisplay(TestResult? testResult) {
    if (testResult == null) return Container();
    final metrics = {'Test Set Metrics': testResult.metrics}
      ..addAll(testResult.baselineMetrics);
    return BiocentralMetricsDisplay(metrics: metrics);
  }

  Widget buildLossCurves(TrainingResult? trainingResult) {
    if (trainingResult == null || (trainingResult.trainingLoss.isEmpty && trainingResult.validationLoss.isEmpty)) {
      return Container();
    }
    final Map<String, Map<int, double>> linePlotData = {
      'Training': trainingResult.trainingLoss,
      'Validation': trainingResult.validationLoss,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth * 0.6,
          child: BiocentralLinePlot(data: linePlotData),
        );
      },
    );
  }

  Widget buildAvailableCheckpoints() {
    final List<String> checkpointNames = widget.predictionModel.checkpoints?.keys.toList() ?? [];
    if (checkpointNames.isEmpty) return Container();
    return Column(
      children: checkpointNames.map((name) => Text(name)).toList(),
    );
  }

  Widget buildLogResult() {
    final List<String> logs = widget.predictionModel.trainingLogs ?? [];
    if (logs.isEmpty) return Container();
    return LayoutBuilder(
      builder: (context, constraints) {
        return BiocentralLazyLogsViewer(
          logs: logs,
          height: constraints.maxHeight * 0.8,
        );
      },
    );
  }
}
