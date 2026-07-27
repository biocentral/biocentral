import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

class ColumnWizardOperationDisplayFactory {
  static Widget fromSelected({
    required ColumnOperationType columnOperationType,
    required String selectedColumnName,
    required GlobalKey calculateButtonKey,
    required void Function(ColumnWizardOperation) onCalculateCallback,
  }) {
    switch (columnOperationType) {
      case ColumnOperationType.toBinary:
        return ColumnWizardToBinaryOperationDisplay(
          selectedColumnName: selectedColumnName,
          onCalculateCallback: onCalculateCallback,
          calculateButtonKey: calculateButtonKey,
        );
      case ColumnOperationType.removeMissing:
        return ColumnWizardRemoveMissingOperationDisplay(
          selectedColumnName: selectedColumnName,
          onCalculateCallback: onCalculateCallback,
          calculateButtonKey: calculateButtonKey,
        );
      case ColumnOperationType.removeOutliers:
        return ColumnWizardRemoveOutliersOperationDisplay(
          selectedColumnName: selectedColumnName,
          onCalculateCallback: onCalculateCallback,
          calculateButtonKey: calculateButtonKey,
        );
      case ColumnOperationType.clamp:
        return ColumnWizardClampOperationDisplay(
          selectedColumnName: selectedColumnName,
          onCalculateCallback: onCalculateCallback,
          calculateButtonKey: calculateButtonKey,
        );
      case ColumnOperationType.calculateLength:
        return ColumnWizardCalculateLengthOperationDisplay(
          selectedColumnName: selectedColumnName,
          onCalculateCallback: onCalculateCallback,
          calculateButtonKey: calculateButtonKey,
        );
      case ColumnOperationType.shuffle:
        return ColumnWizardShuffleOperationDisplay(
          selectedColumnName: selectedColumnName,
          onCalculateCallback: onCalculateCallback,
          calculateButtonKey: calculateButtonKey,
        );
    }
  }
}

abstract class ColumnWizardOperationDisplay extends StatefulWidget {
  final String selectedColumnName;
  final GlobalKey calculateButtonKey;
  final void Function(ColumnWizardOperation) onCalculateCallback;

  const ColumnWizardOperationDisplay(
      {required this.selectedColumnName,
      required this.calculateButtonKey,
      required this.onCalculateCallback,
      super.key});
}

abstract class ColumnWizardOperationDisplayState extends State<ColumnWizardOperationDisplay> {
  @override
  void initState() {
    super.initState();
  }

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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildCalculateButton(),
        ),
      ],
    );
  }

  Widget buildCalculateButton() {
    return BiocentralSmallButton(key: widget.calculateButtonKey, onTap: collectAndInvokeCallback, label: 'Calculate');
  }

  List<Widget> buildParameterSelections();
}

