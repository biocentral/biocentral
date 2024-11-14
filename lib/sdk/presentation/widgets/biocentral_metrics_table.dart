import 'package:flutter/material.dart';

import 'package:biocentral/sdk/model/biocentral_ml_metrics.dart';
import 'package:biocentral/sdk/util/constants.dart';

class BiocentralMetricsTable extends StatefulWidget {
  final Map<String, Set<BiocentralMLMetric>> metrics;

  const BiocentralMetricsTable({required this.metrics, super.key});

  @override
  State<BiocentralMetricsTable> createState() => _BiocentralMetricsTableState();
}

class _BiocentralMetricsTableState extends State<BiocentralMetricsTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      children: buildRows(),
    );
  }

  List<TableRow> buildRows() {
    final List<TableRow> result = [];
    // Names on top of table
    result.add(TableRow(children: [const Text(''), ...widget.metrics.keys.map((key) => Text(key))]));

    // We need to iterate over each metric for every key to build the table with the correct rows
    final Set<String> allMetricNames =
        widget.metrics.values.expand((metricSet) => metricSet.map((metric) => metric.name)).toSet();

    final Map<String, List<Text>> mlMetricValues = {};
    for (String key in widget.metrics.keys) {
      // Remapping for fast access in for loop
      final Map<String, BiocentralMLMetric> availableMetricsForKey =
          Map.fromEntries(widget.metrics[key]!.map((metric) => MapEntry(metric.name, metric)));

      for (String metric in allMetricNames) {
        mlMetricValues.putIfAbsent(metric, () => []);
        if (availableMetricsForKey.keys.contains(metric)) {
          mlMetricValues[metric]?.add(
              Text(availableMetricsForKey[metric]?.value.toStringAsPrecision(Constants.maxDoublePrecision) ?? ''),);
        } else {
          mlMetricValues[metric]?.add(const Text('N/A'));
        }
      }
    }

    for (MapEntry<String, List<Text>> entry in mlMetricValues.entries) {
      result.add(TableRow(children: [Text(entry.key), ...entry.value]));
    }
    return result;
  }
}
