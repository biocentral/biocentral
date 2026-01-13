import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/column_wizard_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ColumnWizardDialog extends StatefulWidget {
  final void Function(String newColumnName, String originalColumnName, List<ColumnWizardHistoryEntry> operationHistory)
      onApplyColumn;

  final String? initialSelectedColumn;

  const ColumnWizardDialog({required this.onApplyColumn, required this.initialSelectedColumn, super.key});

  @override
  State<ColumnWizardDialog> createState() => ColumnWizardDialogState();
}

class ColumnWizardDialogState extends State<ColumnWizardDialog>
    with BiocentralDialogCloseMixin, AutomaticKeepAliveClientMixin {
  final GlobalKey columnSelectionKey = GlobalKey();
  final GlobalKey operationSelectionKey = GlobalKey();
  final GlobalKey calculateButtonKey = GlobalKey();

  String newColumnName = '';

  void onCalculate(
      ColumnWizardBloc columnWizardDialogBloc, ColumnWizardBlocState state, ColumnWizardOperation operation,) {
    if (state.columnWizard != null) {
      columnWizardDialogBloc.add(ColumnWizardCalculateEvent(operation));
    }
  }

  void onApply(ColumnWizardBlocState state) {
    // TODO
    final operationHistory = state.columnWizardHistory?[state.selectedColumn] ?? [];
    if (state.selectedColumn != null && state.columnWizard != null && operationHistory.isNotEmpty) {
      closeDialog(
        callback: () => widget.onApplyColumn(newColumnName, state.selectedColumn!, operationHistory),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<ColumnWizardBloc, ColumnWizardBlocState>(
      listener: (context, state) {},
      builder: (context, state) => buildDialog(state),
    );
  }

  Widget buildDialog(ColumnWizardBlocState state) {
    final ColumnWizardBloc columnWizardDialogBloc = BlocProvider.of<ColumnWizardBloc>(context);
    return BiocentralDialog(
      children: [
        Text(
          'Column Wizard',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        buildColumnSelection(columnWizardDialogBloc, state),
        buildColumnWizardDisplays(state),
        buildColumnWizardOperationSelection(columnWizardDialogBloc, state),
        buildColumnWizardOperationDisplay(columnWizardDialogBloc, state),
        buildNewColumnNameSelection(state),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [buildApplyButton(state), const Spacer(), buildCancelButton()],
        ),
      ],
    );
  }

  Widget buildColumnSelection(ColumnWizardBloc columnWizardDialogBloc, ColumnWizardBlocState state) {
    return BiocentralDropdownMenu<String>(
      key: columnSelectionKey,
      dropdownMenuEntries: state.columns.keys.map((key) => DropdownMenuEntry(value: key, label: key)).toList(),
      label: const Text('Select column..'),
      initialSelection: widget.initialSelectedColumn,
      onSelected: (String? value) => columnWizardDialogBloc.add(ColumnWizardSelectColumnEvent(value ?? '')),
    );
  }

  Widget buildColumnWizardDisplays(ColumnWizardBlocState state) {
    final String? selectedColumn = state.selectedColumn;
    final columnWizardHistory = state.columnWizardHistory?[selectedColumn] ?? [];

    if (selectedColumn == null || columnWizardHistory.isEmpty) {
      return Container();
    }

    // TODO Show diff between operations
    return ListView.builder(
      shrinkWrap: true,
      itemCount: columnWizardHistory.length,
      itemBuilder: (context, index) {
        final operationResult = columnWizardHistory[index];
        final resultWizard = operationResult.resultWizard;
        final operation = operationResult.operation;
        return Column(
          children: [
            if (index != 0 && index < columnWizardHistory.length)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(border: Border.all()),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(operation?.getDisplayName() ?? 'Operation'),
                        ...(operation?.getConfigMap() ?? {}).entries.map((entry) => Text(
                              '${entry.key.capitalize()}: ${entry.value}',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontStyle: FontStyle.italic),
                            ),),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_downward, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ColumnWizardDisplay(
              columnWizard: resultWizard,
              customBuildFunction: state.customBuildFunctions?[resultWizard.type],
            ),
          ],
        );
      },
    );
  }

  Widget buildColumnWizardOperationSelection(
    ColumnWizardBloc columnWizardDialogBloc,
    ColumnWizardBlocState state,
  ) {
    final Set<ColumnOperationType> availableOperations = state.columnWizard?.getAvailableOperations() ?? {};
    if (availableOperations.isEmpty) {
      return Container();
    }
    return BiocentralDropdownMenu<ColumnOperationType>(
      key: operationSelectionKey,
      dropdownMenuEntries:
          availableOperations.map((operation) => DropdownMenuEntry(value: operation, label: operation.name)).toList(),
      label: const Text('Select operation..'),
      onSelected: (ColumnOperationType? value) {
        if (value != null) {
          columnWizardDialogBloc.add(ColumnWizardSelectOperationEvent(value));
        }
      },
    );
  }

  Widget buildColumnWizardOperationDisplay(ColumnWizardBloc columnWizardDialogBloc, ColumnWizardBlocState state) {
    if (state.selectedOperationType == null) {
      return Container();
    }
    return ColumnWizardOperationDisplayFactory.fromSelected(
      columnOperationType: state.selectedOperationType!,
      selectedColumnName: state.selectedColumn!,
      onCalculateCallback: (ColumnWizardOperation operation) => onCalculate(columnWizardDialogBloc, state, operation),
      calculateButtonKey: calculateButtonKey,
    );
  }

  Widget buildNewColumnNameSelection(ColumnWizardBlocState state) {
    final show = state.columnWizardHistory?[state.selectedColumn]?.lastOrNull?.operation != null;
    if (show) {
      if (newColumnName == '') {
        newColumnName = "${state.selectedColumn ?? ''}-modified";
      }
      return Flexible(
        child: TextFormField(
          initialValue: newColumnName,
          decoration: const InputDecoration(labelText: 'New Column Name'),
          onChanged: (String? value) {
            setState(() {
              newColumnName = value ?? '';
            });
          },
        ),
      );
    }
    return Container();
  }

  Widget buildApplyButton(ColumnWizardBlocState state) {
    final show = state.columnWizardHistory?[state.selectedColumn]?.lastOrNull?.operation != null;
    if (show) {
      return BiocentralSmallButton(onTap: () => onApply(state), label: 'Apply column modifications');
    }
    return Container();
  }

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: 'Close');
  }

  @override
  bool get wantKeepAlive => true;
}
