import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_line_plot.dart';
import 'package:flutter/material.dart';

import '../../data/prediction_models_service_api.dart';
import '../../model/prediction_model.dart';

class PredictionModelDisplay extends StatefulWidget {
  final PredictionModel predictionModel;

  const PredictionModelDisplay({super.key, required this.predictionModel});

  @override
  State<PredictionModelDisplay> createState() => _PredictionModelDisplayState();
}

class _PredictionModelDisplayState extends State<PredictionModelDisplay> {
  final ScrollController _trainingLogsScrollController = ScrollController();
  final List<Text> _loadedLogs = [];

  static const int _maxLoadedLogsPerStep = 50;

  @override
  void initState() {
    super.initState();
    // Initially load logs
    _loadedLogs.addAll(loadLogs());
    // Add listener to lazy-load new logs
    _trainingLogsScrollController.addListener(() {
      if (_trainingLogsScrollController.position.pixels == _trainingLogsScrollController.position.maxScrollExtent) {
        Iterable<Text> newLogs = loadLogs();
        setState(() {
          _loadedLogs.addAll(newLogs);
        });
      }
    });
  }

  Iterable<Text> loadLogs() {
    List<String> logs = widget.predictionModel.biotrainerTrainingLog ?? [];
    if (logs.isEmpty) {
      return [];
    }
    final int start = _loadedLogs.length;
    final int end = (start + _maxLoadedLogsPerStep).clamp(0, logs.length);
    return logs.sublist(start, end).map((log) => Text(log, maxLines: 2));
  }

  @override
  Widget build(BuildContext context) {
    return buildModel();
  }

  Widget buildModel() {
    BiotrainerTrainingResult? trainingResult = widget.predictionModel.biotrainerTrainingResult;
    String databaseType = "";
    if (widget.predictionModel.databaseType != null) {
      databaseType = "${widget.predictionModel.databaseType?.capitalize() ?? "Unknown"}-";
    }
    String title = "${databaseType}Model: ${widget.predictionModel.architecture ?? "Unknown architecture"} - "
        "${widget.predictionModel.embedderName ?? "Unknown Embeddings"} - "
        "${widget.predictionModel.predictionProtocol?.name ?? "Unknown protocol"}";
    return SizedBox(
      width: SizeConfig.screenWidth(context) * 0.95,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            child: ExpansionTile(leading: buildSanityCheckIcon(trainingResult), title: Text(title), children: [
          ExpansionTile(
            title: const Text("Model Information"),
            children: [buildModelInformation()],
          ),
          ExpansionTile(
            title: const Text("Metrics Table"),
            children: [buildMetricsTable(trainingResult)],
          ),
          ExpansionTile(title: const Text("Loss Curves"), children: buildLossCurves(trainingResult)),
          ExpansionTile(
            title: const Text("Available Checkpoints"),
            children: buildAvailableCheckpoints(),
          ),
          ExpansionTile(title: const Text("Training Logs"), children: buildLogResult())
        ])),
      ),
    );
  }

  Widget buildModelInformation() {
    Map<String, String> modelInformation = widget.predictionModel.getModelInformationMap();
    List<TableRow> rows = [];
    for (MapEntry<String, String> mapEntry in modelInformation.entries) {
      rows.add(TableRow(children: [Text(mapEntry.key), Text(mapEntry.value)]));
    }
    return Table(
      children: rows,
    );
  }

  Widget buildSanityCheckIcon(BiotrainerTrainingResult? trainingResult) {
    Set<String> sanityCheckWarnings = trainingResult?.sanityCheckWarnings ?? {};
    String tooltipMessage = "All sanity checks passed!";
    if (sanityCheckWarnings.isNotEmpty) {
      tooltipMessage = "Your model has the following sanity check warnings:";
      for (String warning in sanityCheckWarnings) {
        tooltipMessage += "\n$warning";
      }
    }
    Icon sanityCheckIcon = const Icon(Icons.check, color: Colors.green);
    if (sanityCheckWarnings.isNotEmpty) {
      sanityCheckIcon = const Icon(Icons.warning, color: Colors.red);
    }
    return BiocentralTooltip(message: tooltipMessage, child: sanityCheckIcon);
  }

  Widget buildMetricsTable(BiotrainerTrainingResult? trainingResult) {
    if (trainingResult == null) {
      return Container();
    }
    return BiocentralMetricsTable(
        metrics: {"Test Set Metrics": trainingResult.testSetMetrics}
          ..addAll(trainingResult.sanityCheckBaselineMetrics));
  }

  List<Widget> buildLossCurves(BiotrainerTrainingResult? trainingResult) {
    if (trainingResult == null) {
      return [Container()];
    }
    if (trainingResult.trainingLoss.isEmpty && trainingResult.validationLoss.isEmpty) {
      return [Container()];
    }
    final Map<String, Map<int, double>> linePlotData = {
      "Training": trainingResult.trainingLoss,
      "Validation": trainingResult.validationLoss
    };
    return [
      SizedBox(
        height: SizeConfig.safeBlockVertical(context) * 2,
      ),
      SizedBox(
          height: SizeConfig.screenHeight(context) * 0.3,
          width: SizeConfig.screenWidth(context) * 0.6,
          child: BiocentralLinePlot(data: linePlotData)),
      SizedBox(
        height: SizeConfig.safeBlockVertical(context) * 2,
      ),
    ];
  }

  List<Widget> buildAvailableCheckpoints() {
    List<String> checkpointNames = widget.predictionModel.biotrainerCheckpoints?.keys.toList() ?? [];
    if (checkpointNames.isEmpty) {
      return [Container()];
    }
    return checkpointNames.map((checkpointName) => Text(checkpointName)).toList();
  }

  List<Widget> buildLogResult() {
    if (widget.predictionModel.biotrainerTrainingLog?.isEmpty ?? true) {
      return [Container()];
    }
    return [
      SizedBox(
        height: SizeConfig.screenHeight(context) * 0.2,
        child: ListView.builder(
            itemCount: _loadedLogs.length,
            controller: _trainingLogsScrollController,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == _loadedLogs.length) {
                return const CircularProgressIndicator();
              }
              return _loadedLogs[index];
            }),
      )
    ];
  }
}
