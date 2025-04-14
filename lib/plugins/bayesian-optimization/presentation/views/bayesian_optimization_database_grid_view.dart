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
  });

  @override
  State<BayesianOptimizationDatabaseGridView> createState() => _BayesianOptimizationDatabaseGridViewState();
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
      title: 'Score',
      field: 'score',
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
      title: 'Sequence',
      field: 'sequence',
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
          'score': PlutoCell(value: data.score),
          'sequence': PlutoCell(value: data.sequence),
          'uncertainty': PlutoCell(value: data.uncertainty),
          'prediction': PlutoCell(value: data.prediction)
        },
      );

      rows.add(row);
    }
    return rows;
  }
}
