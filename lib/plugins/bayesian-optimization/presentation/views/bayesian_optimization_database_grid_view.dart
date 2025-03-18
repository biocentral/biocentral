import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class BayesianOptimizationDatabaseGridView extends StatefulWidget {
  String yLabel;
  String xLabel;
  BayesianOptimizationTrainingResult? data;

  BayesianOptimizationDatabaseGridView({
    required this.yLabel,
    required this.xLabel,
    this.data,
    super.key,
  }) {
    data = data ?? dummyData;
  }

  @override
  State<BayesianOptimizationDatabaseGridView> createState() => _BayesianOptimizationDatabaseGridViewState();

  // Dummy list of PlotData
// Dummy list of PlotData
  final BayesianOptimizationTrainingResult dummyData = const BayesianOptimizationTrainingResult(
    results: [
      BayesianOptimizationTrainingResultData(proteinId: '1', prediction: 32, uncertainty: -1.4, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '2', prediction: 35, uncertainty: -1.0, utility: -1.2),
      BayesianOptimizationTrainingResultData(proteinId: '3', prediction: 37, uncertainty: -0.8, utility: -0.5),
      BayesianOptimizationTrainingResultData(proteinId: '4', prediction: 40, uncertainty: -0.5, utility: -0.2),
      BayesianOptimizationTrainingResultData(proteinId: '5', prediction: 42, uncertainty: -0.2, utility: 0.0),
      BayesianOptimizationTrainingResultData(proteinId: '6', prediction: 45, uncertainty: 0.0, utility: 0.2),
      BayesianOptimizationTrainingResultData(proteinId: '7', prediction: 47, uncertainty: 0.2, utility: 0.5),
      BayesianOptimizationTrainingResultData(proteinId: '8', prediction: 50, uncertainty: 0.5, utility: 0.8),
      BayesianOptimizationTrainingResultData(proteinId: '9', prediction: 52, uncertainty: 0.8, utility: 1.0),
      BayesianOptimizationTrainingResultData(proteinId: '10', prediction: 55, uncertainty: 1.0, utility: 1.5),
      BayesianOptimizationTrainingResultData(proteinId: '11', prediction: 32, uncertainty: -1.5, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '12', prediction: 35, uncertainty: -1.1, utility: -1.2),
      BayesianOptimizationTrainingResultData(proteinId: '13', prediction: 37, uncertainty: -0.1, utility: -0.5),
      BayesianOptimizationTrainingResultData(proteinId: '14', prediction: 40, uncertainty: -0.2, utility: -0.2),
      BayesianOptimizationTrainingResultData(proteinId: '15', prediction: 42, uncertainty: -0.5, utility: 1.0),
      BayesianOptimizationTrainingResultData(proteinId: '16', prediction: 45, uncertainty: 0.5, utility: 1.2),
      BayesianOptimizationTrainingResultData(proteinId: '17', prediction: 47, uncertainty: 0.6, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '18', prediction: 50, uncertainty: 0.1, utility: 0.8),
    ],
  );
}

class _BayesianOptimizationDatabaseGridViewState extends State<BayesianOptimizationDatabaseGridView> {
  static final List<PlutoColumn> _defaultBOColumns = <PlutoColumn>[
    PlutoColumn(
      title: 'Protein ID',
      field: 'proteinId',
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
      title: 'Prediction',
      field: 'prediction',
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
      title: 'Uncertainty',
      field: 'uncertainty',
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
      title: 'Utility',
      field: 'utility',
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
    if (widget.data == null || widget.data!.results == null) {
      return rows;
    }
    final List<BayesianOptimizationTrainingResultData> results = widget.data!.results!;
    for (BayesianOptimizationTrainingResultData data in results) {
      final PlutoRow row = PlutoRow(
        cells: {
          'proteinId': PlutoCell(value: data.proteinId),
          'prediction': PlutoCell(value: data.prediction),
          'uncertainty': PlutoCell(value: data.uncertainty),
          'utility': PlutoCell(value: data.utility),
        },
      );

      rows.add(row);
    }
    return rows;
  }
}
