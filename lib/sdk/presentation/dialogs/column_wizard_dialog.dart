import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/column_wizard_dialog_bloc.dart';
import '../../model/column_wizard_abstract.dart';
import '../../model/column_wizard_operations.dart';
import '../displays/column_wizard_operation_displays.dart';
import '../displays/column_wizard_stats_display.dart';
import '../widgets/biocentral_drop_down_menu.dart';
import '../widgets/biocentral_small_button.dart';
import 'biocentral_dialog.dart';

class ColumnWizardDialog extends StatefulWidget {
  final void Function(ColumnWizard columnWizard, ColumnWizardOperation columnWizardOperation) onCalculateColumn;

  const ColumnWizardDialog({super.key, required this.onCalculateColumn});

  @override
  State<ColumnWizardDialog> createState() => _ColumnWizardDialogState();
}

class _ColumnWizardDialogState extends State<ColumnWizardDialog> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  void onCalculate(ColumnWizardDialogState state, ColumnWizardOperation operation) {
    if (state.columnWizard != null) {
      widget.onCalculateColumn(state.columnWizard!, operation);
      closeDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<ColumnWizardDialogBloc, ColumnWizardDialogState>(
      listener: (context, state) {},
      builder: (context, state) => buildDialog(state),
    );
  }

  Widget buildDialog(ColumnWizardDialogState state) {
    ColumnWizardDialogBloc columnWizardDialogBloc = BlocProvider.of<ColumnWizardDialogBloc>(context);
    return BiocentralDialog(
      small: false, // TODO Small Dialog not working yet
      children: [
        Text(
          "Column Wizard",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        buildColumnSelection(columnWizardDialogBloc, state),
        buildColumnWizardDisplay(state),
        buildColumnWizardOperationSelection(columnWizardDialogBloc, state),
        buildColumnWizardOperationDisplay(state),
        buildCancelButton(),
      ],
    );
  }

  Widget buildColumnSelection(ColumnWizardDialogBloc columnWizardDialogBloc, ColumnWizardDialogState state) {
    return BiocentralDropdownMenu<String>(
        dropdownMenuEntries: state.columns.keys.map((key) => DropdownMenuEntry(value: key, label: key)).toList(),
        label: const Text("Select column.."),
        onSelected: (String? value) => columnWizardDialogBloc.add(ColumnWizardDialogSelectColumnEvent(value ?? "")));
  }

  Widget buildColumnWizardDisplay(ColumnWizardDialogState state) {
    ColumnWizard? columnWizard = state.columnWizards?[state.selectedColumn];

    if (columnWizard == null) {
      return Container();
    }
    return ColumnWizardStatsDisplay(columnWizard: columnWizard);
  }

  Widget buildColumnWizardOperationSelection(
      ColumnWizardDialogBloc columnWizardDialogBloc, ColumnWizardDialogState state) {
    Set<ColumnOperationType> availableOperations = state.columnWizard?.getAvailableOperations() ?? {};
    if (availableOperations.isEmpty) {
      return Container();
    }
    return BiocentralDropdownMenu<ColumnOperationType>(
        dropdownMenuEntries:
            availableOperations.map((operation) => DropdownMenuEntry(value: operation, label: operation.name)).toList(),
        label: const Text("Select operation.."),
        onSelected: (ColumnOperationType? value) {
          if (value != null) {
            columnWizardDialogBloc.add(ColumnWizardDialogSelectOperationEvent(value));
          }
        });
  }

  Widget buildColumnWizardOperationDisplay(ColumnWizardDialogState state) {
    if (state.selectedOperationType == null) {
      return Container();
    }
    return ColumnWizardOperationDisplayFactory.fromSelected(
        columnOperationType: state.selectedOperationType!,
        selectedColumnName: state.selectedColumn!,
        onCalculateCallback: (ColumnWizardOperation operation) => onCalculate(state, operation));
  }

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: "Close");
  }

  @override
  bool get wantKeepAlive => true;
}
