import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

class BiocentralMetricsTable extends StatefulWidget {
  final Map<String, Set<BiocentralMLMetric>> metrics;

  final String? initialSortingMetric;
  final String? prominentMetric;

  const BiocentralMetricsTable({required this.metrics, this.initialSortingMetric, this.prominentMetric, super.key});

  @override
  State<BiocentralMetricsTable> createState() => _BiocentralMetricsTableState();
}

class _BiocentralMetricsTableState extends State<BiocentralMetricsTable> {
  String? _sortedMetric;
  String? _prominentMetric;
  bool _ascending = false;
  bool _isExpanded = false;

  double _cellHeight = 50.0;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    _isExpanded = false;
    _ascending = false;
    _prominentMetric = widget.prominentMetric;
    // Set default sorting to first metric alphabetically
    final allMetricNames = widget.metrics.values.expand((metricSet) => metricSet.map((metric) => metric.name)).toSet();

    final String? metricToInitialSort = widget.initialSortingMetric ?? (allMetricNames.toList()..sort()).firstOrNull;
    if (metricToInitialSort != null) {
      _sortTableByMetricInitial(metricToInitialSort);
    }
  }

  @override
  void didUpdateWidget(covariant BiocentralMetricsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    initialize();
  }

  void _sortTableByMetricInitial(String metric) {
    setState(() {
      _sortedMetric = metric;
      _ascending = BiocentralMLMetric.isAscending(metric);
      _isExpanded = false;
      _prominentMetric = metric;
    });
  }

  void _sortTableByMetric(String metric) {
    setState(() {
      if (_sortedMetric == metric) {
        _ascending = !_ascending;
      } else {
        _sortTableByMetricInitial(metric);
      }
    });
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  TextStyle headerTextStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black, // Changed to black for better visibility
    );
  }

  TextStyle cellTextStyle() {
    return const TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.black, // Changed to black for better visibility
    );
  }

  @override
  Widget build(BuildContext context) {
    _cellHeight = SizeConfig.safeBlockVertical(context) * 5;

    final Set<String> allMetricNames =
        widget.metrics.values.expand((metricSet) => metricSet.map((metric) => metric.name)).toSet();

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
              columnWidths: _getColumnWidths(allMetricNames),
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

  Map<int, TableColumnWidth> _getColumnWidths(Set<String> allMetricNames) {
    if (_prominentMetric == null || _isExpanded) {
      return {
        0: const FlexColumnWidth(2),
        for (int i = 1; i <= allMetricNames.length; i++) i: const FlexColumnWidth(),
      };
    } else {
      return {
        0: const FlexColumnWidth(2),
        1: const FlexColumnWidth(2),
        2: const FlexColumnWidth(),
      };
    }
  }

  TableRow _buildHeaderRow(Set<String> metricNames) {
    final List<Widget> cells = [_buildCell('Dataset', isHeader: true)];

    if (_prominentMetric != null) {
      cells.add(_buildHeaderCell(_prominentMetric!));
      if (!_isExpanded) {
        cells.add(_buildExpandCell());
      } else {
        cells.addAll(metricNames.where((m) => m != _prominentMetric).map((metric) => _buildHeaderCell(metric)));
      }
    } else {
      cells.addAll(metricNames.map((metric) => _buildHeaderCell(metric)));
    }

    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      children: cells,
    );
  }

  Widget _buildHeaderCell(String metric) {
    return InkWell(
      onTap: () => _sortTableByMetric(metric),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        height: _cellHeight,
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

  Widget _buildExpandCell() {
    return TableCell(
      child: InkWell(
        onTap: _toggleExpanded,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          height: _cellHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(angle: 90 * pi / 180, child: const Icon(Icons.expand, color: Colors.black)),
              Text(
                '  Expand',
                style: headerTextStyle().copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TableRow> _buildSortedMetrics(Set<String> allMetricNames) {
    if (widget.metrics.isEmpty) {
      return [
        const TableRow(children: [Text('No data available yet!')])
      ];
    }

    final entries = widget.metrics.entries.toList();

    if (_sortedMetric != null) {
      entries.sort((a, b) {
        final valueA = a.value
            .firstWhere(
              (m) => m.name == _sortedMetric,
              orElse: () => BiocentralMLMetric(name: _sortedMetric!, value: double.nan),
            )
            .value;
        final valueB = b.value
            .firstWhere(
              (m) => m.name == _sortedMetric,
              orElse: () => BiocentralMLMetric(name: _sortedMetric!, value: double.nan),
            )
            .value;

        if (valueA.isNaN && valueB.isNaN) return 0;
        if (valueA.isNaN) return _ascending ? -1 : 1;
        if (valueB.isNaN) return _ascending ? 1 : -1;

        return _ascending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
      });
    }

    return entries.map((entry) => _buildDataRow(entry.key, entry.value, allMetricNames)).toList();
  }

  TableRow _buildDataRow(String datasetName, Set<BiocentralMLMetric> datasetMetrics, Set<String> allMetricNames) {
    final List<Widget> cells = [_buildCell(datasetName)];

    if (_prominentMetric != null) {
      final prominentMetric = datasetMetrics.firstWhere(
        (m) => m.name == _prominentMetric,
        orElse: () => BiocentralMLMetric(name: _prominentMetric!, value: double.nan),
      );
      cells.add(_buildCell(
        prominentMetric.value.isNaN ? 'N/A' : prominentMetric.value.toStringAsPrecision(Constants.maxDoublePrecision),
      ));

      if (_isExpanded) {
        cells.addAll(allMetricNames.where((m) => m != _prominentMetric).map((metricName) {
          final metric = datasetMetrics.firstWhere(
            (m) => m.name == metricName,
            orElse: () => BiocentralMLMetric(name: metricName, value: double.nan),
          );
          return _buildCell(
            metric.value.isNaN ? 'N/A' : metric.value.toStringAsPrecision(Constants.maxDoublePrecision),
          );
        }));
      } else {
        cells.add(_buildCell('')); // Empty cell for collapsed state
      }
    } else {
      cells.addAll(allMetricNames.map((metricName) {
        final metric = datasetMetrics.firstWhere(
          (m) => m.name == metricName,
          orElse: () => BiocentralMLMetric(name: metricName, value: double.nan),
        );
        return _buildCell(
          metric.value.isNaN ? 'N/A' : metric.value.toStringAsPrecision(Constants.maxDoublePrecision),
        );
      }));
    }

    return TableRow(children: cells);
  }

  Widget _buildCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      height: _cellHeight,
      child: AutoSizeText(
        text,
        style: isHeader ? headerTextStyle() : cellTextStyle(),
        maxLines: isHeader ? 3 : 1,
        minFontSize: 8,
        textAlign: TextAlign.center,
      ),
    );
  }
}
