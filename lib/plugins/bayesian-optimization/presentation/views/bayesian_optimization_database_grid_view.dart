import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pluto_grid/pluto_grid.dart';

class BayesianOptimizationDatabaseGridView extends StatefulWidget {
  String yLabel;
  String xLabel;
  List<PlotData>? plotData;

  BayesianOptimizationDatabaseGridView({
    required this.yLabel,
    required this.xLabel,
    this.plotData,
    super.key,
  }) {
    plotData = plotData ?? dummyData;
  }

  @override
  State<BayesianOptimizationDatabaseGridView> createState() =>
      _BayesianOptimizationDatabaseGridViewState();

  // Dummy list of PlotData
  final List<PlotData> dummyData = [
    PlotData(row: 1, x: 32, y: -1.4, utility: -1.5),
    PlotData(row: 2, x: 35, y: -1.0, utility: -1.2),
    PlotData(row: 3, x: 37, y: -0.8, utility: -0.5),
    PlotData(row: 4, x: 40, y: -0.5, utility: -0.3),
    PlotData(row: 5, x: 42, y: -0.2, utility: -0.1),
    PlotData(row: 6, x: 45, y: 0.0, utility: 0.0),
    PlotData(row: 7, x: 48, y: 0.3, utility: 0.1),
    PlotData(row: 8, x: 50, y: 0.5, utility: 0.5),
    PlotData(row: 9, x: 52, y: 0.7, utility: 0.8),
    PlotData(row: 10, x: 55, y: 0.9, utility: 1.0),
    PlotData(row: 11, x: 57, y: 0.6, utility: 0.7),
    PlotData(row: 12, x: 60, y: 0.3, utility: 0.2),
    PlotData(row: 13, x: 40, y: -1.5, utility: -1.4),
    PlotData(row: 14, x: 55, y: -0.5, utility: -0.2),
    PlotData(row: 15, x: 50, y: -1.2, utility: -1.0),
  ];
}

class _BayesianOptimizationDatabaseGridViewState
    extends State<BayesianOptimizationDatabaseGridView> {
  static final List<PlutoColumn> _defaultBOColumns = <PlutoColumn>[
    PlutoColumn(
      title: 'Protein ID',
      field: 'id',
      type: PlutoColumnType.text(),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.count,
          format: '#',
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'N',
                style: TextStyle(color: Colors.green),
              ),
              const TextSpan(text: ': '),
              TextSpan(text: text),
            ];
          },
        );
      },
    ),
    PlutoColumn(
      title: 'Taxonomy ID',
      field: 'taxonomyID',
      type: PlutoColumnType.number(defaultValue: -1),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.count,
          filter: (PlutoCell plutoCell) => plutoCell.value == -1,
          format: '#',
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'Missing',
                style: TextStyle(color: Colors.red),
              ),
              const TextSpan(text: ': '),
              TextSpan(text: text),
            ];
          },
        );
      },
    ),
    PlutoColumn(
      title: 'Species Name',
      field: 'taxonomyName',
      type: PlutoColumnType.text(),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.count,
          filter: (PlutoCell plutoCell) => plutoCell.value == '',
          format: '#',
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'Missing',
                style: TextStyle(color: Colors.red),
              ),
              const TextSpan(text: ': '),
              TextSpan(text: text),
            ];
          },
        );
      },
    ),
    PlutoColumn(
      title: 'Family Name',
      field: 'taxonomyFamily',
      type: PlutoColumnType.text(),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.count,
          filter: (PlutoCell plutoCell) => plutoCell.value == '',
          format: '#',
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'Missing',
                style: TextStyle(color: Colors.red),
              ),
              const TextSpan(text: ': '),
              TextSpan(text: text),
            ];
          },
        );
      },
    ),
    //PlutoColumn(title: 'Target', field: 'target', type: PlutoColumnType.text()),
    //PlutoColumn(title: 'Set', field: 'set', type: PlutoColumnType.text())
  ];

  PlutoGridStateManager? stateManager;
  final PlutoGridMode plutoGridMode = PlutoGridMode.selectWithOneTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;
          final double columnWidth = totalWidth / _defaultBOColumns.length;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PlutoGrid(
              mode: plutoGridMode,
              columns: buildColumns(columnWidth),
              rows: buildRows(),
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager ??= event.stateManager;
                stateManager!.setShowColumnFilter(true);
              },
            ),
          );
        },
      ),
    );
  }

  List<PlutoColumn> buildColumns(double columnWidth) {
    final List<PlutoColumn> result = List.from(_defaultBOColumns);
    for (PlutoColumn column in result) {
      column.width = columnWidth;
      column.minWidth = columnWidth;
    }
    return result;
  }

  List<PlutoRow> buildRows() {
    final List<PlutoRow> rows = List.empty(growable: true);
    for (PlotData data in widget.plotData!) {
      final PlutoRow row = PlutoRow(
        cells: {
          'id': PlutoCell(value: data.row),
          'taxonomyID': PlutoCell(value: data.x),
          'taxonomyName': PlutoCell(value: data.y),
          'taxonomyFamily': PlutoCell(value: data.utility),
        },
      );

      rows.add(row);
    }
    return rows;
  }

  List<ScatterSpot> getData(List<PlotData> plotData) {
    final List<ScatterSpot> scatterSpots = [];

    // Map the dummyData to ScatterSpot
    for (var data in plotData) {
      final Color pointColor = getColorBasedOnUtility(data.utility);

      scatterSpots.add(
        ScatterSpot(
          data.x,
          data.y,
          show: true,
          dotPainter: FlDotCirclePainter(
            radius: 8,
            color: pointColor,
          ),
        ),
      );
    }

    return scatterSpots;
  }

// Function to assign colors based on utility value
  Color getColorBasedOnUtility(double utility) {
    if (utility <= -1.0) {
      return Colors.blue; // Low utility
    } else if (utility <= 0.0) {
      return Colors.purple;
    } else if (utility <= 0.5) {
      return Colors.red;
    } else if (utility <= 1.0) {
      return Colors.orange;
    } else {
      return Colors.yellow; // High utility
    }
  }

  MinMaxValues minMax(List<PlotData>? plotData) {
    double minX = 99999;
    double minY = 99999;
    double maxX = -99999;
    double maxY = -99999;

    for (var data in plotData!) {
      if (data.x < minX) {
        minX = data.x;
      }
      if (data.y < minY) {
        minY = data.y;
      }
      if (data.x > maxX) {
        maxX = data.x;
      }
      if (data.y > maxY) {
        maxY = data.y;
      }
    }

    return MinMaxValues(minX: minX, minY: minY, maxX: maxX, maxY: maxY);
  }
}

// Define a class to hold Row, X, Y, and Utility
class PlotData {
  final int row;
  final double x;
  final double y;
  final double utility;

  PlotData({
    required this.row,
    required this.x,
    required this.y,
    required this.utility,
  });
}

class MinMaxValues {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  MinMaxValues({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  double get getMinX => minX - 1;
  double get getMinY => minY - 1;
  double get getMaxX => maxX + 1;
  double get getMaxY => maxY + 1;
}
