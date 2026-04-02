import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/column_wizard_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProteinInsightsView extends StatefulWidget {
  const ProteinInsightsView({super.key});

  @override
  State<ProteinInsightsView> createState() => _ProteinInsightsViewState();
}

class _ProteinInsightsViewState extends State<ProteinInsightsView> {
  final GlobalKey _columnSelectionKey = GlobalKey();
  final GlobalKey _operationSelectionKey = GlobalKey();
  final GlobalKey _calculateButtonKey = GlobalKey();
  
  String? _newColumnName;
  
  @override
  void initState() {
    super.initState();
  }

  void onCalculate(
      ColumnWizardBloc columnWizardBloc, ColumnWizardBlocState state, ColumnWizardOperation operation,) {
    if (state.columnWizard != null) {
      columnWizardBloc.add(ColumnWizardCalculateEvent(operation));
    }
  }

  void onApply(ColumnWizardBlocState state) {
    // TODO
    final operationHistory = state.columnWizardHistory?[state.selectedColumn] ?? [];
    if (state.selectedColumn != null && state.columnWizard != null && operationHistory.isNotEmpty) {
      
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final ColumnWizardBloc columnWizardBloc = BlocProvider.of<ColumnWizardBloc>(context);
    return BlocBuilder<ColumnWizardBloc, ColumnWizardBlocState>(
      builder: (context, state) {
        return Column(
          children: [
            Flexible(child: buildColumnSelection(columnWizardBloc, state)),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
            Expanded(flex: 5, child: buildColumnWizardDisplay(state)),
            Flexible(child: buildColumnWizardOperationSelection(columnWizardBloc, state)),
            Flexible(child: buildColumnWizardOperationDisplay(columnWizardBloc, state)),
            Flexible(child: buildNewColumnNameSelection(state)),
          ],
        );
      },
    );
  }

  Widget buildColumnSelection(ColumnWizardBloc columnWizardBloc, ColumnWizardBlocState state) {
    return BiocentralDropdownMenu<String>(
      key: _columnSelectionKey,
      dropdownMenuEntries: state.columns.keys.map((key) => DropdownMenuEntry(value: key, label: key)).toList(),
      label: const Text('Select column..'),
      // TODO initialSelection: 'Sequence',
      onSelected: (String? value) => columnWizardBloc.add(ColumnWizardSelectColumnEvent(value ?? '')),
    );
  }

  Widget buildColumnWizardDisplay(ColumnWizardBlocState state) {
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
      ColumnWizardBloc columnWizardBloc,
      ColumnWizardBlocState state,
      ) {
    final Set<ColumnOperationType> availableOperations = state.columnWizard?.getAvailableOperations() ?? {};
    if (availableOperations.isEmpty) {
      return Container();
    }
    return BiocentralDropdownMenu<ColumnOperationType>(
      key: _operationSelectionKey,
      dropdownMenuEntries:
      availableOperations.map((operation) => DropdownMenuEntry(value: operation, label: operation.name)).toList(),
      label: const Text('Select operation..'),
      onSelected: (ColumnOperationType? value) {
        if (value != null) {
          columnWizardBloc.add(ColumnWizardSelectOperationEvent(value));
        }
      },
    );
  }

  Widget buildColumnWizardOperationDisplay(ColumnWizardBloc columnWizardBloc, ColumnWizardBlocState state) {
    if (state.selectedOperationType == null) {
      return Container();
    }
    return ColumnWizardOperationDisplayFactory.fromSelected(
      columnOperationType: state.selectedOperationType!,
      selectedColumnName: state.selectedColumn!,
      onCalculateCallback: (ColumnWizardOperation operation) => onCalculate(columnWizardBloc, state, operation),
      calculateButtonKey: _calculateButtonKey,
    );
  }

  Widget buildNewColumnNameSelection(ColumnWizardBlocState state) {
    final show = state.columnWizardHistory?[state.selectedColumn]?.lastOrNull?.operation != null;
    if (show) {
      if (_newColumnName == '') {
        _newColumnName = "${state.selectedColumn ?? ''}-modified";
      }
      return Flexible(
        child: TextFormField(
          initialValue: _newColumnName,
          decoration: const InputDecoration(labelText: 'New Column Name'),
          onChanged: (String? value) {
            setState(() {
              _newColumnName = value ?? '';
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
      // TODO
      return BiocentralSmallButton(onTap: () => onApply(state), label: 'Apply column modifications');
    }
    return Container();
  }
}
