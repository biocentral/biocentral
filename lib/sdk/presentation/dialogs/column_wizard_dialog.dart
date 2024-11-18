import 'package:biocentral/sdk/bloc/column_wizard_bloc.dart';
import 'package:biocentral/sdk/model/column_wizard_abstract.dart';
import 'package:biocentral/sdk/model/column_wizard_operations.dart';
import 'package:biocentral/sdk/presentation/dialogs/biocentral_dialog.dart';
import 'package:biocentral/sdk/presentation/displays/column_wizard_display.dart';
import 'package:biocentral/sdk/presentation/displays/column_wizard_operation_displays.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_drop_down_menu.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_small_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ColumnWizardDialog extends StatefulWidget {
  final void Function(ColumnWizard columnWizard, ColumnWizardOperation columnWizardOperation) onCalculateColumn;

  final String? initialSelectedColumn;

  const ColumnWizardDialog({required this.onCalculateColumn, required this.initialSelectedColumn, super.key});

  @override
  State<ColumnWizardDialog> createState() => _ColumnWizardDialogState();
}

class _ColumnWizardDialogState extends State<ColumnWizardDialog> with AutomaticKeepAliveClientMixin {
  void closeDialog() {
    Navigator.of(context).pop();
  }

  void onCalculate(ColumnWizardBlocState state, ColumnWizardOperation operation) {
    if (state.columnWizard != null) {
      closeDialog();
      widget.onCalculateColumn(state.columnWizard!, operation);
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
        buildColumnWizardDisplay(state),
        buildColumnWizardOperationSelection(columnWizardDialogBloc, state),
        buildColumnWizardOperationDisplay(state),
        buildCancelButton(),
      ],
    );
  }

  Widget buildColumnSelection(ColumnWizardBloc columnWizardDialogBloc, ColumnWizardBlocState state) {
    return BiocentralDropdownMenu<String>(
      dropdownMenuEntries: state.columns.keys.map((key) => DropdownMenuEntry(value: key, label: key)).toList(),
      label: const Text('Select column..'),
      initialSelection: widget.initialSelectedColumn,
      onSelected: (String? value) => columnWizardDialogBloc.add(ColumnWizardSelectColumnEvent(value ?? '')),
    );
  }

  Widget buildColumnWizardDisplay(ColumnWizardBlocState state) {
    final ColumnWizard? columnWizard = state.columnWizards?[state.selectedColumn];

    if (columnWizard == null) {
      return Container();
    }
    return ColumnWizardDisplay(
      columnWizard: columnWizard,
      customBuildFunction: state.customBuildFunction,
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

  Widget buildColumnWizardOperationDisplay(ColumnWizardBlocState state) {
    if (state.selectedOperationType == null) {
      return Container();
    }
    return ColumnWizardOperationDisplayFactory.fromSelected(
      columnOperationType: state.selectedOperationType!,
      selectedColumnName: state.selectedColumn!,
      onCalculateCallback: (ColumnWizardOperation operation) => onCalculate(state, operation),
    );
  }

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: 'Close');
  }

  @override
  bool get wantKeepAlive => true;
}
