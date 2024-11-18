import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

class ColumnWizardOperationDisplayFactory {
  static Widget fromSelected({
    required ColumnOperationType columnOperationType,
    required String selectedColumnName,
    required void Function(ColumnWizardOperation) onCalculateCallback,
  }) {
    switch (columnOperationType) {
      case ColumnOperationType.toBinary:
        return ColumnWizardToBinaryOperationDisplay(
          selectedColumnName: selectedColumnName,
          onCalculateCallback: onCalculateCallback,
        );
      case ColumnOperationType.removeMissing:
        return ColumnWizardRemoveMissingOperationDisplay(
          selectedColumnName: selectedColumnName,
          onCalculateCallback: onCalculateCallback,
        );
      case ColumnOperationType.removeOutliers:
        return ColumnWizardRemoveOutliersOperationDisplay(
            selectedColumnName: selectedColumnName, onCalculateCallback: onCalculateCallback);
      case ColumnOperationType.calculateLength:
        return ColumnWizardCalculateLengthOperationDisplay(
            selectedColumnName: selectedColumnName, onCalculateCallback: onCalculateCallback);
      case ColumnOperationType.shuffle:
        return ColumnWizardShuffleOperationDisplay(
          selectedColumnName: selectedColumnName,
          onCalculateCallback: onCalculateCallback,
        );
    }
  }
}

abstract class ColumnWizardOperationDisplay<T extends ColumnWizardOperationResult> extends StatefulWidget {
  final String selectedColumnName;
  final void Function(ColumnWizardOperation) onCalculateCallback;

  const ColumnWizardOperationDisplay({required this.selectedColumnName, required this.onCalculateCallback, super.key});
}

abstract class ColumnWizardOperationDisplayState<T extends ColumnWizardOperationResult>
    extends State<ColumnWizardOperationDisplay> {
  String newColumnName = '';

  @override
  void initState() {
    super.initState();
    if(defaultColumnName().isNotEmpty) {
      newColumnName = '${widget.selectedColumnName}-${defaultColumnName()}';
    }
  }

  bool showNewColumnName() {
    return T == ColumnWizardAddOperationResult;
  }

  String defaultColumnName();

  ColumnWizardOperation? collect();

  void collectAndInvokeCallback() {
    final ColumnWizardOperation? operation = collect();
    if (operation != null) {
      widget.onCalculateCallback(operation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: buildParameterSelections(),
        ),
        buildNewColumnNameSelection(),
        buildCalculateButton(),
      ],
    );
  }

  Widget buildNewColumnNameSelection() {
    return Visibility(
      visible: showNewColumnName(),
      child: Flexible(
        child: TextFormField(
          initialValue: newColumnName,
          decoration: const InputDecoration(labelText: 'New Column Name'),
          onChanged: (String? value) {
            setState(() {
              newColumnName = value ?? '';
            });
          },
        ),
      ),
    );
  }

  Widget buildCalculateButton() {
    return BiocentralSmallButton(onTap: collectAndInvokeCallback, label: 'Calculate');
  }

  List<Widget> buildParameterSelections();
}

