import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/sdk/util/constants.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// A widget that displays Active Learning results in a grid format.
/// Shows protein sequences, scores, uncertainties, and other metrics in a sortable and filterable table.
/// When [displayedResult] is null, shows all iterations combined with an Iteration column.
class ALDatabaseGridView extends StatefulWidget {
  final ALCampaign campaign;
  final ActiveLearningIterationResult? displayedResult;

  const ALDatabaseGridView({
    required this.campaign,
    required this.displayedResult,
    super.key,
  });

  @override
  State<ALDatabaseGridView> createState() => _ALDatabaseGridViewState();
}

class _ALDatabaseGridViewState extends State<ALDatabaseGridView> {
  /// Default columns configuration for the grid
  final List<PlutoColumn> _alColumns = <PlutoColumn>[
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

  bool get _showAllIterations => widget.displayedResult == null;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ALHubBloc, ALHubState>(
      buildWhen: (previous, current) => previous.proteinDatabase != current.proteinDatabase,
      builder: (context, state) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final columns = buildColumns(constraints.maxWidth);
              return _buildGrid(columns, state.proteinDatabase);
            },
          ),
        );
      },
    );
  }

  /// Builds the main grid widget with configured columns and rows
  Widget _buildGrid(List<PlutoColumn> columns, Map<String, Protein> proteinDatabase) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PlutoGrid(
        key: UniqueKey(),
        mode: plutoGridMode,
        columns: columns,
        rows: _showAllIterations ? buildAllRows(proteinDatabase) : buildRows(proteinDatabase),
      ),
    );
  }

  List<PlutoColumn> buildColumns(double availableWidth) {
    final allCols = <PlutoColumn>[
      if (_showAllIterations)
        PlutoColumn(
          title: 'Iteration',
          field: 'iteration',
          readOnly: true,
          width: 90,
          minWidth: 90,
          type: PlutoColumnType.number(),
        ),
      ..._alColumns,
    ];

    final fixedWidth = _showAllIterations ? 90.0 + 100.0 : 100.0; // iteration col + ranking col
    final remainingCols = allCols.length - (_showAllIterations ? 2 : 1);
    final columnWidth = (availableWidth - fixedWidth - 100) / remainingCols - 1;

    var index = 0;
    for (final column in allCols) {
      if (column.field == 'iteration') {
        index++;
        continue;
      }
      if (index == (_showAllIterations ? 1 : 0)) {
        column.width = 100;
        column.minWidth = 100;
      } else {
        column.width = columnWidth;
        column.minWidth = columnWidth;
      }
      index++;
    }
    return allCols;
  }

  /// Builds rows from the training results data
  List<PlutoRow> buildRows(Map<String, Protein> proteinDatabase) {
    final suggestionSet = widget.displayedResult?.suggestions.toSet() ?? {};
    final lastIterationResult = widget.displayedResult?.results
        .where((r) => suggestionSet.contains(r.entityId))
        .toList() ?? [];
    if (lastIterationResult.isEmpty) {
      return [];
    }
    int index = 0;
    return lastIterationResult.map((alResult) {
      final experimentalValue = proteinDatabase[alResult.entityId]?.attributes[widget.campaign.columnName];
      return PlutoRow(
        cells: {
          'ranking': PlutoCell(value: ++index),
          'proteinId': PlutoCell(value: alResult.entityId),
          'score': PlutoCell(value: alResult.score.toStringAsFixed(Constants.maxDoublePrecision)),
          'uncertainty': PlutoCell(value: alResult.uncertainty.toStringAsFixed(Constants.maxDoublePrecision)),
          'prediction': PlutoCell(value: alResult.prediction),
          'experiment': PlutoCell(value: experimentalValue ?? ''),
        },
      );
    }).toList();
  }

  List<PlutoRow> buildAllRows(Map<String, Protein> proteinDatabase) {
    final rows = <PlutoRow>[];
    int index = 0;
    for (final (_, iterResult) in widget.campaign.iterationResults) {
      final suggestionSet = iterResult.suggestions.toSet();
      final suggestions = iterResult.results.where((r) => suggestionSet.contains(r.entityId)).toList();
      for (final alResult in suggestions) {
        final experimentalValue = proteinDatabase[alResult.entityId]?.attributes[widget.campaign.columnName];
        rows.add(PlutoRow(
          cells: {
            'iteration': PlutoCell(value: iterResult.iteration),
            'ranking': PlutoCell(value: ++index),
            'proteinId': PlutoCell(value: alResult.entityId),
            'score': PlutoCell(value: alResult.score.toStringAsFixed(Constants.maxDoublePrecision)),
            'uncertainty': PlutoCell(value: alResult.uncertainty.toStringAsFixed(Constants.maxDoublePrecision)),
            'prediction': PlutoCell(value: alResult.prediction),
            'experiment': PlutoCell(value: experimentalValue ?? ''),
          },
        ),);
      }
    }
    return rows;
  }
}
