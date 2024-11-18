import 'dart:math';

import 'package:flutter/material.dart';
import 'package:biocentral/sdk/model/biocentral_ml_metrics.dart';
import 'package:biocentral/sdk/util/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';

class BiocentralMetricsTable extends StatefulWidget {
  final Map<String, Set<BiocentralMLMetric>> metrics;

  const BiocentralMetricsTable({required this.metrics, super.key});

  @override
  State<BiocentralMetricsTable> createState() => _BiocentralMetricsTableState();
}

class _BiocentralMetricsTableState extends State<BiocentralMetricsTable> {
  String? _sortedMetric;
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    // Set default sorting to first metric alphabetically
    final allMetricNames = widget.metrics.values
        .expand((metricSet) => metricSet.map((metric) => metric.name))
        .toSet();
    if (allMetricNames.isNotEmpty) {
      final metricsListSorted = allMetricNames.toList()..sort();
      _sortedMetric = metricsListSorted.first;
    }
  }

  void _sortTableByMetric(String metric) {
    setState(() {
      if (_sortedMetric == metric) {
        _ascending = !_ascending;
      } else {
        _sortedMetric = metric;
        _ascending = BiocentralMLMetric.isAscending(metric);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> allMetricNames = widget.metrics.values
        .expand((metricSet) => metricSet.map((metric) => metric.name))
        .toSet();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: {
                0: const FlexColumnWidth(2),
                ...(List.generate(max(0, widget.metrics.length - 1), (_) => const FlexColumnWidth()))
                    .asMap()
                    .map((k, v) => MapEntry(k + 1, v)),
              },
              children: [
                _buildHeaderRow(allMetricNames),
                ..._buildSortedMetrics(allMetricNames),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildHeaderRow(Set<String> metricNames) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      children: [
        _buildCell('Dataset', isHeader: true),
        ...metricNames.map((metric) => _buildHeaderCell(metric)),
      ],
    );
  }

  Widget _buildHeaderCell(String metric) {
    return InkWell(
      onTap: () => _sortTableByMetric(metric),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: AutoSizeText(
                metric,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                maxLines: 3,
                minFontSize: 8,
                textAlign: TextAlign.center,
              ),
            ),
            if (_sortedMetric == metric)
              Icon(
                _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _buildSortedMetrics(Set<String> allMetricNames) {
    if(widget.metrics.isEmpty) {
      return [const TableRow(children: [Text('No data available yet!')])];
    }

    final entries = widget.metrics.entries.toList();

    if (_sortedMetric != null) {
      entries.sort((a, b) {
        final valueA = a.value.firstWhere(
              (m) => m.name == _sortedMetric,
          orElse: () => BiocentralMLMetric(name: _sortedMetric!, value: double.nan),
        ).value;
        final valueB = b.value.firstWhere(
              (m) => m.name == _sortedMetric,
          orElse: () => BiocentralMLMetric(name: _sortedMetric!, value: double.nan),
        ).value;

        if (valueA.isNaN && valueB.isNaN) return 0;
        if (valueA.isNaN) return _ascending ? -1 : 1;
        if (valueB.isNaN) return _ascending ? 1 : -1;

        return _ascending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
      });
    }

    return entries.map((entry) => _buildDataRow(entry.key, entry.value, allMetricNames)).toList();
  }

  TableRow _buildDataRow(String datasetName, Set<BiocentralMLMetric> datasetMetrics, Set<String> allMetricNames) {
    return TableRow(
      children: [
        _buildCell(datasetName),
        ...allMetricNames.map((metricName) {
          final metric = datasetMetrics.firstWhere(
                (m) => m.name == metricName,
            orElse: () => BiocentralMLMetric(name: metricName, value: double.nan),
          );
          return _buildCell(
            metric.value.isNaN ? 'N/A' : metric.value.toStringAsPrecision(Constants.maxDoublePrecision),
          );
        }),
      ],
    );
  }

  Widget _buildCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      height: 50,
      child: AutoSizeText(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black : Colors.black, // Changed to black for better visibility
        ),
        maxLines: isHeader ? 3 : 1,
        minFontSize: 8,
        textAlign: TextAlign.center,
      ),
    );
  }
}
