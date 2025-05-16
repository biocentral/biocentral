import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class IterateTrainingDialog extends StatefulWidget {
  final BayesianOptimizationTrainingResult currentResult;
  final Function(List<double?>) onStartIteration;
  final Function(List<double?>) onStartDirectIteration;

  const IterateTrainingDialog({
    required this.currentResult,
    required this.onStartIteration,
    required this.onStartDirectIteration,
    super.key,
  });

  @override
  State<IterateTrainingDialog> createState() => _IterateTrainingDialogState();
}

class _IterateTrainingDialogState extends State<IterateTrainingDialog> {
  late PlutoGridStateManager stateManager;
  late BayesianOptimizationTrainingResult editedResult;
  List<double?> inputList = [];

  @override
  void initState() {
    super.initState();
    editedResult = widget.currentResult;
    inputList = List.filled(editedResult.results?.length ?? 0, null);
  }

  List<PlutoColumn> buildColumns() {
    return [
      PlutoColumn(
        title: 'Ranking',
        field: 'ranking',
        type: PlutoColumnType.number(format: '#'),
        width: 100,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Protein ID',
        field: 'proteinId',
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
        field: 'inputList',
        type: PlutoColumnType.number(format: '#,###.############'),
        width: 150,
      ),
    ];
  }

  List<PlutoRow> buildRows() {
    return List.generate(
      editedResult.results?.length ?? 0,
      (index) {
        final result = editedResult.results![index];
        return PlutoRow(
          cells: {
            'ranking': PlutoCell(value: index + 1),
            'proteinId': PlutoCell(value: result.proteinId),
            'prediction': PlutoCell(value: result.mean),
            'inputList': PlutoCell(
              value: inputList[index],
            ),
          },
        );
      },
    );
  }

  void handleCellValueChanged(PlutoGridOnChangedEvent event) {
    if (event.column.field == 'inputList') {
      setState(() {
        inputList[event.rowIdx] = event.value;
      });
    }
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
              'Select Proteins for Iterative Training',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PlutoGrid(
                columns: buildColumns(),
                rows: buildRows(),
                onChanged: handleCellValueChanged,
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
                    await Future.delayed(const Duration(milliseconds: 500));
                    widget.onStartDirectIteration(inputList);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Start with Same Config'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    stateManager.setEditing(false);
                    await Future.delayed(const Duration(milliseconds: 500));
                    widget.onStartIteration(inputList);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Start with New Config'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