class ColumnWizardShuffleOperationDisplay extends ColumnWizardOperationDisplay {
  const ColumnWizardShuffleOperationDisplay({
    required super.selectedColumnName,
    required super.onCalculateCallback,
    required super.calculateButtonKey,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ColumnWizardShuffleOperationDisplayState();
}

class _ColumnWizardShuffleOperationDisplayState extends ColumnWizardOperationDisplayState {
  int seed = ColumnWizardShuffleOperation.defaultSeed;

  @override
  ColumnWizardOperation? collect() {
    return ColumnWizardShuffleOperation(seed);
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

class ColumnWizardToBinaryOperationDisplay extends ColumnWizardOperationDisplay {
  const ColumnWizardToBinaryOperationDisplay({
    required super.selectedColumnName,
    required super.onCalculateCallback,
    required super.calculateButtonKey,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ColumnWizardToBinaryOperationDisplayState();
}

class _ColumnWizardToBinaryOperationDisplayState extends ColumnWizardOperationDisplayState {
  String compareToValue = '';
  String valueTrue = ColumnWizardToBinaryOperation.defaultValueTrue;
  String valueFalse = ColumnWizardToBinaryOperation.defaultValueFalse;

  @override
  ColumnWizardOperation? collect() {
    return ColumnWizardToBinaryOperation(compareToValue, valueTrue, valueFalse);
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

class ColumnWizardRemoveMissingOperationDisplay extends ColumnWizardOperationDisplay {
  const ColumnWizardRemoveMissingOperationDisplay({
    required super.selectedColumnName,
    required super.onCalculateCallback,
    required super.calculateButtonKey,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ColumnWizardRemoveMissingOperationDisplayState();
}

class _ColumnWizardRemoveMissingOperationDisplayState extends ColumnWizardOperationDisplayState {
  @override
  ColumnWizardOperation? collect() {
    return ColumnWizardRemoveMissingOperation();
  }

  @override
  List<Widget> buildParameterSelections() {
    return [];
  }
}

class ColumnWizardRemoveOutliersOperationDisplay extends ColumnWizardOperationDisplay {
  const ColumnWizardRemoveOutliersOperationDisplay({
    required super.selectedColumnName,
    required super.onCalculateCallback,
    required super.calculateButtonKey,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ColumnWizardRemoveOutliersOperationDisplayState();
}

class _ColumnWizardRemoveOutliersOperationDisplayState extends ColumnWizardOperationDisplayState {
  ColumnWizardOutlierRemovalMethod _selectedMethod = ColumnWizardOutlierRemovalMethod.values.first;

  @override
  ColumnWizardOperation? collect() {
    return ColumnWizardRemoveOutliersOperation(_selectedMethod);
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
          initialSelection: _selectedMethod,
          onSelected: (ColumnWizardOutlierRemovalMethod? method) {
            if (method != null && _selectedMethod != method) {
              setState(() {
                _selectedMethod = method;
              });
            }
          },
        ),
      ),
    ];
  }
}

class ColumnWizardClampOperationDisplay extends ColumnWizardOperationDisplay {
  const ColumnWizardClampOperationDisplay({
    required super.selectedColumnName,
    required super.onCalculateCallback,
    required super.calculateButtonKey,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ColumnWizardClampOperationDisplayState();
}

class _ColumnWizardClampOperationDisplayState extends ColumnWizardOperationDisplayState {
  double? low;
  double? high;

  @override
  ColumnWizardOperation? collect() {
    if (low != null || high != null) {
      return ColumnWizardClampOperation(low, high);
    }
    return null;
  }

  @override
  List<Widget> buildParameterSelections() {
    return [
      Flexible(
        child: TextFormField(
          initialValue: '0.0',
          decoration: const InputDecoration(
            labelText: 'Lower value:',
            helperText: 'Remove all values strictly lower than this.',
          ),
          onChanged: (String? value) {
            setState(() {
              low = double.tryParse(value ?? '');
            });
          },
        ),
      ),
      Flexible(
        child: TextFormField(
          initialValue: '0.0',
          decoration: const InputDecoration(
            labelText: 'Upper value:',
            helperText: 'Remove all values strictly higher than this.',
          ),
          onChanged: (String? value) {
            setState(() {
              high = double.tryParse(value ?? '');
            });
          },
        ),
      ),
    ];
  }
}

class ColumnWizardCalculateLengthOperationDisplay extends ColumnWizardOperationDisplay {
  const ColumnWizardCalculateLengthOperationDisplay({
    required super.selectedColumnName,
    required super.onCalculateCallback,
    required super.calculateButtonKey,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ColumnWizardCalculateLengthOperationDisplayState();
}

class _ColumnWizardCalculateLengthOperationDisplayState extends ColumnWizardOperationDisplayState {
  @override
  ColumnWizardOperation? collect() {
    return ColumnWizardCalculateLengthOperation();
  }

  @override
  List<Widget> buildParameterSelections() {
    return [];
  }
}
