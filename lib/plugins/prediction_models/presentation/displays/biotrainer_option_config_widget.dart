import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_config_dialog_bloc.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';

class BiotrainerOptionalConfigWidget extends StatefulWidget {
  final BiotrainerOption option;

  const BiotrainerOptionalConfigWidget({required this.option, super.key});

  @override
  State<BiotrainerOptionalConfigWidget> createState() => _BiotrainerOptionalConfigWidgetState();
}

class _BiotrainerOptionalConfigWidgetState extends State<BiotrainerOptionalConfigWidget> {
  final TextEditingController optionController = TextEditingController();

  String chosenOption = '';

  @override
  void initState() {
    super.initState();
    chosenOption = widget.option.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final BiotrainerConfigBloc biotrainerConfigBloc = BlocProvider.of<BiotrainerConfigBloc>(context);

    Widget selector;
    if (widget.option.category.contains('input')) {
      selector = buildInputOption(biotrainerConfigBloc);
    } else {
      selector = buildOption(biotrainerConfigBloc);
    }

    return ListTile(
      leading: Text(widget.option.name),
      title: selector,
    );
  }

  Widget buildInputOption(BiotrainerConfigBloc biotrainerConfigBloc) {
    Iterable<String> columnNames = [];
    if (widget.option.name.contains('sequence')) {
      columnNames = ['SEQUENCE'];
    } else if (widget.option.name.contains('target')) {
      //TODO Might be at a bad position costing performance
      //columnNames = proteinRepository.getAvailableAttributesForAllProteins().toList();
    }

    if (chosenOption == '') {
      chosenOption = columnNames.elementAtOrNull(0) ?? '';
    }

    return BiocentralDropdownMenu<String>(
      label: Text("${widget.option.name.split("_").first} column"),
      controller: optionController..text = chosenOption,
      dropdownMenuEntries: columnNames.map((value) => DropdownMenuEntry<String>(value: value, label: value)).toList(),
      onSelected: (String? value) {
        biotrainerConfigBloc.add(BiotrainerConfigChangeOptionalConfigEvent(widget.option.name, value ?? ''));
        setState(() {
          chosenOption = value!;
        });
      },
    );
  }

  // TODO [Refactor] Use BiocentralConfigSelection
  Widget buildOption(BiotrainerConfigBloc biotrainerConfigBloc) {
    if (widget.option.possibleValues.isEmpty) {
      return buildTextOption(biotrainerConfigBloc);
    } else {
      return buildSelectionOption(biotrainerConfigBloc);
    }
  }

  Widget buildTextOption(BiotrainerConfigBloc biotrainerConfigBloc) {
    final String defaultValue = widget.option.defaultValue;
    return Align(
        alignment: Alignment.bottomCenter,
        child: TextFormField(
          initialValue: defaultValue,
          textAlign: TextAlign.center,
          onChanged: (String? newValue) {
            biotrainerConfigBloc.add(BiotrainerConfigChangeOptionalConfigEvent(widget.option.name, newValue ?? ''));
          },
        ),);
  }

  Widget buildSelectionOption(BiotrainerConfigBloc biotrainerConfigBloc) {
    final List<String> possibleValues = widget.option.possibleValues;
    final String defaultValue = widget.option.defaultValue;

    if (chosenOption == '') {
      chosenOption = defaultValue != '' ? defaultValue : possibleValues.first;
    }
    if (defaultValue != '' && !possibleValues.contains(defaultValue)) {
      possibleValues.add(defaultValue);
    }

    return BiocentralDropdownMenu<String>(
      controller: optionController..text = chosenOption,
      label: Text(widget.option.name),
      dropdownMenuEntries:
          possibleValues.map((value) => DropdownMenuEntry<String>(value: value, label: value)).toList(),
      onSelected: (String? value) {
        biotrainerConfigBloc.add(BiotrainerConfigChangeOptionalConfigEvent(widget.option.name, value ?? ''));
        setState(() {
          chosenOption = value!;
        });
      },
    );
  }
}
