import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

import '../../model/biocentral_config_option.dart';

class BiocentralConfigSelection extends StatefulWidget {
  final Map<String, List<BiocentralConfigOption>> optionMap;

  const BiocentralConfigSelection({required this.optionMap, super.key});

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
      _chosenOptions.putIfAbsent(entry.key, () => Map.fromEntries(entry.value.map((option) => MapEntry(option, null))));
    }
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
        ...buildConfigOptions(),
      ],
    );
  }

  List<Widget> buildConfigOptions() {
    if (_selectedKey == null) {
      return [];
    }
    return widget.optionMap[_selectedKey]?.map((option) => buildOption(option)).toList() ?? [];
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
          //TODO
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
