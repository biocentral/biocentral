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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ALHubBloc, ALHubState>(
      buildWhen: (previous, current) => previous.proteinDatabase != current.proteinDatabase,
      builder: (context, state) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double columnWidth = (constraints.maxWidth - 100) / _alColumns.length - 1;
              return _buildGrid(columnWidth, state.proteinDatabase);
            },
          ),
        );
      },
    );
  }

  /// Builds the main grid widget with configured columns and rows
  Widget _buildGrid(double columnWidth, Map<String, Protein> proteinDatabase) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PlutoGrid(
        key: UniqueKey(),
        mode: plutoGridMode,
        columns: buildColumns(columnWidth),
        rows: buildRows(proteinDatabase),
      ),
    );
  }

  /// Builds and configures columns with the specified width
  List<PlutoColumn> buildColumns(double columnWidth) {
    var index = 0;
    final List<PlutoColumn> result = List.from(_alColumns);
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
  List<PlutoRow> buildRows(Map<String, Protein> proteinDatabase) {
    final lastIterationResult = widget.displayedResult?.results.toList() ?? [];
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
}
