import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_training_result.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class BayesianOptimizationAddExperimentalDataDialog extends StatefulWidget {
  final BayesianOptimizationTrainingResult currentResult;
  final void Function(Map<String, dynamic>? experimentalData) onFinishedAddingData;

  const BayesianOptimizationAddExperimentalDataDialog({
    required this.currentResult,
    required this.onFinishedAddingData,
    super.key,
  });

  @override
  State<BayesianOptimizationAddExperimentalDataDialog> createState() =>
      _BayesianOptimizationAddExperimentalDataDialogState();
}

class _BayesianOptimizationAddExperimentalDataDialogState extends State<BayesianOptimizationAddExperimentalDataDialog> {
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
  }

  List<PlutoColumn> buildColumns() {
    return [
      PlutoColumn(
        title: 'Ranking',
        field: 'ranking',
        type: PlutoColumnType.number(format: '#'),
        width: 100,
        enableEditingMode: false,
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            type: PlutoAggregateColumnType.count,
            format: '#',
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(
                  text: 'Count: ',
                ),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
      PlutoColumn(
        title: 'ID',
        field: 'id',
        type: PlutoColumnType.text(),
        width: 150,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Prediction',
        field: 'prediction',
        type: PlutoColumnType.number(format: '#,###.############'),
        width: 150,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Lab Value',
        field: 'experiment',
        type: PlutoColumnType.text(),
        width: 150,
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            type: PlutoAggregateColumnType.count,
            filter: (PlutoCell plutoCell) =>
                plutoCell.value != 'N/A' && double.tryParse(plutoCell.value.toString()) != null,
            format: '#',
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(
                  text: 'Added: ',
                ),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
    ];
  }

  List<PlutoRow> buildRows() {
    return widget.currentResult.results.indexed
        .map(
          (indexedResultData) => PlutoRow(
            cells: {
              'ranking': PlutoCell(value: indexedResultData.$1 + 1),
              'id': PlutoCell(value: indexedResultData.$2.id),
              'prediction': PlutoCell(value: indexedResultData.$2.prediction),
              'experiment': PlutoCell(value: widget.currentResult.experimentalData[indexedResultData.$2.id] ?? 'N/A'),
            },
          ),
        )
        .toList();
  }

  Map<String, double> collectInputValues() {
    final Map<String, double> inputMap = {}; // TODO True/False values
    for (final row in stateManager.iterateAllRow) {
      final id = row.cells['id']?.value;
      final input = row.cells['experiment']?.value;
      final parsedInput = double.tryParse(input.toString());
      if (id != null && parsedInput != null) {
        // TODO [Error Handling] Improve user feedback
        inputMap[id.toString()] = parsedInput;
      }
    }
    return inputMap;
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 550,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Add experimentally verified data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PlutoGrid(
                columns: buildColumns(),
                rows: buildRows(),
                onLoaded: (event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    stateManager.setEditing(false);
                    widget.onFinishedAddingData(collectInputValues());
                    closeDialog();
                  },
                  child: const Text('Add new data to database'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
