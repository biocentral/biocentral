import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_metrics_plot.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';

class BiocentralMetricsDisplay extends StatefulWidget {
  final Map<String, Set<BiocentralMLMetric>> metrics;

  const BiocentralMetricsDisplay({required this.metrics, super.key});

  @override
  State<BiocentralMetricsDisplay> createState() => _BiocentralMetricsDisplayState();
}

class _BiocentralMetricsDisplayState extends State<BiocentralMetricsDisplay> {
  bool _showMetricsAsTable = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight * 0.2,
                child: BiocentralDiscreteSelection<String>(
                  title: 'Display',
                  initialValue: _showMetricsAsTable ? 'Table' : 'Plot',
                  selectableValues: ['Table', 'Plot'],
                  onChangedCallback: (String? value) {
                    setState(() {
                      _showMetricsAsTable = value == 'Table';
                    });
                  },
                ),
              ),
              SizedBox(
                width: constraints.maxWidth * 0.95,
                height: constraints.maxHeight * 0.9,
                child: _showMetricsAsTable ? buildMetricsTable() : buildMetricsPlot(),
              ),
            ].withPadding(
              const Padding(
                padding: EdgeInsets.all(8.0),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildMetricsTable() {
    return BiocentralMetricsTable(metrics: widget.metrics);
  }

  Widget buildMetricsPlot() {
    return BiocentralMetricsPlot(metrics: widget.metrics);
  }
}
