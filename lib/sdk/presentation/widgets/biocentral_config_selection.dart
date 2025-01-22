import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

import '../../model/biocentral_config_option.dart';

class BiocentralConfigSelection extends StatefulWidget {
  final Map<String, List<BiocentralConfigOption>> optionMap;
  final void Function(Map<String, Map<BiocentralConfigOption, dynamic>>) onConfigChangedCallback;

  const BiocentralConfigSelection({required this.optionMap, required this.onConfigChangedCallback, super.key});

  @override
  State<BiocentralConfigSelection> createState() => _BiocentralConfigSelectionState();
}

class _BiocentralConfigSelectionState extends State<BiocentralConfigSelection> {
  String? _selectedKey;

  final Map<String, Map<BiocentralConfigOption, dynamic>> _chosenOptions = {};

  @override
  void initState() {
    super.initState();
    for (final entry in widget.optionMap.entries) {
      _chosenOptions.putIfAbsent(
          entry.key, () => Map.fromEntries(entry.value.map((option) => MapEntry(option, option.defaultValue))));
    }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    widget.onConfigChangedCallback(_chosenOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BiocentralDiscreteSelection(
          title: 'Select method:',
          selectableValues: widget.optionMap.keys.toList(),
          onChangedCallback: (String? value) {
            setState(() {
              _selectedKey = value;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: buildConfigOptionsTable(),
        ),
      ],
    );
  }

  int _getNumberOfColumns(int numberOfOptions) {
    // TODO [Refactor - Frontend] Adjust dynamically also based on window size
    if (numberOfOptions % 4 == 0) return 4;
    if (numberOfOptions % 3 == 0) return 3;
    return 2;
  }

  Widget buildConfigOptionsTable() {
    final options = widget.optionMap[_selectedKey] ?? [];
    if(_selectedKey == null || options.isEmpty) {
      return Container();
    }

    final int columns = _getNumberOfColumns(options.length);
    return ExpansionTile(
      title: Text('$_selectedKey-specific Configuration:'),
      initiallyExpanded: true,
      children: [
        Table(
          columnWidths: {
            for (int i = 0; i < columns; i++) i: const FlexColumnWidth(),
          },
          children: [
            for (int i = 0; i < options.length; i += columns)
              TableRow(
                children: [
                  for (int j = 0; j < columns; j++)
                    if (i + j < options.length)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: buildOption(options[i + j]),
                      )
                    else
                      Container(),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget buildOption(BiocentralConfigOption option) {
    final allowedValues = option.constraints?.allowedValues ?? {};
    if (allowedValues.isEmpty) {
      return buildTextOption(option);
    } else {
      return buildSelectionOption(option);
    }
  }

  Widget buildTextOption(BiocentralConfigOption option) {
    final String defaultValue = option.defaultValue.toString();
    return Align(
      alignment: Alignment.bottomCenter,
      child: TextFormField(
        initialValue: defaultValue,
        decoration: InputDecoration(labelText: option.name),
        textAlign: TextAlign.center,
        onChanged: (String? newValue) {
          setState(() {
            _chosenOptions[_selectedKey]?[option] = newValue;
          });
        },
      ),
    );
  }

  Widget buildSelectionOption(BiocentralConfigOption option) {
    final allowedValues = option.constraints?.allowedValues ?? {};
    final dynamic defaultValue = option.defaultValue.toString();
    var chosenOption = _chosenOptions[_selectedKey]?[option];

    if (chosenOption == '') {
      chosenOption = defaultValue != '' ? defaultValue : allowedValues.first;
    }

    // TODO This should not be necessary?
    //if (defaultValue != '' && !allowedValues.contains(defaultValue)) {
    //  allowedValues.add(defaultValue);
    //}

    if (allowedValues.length <= 4) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: option.name,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Center(
          child: ToggleButtons(
              isSelected: allowedValues.map((value) => value == chosenOption).toList(),
              onPressed: (int index) {
                final toggled = allowedValues.toList()[index];
                setState(() {
                  _chosenOptions[_selectedKey]?[option] = toggled;
                });
              },
              children: allowedValues
                  .map(
                    (value) => Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(value.toString()),
                    ),
                  )
                  .toList()),
        ),
      );
    }

    return BiocentralDropdownMenu(
      label: Text(option.name),
      initialSelection: defaultValue,
      dropdownMenuEntries:
          allowedValues.map((value) => DropdownMenuEntry(value: value, label: value.toString())).toList(),
      onSelected: (dynamic value) {
        setState(() {
          chosenOption = value!;
          _chosenOptions[_selectedKey]?[option] = chosenOption;
        });
      },
    );
  }
}
