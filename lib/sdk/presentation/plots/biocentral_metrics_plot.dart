import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_bar_plot.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class BiocentralMetricsPlot extends StatefulWidget {
  final Map<String, Set<BiocentralMLMetric>> metrics;

  const BiocentralMetricsPlot({required this.metrics, super.key});

  @override
  State<BiocentralMetricsPlot> createState() => _BiocentralMetricsPlotState();
}

class _BiocentralMetricsPlotState extends State<BiocentralMetricsPlot> {
  final Set<String> _availableMetrics = {};

  String? _selectedMetric;

  @override
  void initState() {
    super.initState();
    for (final setVal in widget.metrics.values) {
      _availableMetrics.addAll(setVal.map((metric) => metric.name));
    }
    _selectedMetric = _availableMetrics.firstOrNull;
  }

  List<(String, double, double?)> _getBarPlotData() {
    final result = <(String, double, double?)>[];
    for (final entry in widget.metrics.entries) {
      final metric = entry.value.firstWhereOrNull((m) => m.name == _selectedMetric);
      if(metric != null) {
        result.add((entry.key, metric.value, metric.uncertaintyEstimate?.error));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 4,
          child: BiocentralDiscreteSelection<String>(
            title: 'Available metrics',
            initialValue: _selectedMetric,
            selectableValues: _availableMetrics.toList(),
            onChangedCallback: (String? value) {
              setState(() {
                _selectedMetric = value;
              });
            },
          ),
        ),
        if (_selectedMetric != null)
          Flexible(
            flex: 5,
            child: BiocentralBarPlot(
              data: BiocentralBarPlotData.withErrors(_getBarPlotData()),
              maxLabelLength: 30,
            ),
          ),
      ],
    );
  }
}