class ColumnWizardShuffleOperationDisplay extends ColumnWizardOperationDisplay<ColumnWizardAddOperationResult> {
  const ColumnWizardShuffleOperationDisplay({
    required super.selectedColumnName,
    required super.onCalculateCallback,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ColumnWizardShuffleOperationDisplayState();
}

class _ColumnWizardShuffleOperationDisplayState
    extends ColumnWizardOperationDisplayState<ColumnWizardAddOperationResult> {
  int seed = ColumnWizardShuffleOperation.defaultSeed;

  @override
  String defaultColumnName() {
    return 'shuffled';
  }

  @override
  ColumnWizardOperation? collect() {
    return ColumnWizardShuffleOperation(newColumnName, seed);
  }

  @override
  List<Widget> buildParameterSelections() {
    return [
      Flexible(
        child: TextFormField(
          initialValue: seed.toString(),
          decoration: const InputDecoration(labelText: 'Seed'),
          onChanged: (String? value) {
            setState(() {
              seed = int.tryParse(value ?? '') ?? ColumnWizardShuffleOperation.defaultSeed;
            });
          },
        ),
      ),
    ];
  }
}

class ColumnWizardToBinaryOperationDisplay extends ColumnWizardOperationDisplay<ColumnWizardAddOperationResult> {
  const ColumnWizardToBinaryOperationDisplay({
    required super.selectedColumnName,
    required super.onCalculateCallback,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ColumnWizardToBinaryOperationDisplayState();
}

class _ColumnWizardToBinaryOperationDisplayState
    extends ColumnWizardOperationDisplayState<ColumnWizardAddOperationResult> {
  String compareToValue = '';
  String valueTrue = ColumnWizardToBinaryOperation.defaultValueTrue;
  String valueFalse = ColumnWizardToBinaryOperation.defaultValueFalse;

  @override
  String defaultColumnName() {
    return 'binary';
  }

  @override
  ColumnWizardOperation? collect() {
    if (newColumnName.isNotEmpty) {
      return ColumnWizardToBinaryOperation(newColumnName, compareToValue, valueTrue, valueFalse);
    } else {
      return null;
    }
  }

  @override
  List<Widget> buildParameterSelections() {
    return [
      Flexible(
        child: TextFormField(
          initialValue: compareToValue,
          decoration: const InputDecoration(labelText: 'Compare to value:'),
          onChanged: (String? value) {
            setState(() {
              compareToValue = value ?? '';
            });
          },
        ),
      ),
      Flexible(
        child: TextFormField(
          initialValue: valueTrue,
          decoration: const InputDecoration(labelText: 'Value if match'),
          onChanged: (String? value) {
            setState(() {
              valueTrue = value ?? ColumnWizardToBinaryOperation.defaultValueTrue;
            });
          },
        ),
      ),
      Flexible(
        child: TextFormField(
          initialValue: valueFalse,
          decoration: const InputDecoration(labelText: 'Value if no match'),
          onChanged: (String? value) {
            setState(() {
              valueFalse = value ?? ColumnWizardToBinaryOperation.defaultValueFalse;
            });
          },
        ),
      ),
    ];
  }
}

class ColumnWizardRemoveMissingOperationDisplay
    extends ColumnWizardOperationDisplay<ColumnWizardRemoveOperationResult> {
  const ColumnWizardRemoveMissingOperationDisplay({
    required super.selectedColumnName,
    required super.onCalculateCallback,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ColumnWizardRemoveMissingOperationDisplayState();
}

class _ColumnWizardRemoveMissingOperationDisplayState
    extends ColumnWizardOperationDisplayState<ColumnWizardRemoveOperationResult> {
  @override
  String defaultColumnName() {
    return '';
  }

  @override
  ColumnWizardOperation? collect() {
    return ColumnWizardRemoveMissingOperation(newColumnName);
  }

  @override
  List<Widget> buildParameterSelections() {
    return [];
  }
}

class ColumnWizardRemoveOutliersOperationDisplay
    extends ColumnWizardOperationDisplay<ColumnWizardRemoveOperationResult> {
  const ColumnWizardRemoveOutliersOperationDisplay({
    required super.selectedColumnName,
    required super.onCalculateCallback,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ColumnWizardRemoveOutliersOperationDisplay();
}

class _ColumnWizardRemoveOutliersOperationDisplay
    extends ColumnWizardOperationDisplayState<ColumnWizardRemoveOperationResult> {
  ColumnWizardOutlierRemovalMethod? _selectedMethod;

  @override
  String defaultColumnName() {
    return '';
  }

  @override
  ColumnWizardOperation? collect() {
    if (_selectedMethod != null) {
      return ColumnWizardRemoveOutliersOperation(newColumnName, _selectedMethod!);
    }
    return null;
  }

  @override
  List<Widget> buildParameterSelections() {
    return [
      Flexible(
        child: BiocentralDropdownMenu(
          dropdownMenuEntries: ColumnWizardOutlierRemovalMethod.values
              .map((method) => DropdownMenuEntry(value: method, label: method.name))
              .toList(),
          label: const Text('Select method'),
          onSelected: (ColumnWizardOutlierRemovalMethod? method) {
            setState(() {
              _selectedMethod = method;
            });
          },
        ),
      ),
    ];
  }
}

class ColumnWizardCalculateLengthOperationDisplay extends ColumnWizardOperationDisplay<ColumnWizardAddOperationResult> {
  const ColumnWizardCalculateLengthOperationDisplay({
    required super.selectedColumnName,
    required super.onCalculateCallback,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ColumnWizardCalculateLengthOperationDisplayState();
}

class _ColumnWizardCalculateLengthOperationDisplayState
    extends ColumnWizardOperationDisplayState<ColumnWizardAddOperationResult> {
  @override
  String defaultColumnName() {
    return 'length';
  }

  @override
  ColumnWizardOperation? collect() {
    if (newColumnName.isNotEmpty) {
      return ColumnWizardCalculateLengthOperation(newColumnName);
    } else {
      return null;
    }
  }

  @override
  List<Widget> buildParameterSelections() {
    return [];
  }
}
