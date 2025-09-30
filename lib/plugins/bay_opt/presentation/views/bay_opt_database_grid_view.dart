import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_hub_bloc.dart';
import 'package:biocentral/sdk/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// A widget that displays Bayesian optimization results in a grid format.
/// Shows protein sequences, scores, uncertainties, and other metrics in a sortable and filterable table.
class BayOptDatabaseGridView extends StatefulWidget {
  const BayOptDatabaseGridView({
    super.key,
  });

  @override
  State<BayOptDatabaseGridView> createState() => _BayOptDatabaseGridViewState();
}

class _BayOptDatabaseGridViewState extends State<BayOptDatabaseGridView> {
  /// Default columns configuration for the grid
  final List<PlutoColumn> _boColumns = <PlutoColumn>[
    PlutoColumn(
      title: 'Ranking',
      field: 'ranking',
      readOnly: true,
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Protein ID',
      field: 'proteinId',
      readOnly: true,
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Score',
      field: 'score',
      readOnly: true,
      type: PlutoColumnType.number(format: '#,###.############'),
    ),
    PlutoColumn(
      title: 'Sequence',
      field: 'sequence',
      readOnly: true,
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Uncertainty',
      field: 'uncertainty',
      readOnly: true,
      type: PlutoColumnType.number(format: '#,###.############'),
    ),
    PlutoColumn(
      title: 'Prediction',
      field: 'prediction',
      readOnly: true,
      type: PlutoColumnType.number(format: '#,###.############'),
    ),
    PlutoColumn(
      title: 'Experiment',
      field: 'experiment',
      readOnly: true,
      type: PlutoColumnType.text(),
    ),
  ];

  /// Grid mode configuration
  final PlutoGridMode plutoGridMode = PlutoGridMode.selectWithOneTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BayOptHubBloc, BayOptHubState>(
        builder: (context, hubState) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final double columnWidth = (constraints.maxWidth - 100) / _boColumns.length - 1;
              return _buildGrid(hubState, columnWidth);
            },
          );
        },
      ),
    );
  }

  /// Builds the main grid widget with configured columns and rows
  Widget _buildGrid(BayOptHubState hubState, double columnWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PlutoGrid(
        key: UniqueKey(),
        mode: plutoGridMode,
        columns: buildColumns(columnWidth),
        rows: buildRows(hubState),
      ),
    );
  }

  /// Builds and configures columns with the specified width
  List<PlutoColumn> buildColumns(double columnWidth) {
    var index = 0;
    final List<PlutoColumn> result = List.from(_boColumns);
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
  List<PlutoRow> buildRows(BayOptHubState hubState) {
    final selectedResult = hubState.selectedResult;
    if (selectedResult == null || selectedResult.results.isEmpty) {
      return [];
    }
    int index = 0;
    final experimentalData = selectedResult.experimentalData;
    return selectedResult.results.map((data) {
      return PlutoRow(
        cells: {
          'ranking': PlutoCell(value: ++index),
          'proteinId': PlutoCell(value: data.id),
          'score': PlutoCell(value: data.score.toStringAsFixed(Constants.maxDoublePrecision)),
          'sequence': PlutoCell(value: ''), // TODO Get sequence from database
          'uncertainty': PlutoCell(value: data.uncertainty.toStringAsFixed(Constants.maxDoublePrecision)),
          'prediction': PlutoCell(value: data.prediction.toStringAsFixed(Constants.maxDoublePrecision)),
          'experiment': PlutoCell(value: experimentalData[data.id] ?? 'N/A'),
        },
      );
    }).toList();
  }
}
