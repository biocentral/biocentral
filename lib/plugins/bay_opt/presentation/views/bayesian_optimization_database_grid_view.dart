import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_training_result.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// A widget that displays Bayesian optimization results in a grid format.
/// Shows protein sequences, scores, uncertainties, and other metrics in a sortable and filterable table.
class BayesianOptimizationDatabaseGridView extends StatefulWidget {
  /// The training results data to be displayed
  final BayesianOptimizationTrainingResult? data;

  const BayesianOptimizationDatabaseGridView({
    this.data,
    super.key,
  });

  @override
  State<BayesianOptimizationDatabaseGridView> createState() => _BayesianOptimizationDatabaseGridViewState();
}

class _BayesianOptimizationDatabaseGridViewState extends State<BayesianOptimizationDatabaseGridView> {
  /// Default columns configuration for the grid
  static final List<PlutoColumn> _defaultBOColumns = <PlutoColumn>[
    _createColumn(
      title: 'Ranking',
      field: 'ranking',
      type: PlutoColumnType.text(),
    ),
    _createColumn(
      title: 'Protein ID',
      field: 'proteinId',
      type: PlutoColumnType.text(),
    ),
    _createColumn(
      title: 'Score',
      field: 'score',
      type: PlutoColumnType.number(format: '#,###.############'),
    ),
    _createColumn(
      title: 'Sequence',
      field: 'sequence',
      type: PlutoColumnType.text(),
    ),
    _createColumn(
      title: 'Uncertainty',
      field: 'uncertainty',
      type: PlutoColumnType.number(format: '#,###.############'),
    ),
    _createColumn(
      title: 'Prediction',
      field: 'mean',
      type: PlutoColumnType.number(format: '#,###.############'),
    ),
  ];

  /// Grid state manager for handling grid operations
  PlutoGridStateManager? stateManager;

  /// Grid mode configuration
  final PlutoGridMode plutoGridMode = PlutoGridMode.selectWithOneTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double columnWidth = (constraints.maxWidth - 100) / _defaultBOColumns.length - 1;
          return _buildGrid(columnWidth);
        },
      ),
    );
  }

  /// Builds the main grid widget with configured columns and rows
  Widget _buildGrid(double columnWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PlutoGrid(
        mode: plutoGridMode,
        columns: buildColumns(columnWidth),
        rows: buildRows(),
        onLoaded: _handleGridLoaded,
      ),
    );
  }

  /// Handles grid initialization and setup
  void _handleGridLoaded(PlutoGridOnLoadedEvent event) {
    stateManager ??= event.stateManager;
    stateManager!.setShowColumnFilter(true);
  }

  /// Creates a column with the specified configuration
  static PlutoColumn _createColumn({
    required String title,
    required String field,
    required PlutoColumnType type,
  }) {
    return PlutoColumn(
      title: title,
      field: field,
      type: type,
    );
  }

  /// Builds and configures columns with the specified width
  List<PlutoColumn> buildColumns(double columnWidth) {
    var index = 0;
    final List<PlutoColumn> result = List.from(_defaultBOColumns);
    for (PlutoColumn column in result) {
      if (index++ == 0) {
        column.width = 100;
        column.minWidth = 100;
      } else {
        column.width = columnWidth;
        column.minWidth = columnWidth;
      }
    }
    return result;
  }

  /// Builds rows from the training results data
  List<PlutoRow> buildRows() {
    if (widget.data?.results == null) {
      return [];
    }
    int index = 0;
    return widget.data!.results!.map((data) {
      return PlutoRow(
        cells: {
          'ranking': PlutoCell(value: ++index),
          'proteinId': PlutoCell(value: data.id),
          'score': PlutoCell(value: data.score),
          'sequence': PlutoCell(value: data.sequence),
          'uncertainty': PlutoCell(value: data.uncertainty),
          'mean': PlutoCell(value: data.mean),
        },
      );
    }).toList();
  }
}
