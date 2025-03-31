import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_generic_config_parser.dart';
import 'package:biocentral/sdk/model/biocentral_config_option.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiocentralConfigSelection extends StatefulWidget {
  final Map<String, List<BiocentralConfigOption>> optionMap;
  final void Function(String? selectedKey, Map<String, Map<BiocentralConfigOption, dynamic>> config) onConfigChangedCallback;
  final BiocentralGenericConfigHandler? configHandler;
  final String? label;
  final bool initiallyExpanded;
  final bool clusterByCategories;

  const BiocentralConfigSelection({
    required this.optionMap,
    required this.onConfigChangedCallback,
    this.configHandler,
    this.label,
    this.initiallyExpanded = true,
    this.clusterByCategories = false,
    super.key,
  });

  @override
  State<BiocentralConfigSelection> createState() => _BiocentralConfigSelectionState();
}

class _BiocentralConfigSelectionState extends State<BiocentralConfigSelection> {
  final GlobalKey<FormState> _optionsFormKey = GlobalKey<FormState>();

  String? _selectedKey;
  final Map<String, Map<BiocentralConfigOption, dynamic>> _chosenOptions = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (final entry in widget.optionMap.entries) {
      _chosenOptions.putIfAbsent(
          entry.key, () => Map.fromEntries(entry.value.map((option) => MapEntry(option, option.defaultValue))));
    }
    if (widget.optionMap.keys.length == 1) {
      _selectedKey = widget.optionMap.keys.first;
    }
  }

  void updateConfig(VoidCallback fn) {
    final oldSelectedKey = _selectedKey;
    fn();
    if (oldSelectedKey != _selectedKey) {
      widget.onConfigChangedCallback(_selectedKey, _chosenOptions);
    } else {
      if (_optionsFormKey.currentState != null && _optionsFormKey.currentState!.validate()) {
        widget.onConfigChangedCallback(_selectedKey, _chosenOptions);
      }
    }
    setState(() {});
  }

  Future<void> loadConfigFromFile(XFile configFile, BiocentralProjectRepository projectRepository) async {
    if(widget.configHandler == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final loadEither = await projectRepository.handleLoad(xFile: configFile);
    await loadEither.match(
        (error) async => setState(() {
              // TODO [Error Handling]
              _isLoading = false;
            }), (loadedFileData) async {
      final configContent = loadedFileData?.content;
      final Map<String, Map<BiocentralConfigOption, dynamic>> updatedOptions = {};
      for (final (key, configMap) in _chosenOptions.entriesRecord) {
        final updatedConfigMap = await widget.configHandler!.parse(configContent, configMap);
        updatedOptions[key] = updatedConfigMap;
      }
      setState(() {
        _chosenOptions.clear();
        _chosenOptions.addAll(updatedOptions);
        _isLoading = false;
      });
      updateConfig(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget discreteSelection = widget.optionMap.keys.length > 1
        ? BiocentralDiscreteSelection(
            title: widget.label ?? '',
            selectableValues: widget.optionMap.keys.toList(),
            onChangedCallback: (String? value) {
              updateConfig(() {
                _selectedKey = value;
              });
            },
          )
        : Container();
    if(_isLoading) {
      return const CircularProgressIndicator();
    }
    return Column(
      children: [
        buildConfigLoading(),
        discreteSelection,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: buildConfigOptionsTable(),
        ),
      ],
    );
  }

  Widget buildConfigLoading() {
    if(widget.configHandler == null) {
      return Container();
    }
    final projectRepository = RepositoryProvider.of<BiocentralProjectRepository>(context);
    return BiocentralFilePathSelection(
      defaultName: 'Select existing config file..',
      fileSelectedCallback: (xFile) => loadConfigFromFile(xFile, projectRepository),
      allowedExtensions: widget.configHandler?.supportedFileExtensions().toList(),
    );
  }

  int _getNumberOfColumns(int numberOfOptions) {
    // TODO [Refactoring] Adjust dynamically also based on window size
    if (numberOfOptions % 4 == 0) return 4;
    if (numberOfOptions % 3 == 0) return 3;
    return 2;
  }

  Map<String, List<BiocentralConfigOption>> _clusterByCategory(List<BiocentralConfigOption> options) {
    final String fallbackName = 'other';
    final Map<String, List<BiocentralConfigOption>> result = {};
    for (final option in options) {
      final optionCategory = option.category ?? fallbackName;
      result.putIfAbsent(optionCategory, () => []);
      result[optionCategory]?.add(option);
    }
    return result;
  }

  Widget _buildTable(List<BiocentralConfigOption> options) {
    final int columns = _getNumberOfColumns(options.length);
    return Table(
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
    );
  }

  Widget buildConfigOptionsTable() {
    final String placeholder = "%placeholder%Key%!";
    var options = {placeholder: widget.optionMap[_selectedKey] ?? []};
    if (_selectedKey == null || options.isEmpty) {
      return Container();
    }
    if (widget.clusterByCategories) {
      options = _clusterByCategory(options[placeholder]?.toList() ?? []);
    }
    return Form(
      key: _optionsFormKey,
      child: ExpansionTile(
        title: Text('$_selectedKey-specific Configuration:'),
        initiallyExpanded: widget.initiallyExpanded,
        children: [
          if (options.length == 1)
            _buildTable(options[placeholder] ?? [])
          else
            for (final entry in options.entries)
              ExpansionTile(
                title: Text(entry.key),
                children: [
                  _buildTable(entry.value),
                ],
              )
        ],
      ),
    );
  }

  Widget _buildOptionDecoration({required BiocentralConfigOption option, required Widget child}) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: option.name,
        // Add a suffix icon if description is available
        suffixIcon: option.description != null && option.description!.isNotEmpty
            ? BiocentralTooltip(
                message: option.description!,
                child: IconButton(
                  icon: Icon(Icons.help_outline, color: Colors.grey[600]),
                  onPressed: null, // Prevents additional action
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: child,
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
    return _buildOptionDecoration(
      option: option,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: TextFormField(
          initialValue: _chosenOptions[_selectedKey]?[option].toString() ?? defaultValue,
          textAlign: TextAlign.center,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: option.constraints?.validator,
          onChanged: (String? newValue) {
            if (option.constraints != null) {
              final (valid, error, parsedValue) = option.constraints!.validate(newValue);
              if (valid) {
                updateConfig(() {
                  _chosenOptions[_selectedKey]?[option] = parsedValue;
                });
              }
            } else {
              updateConfig(() {
                _chosenOptions[_selectedKey]?[option] = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget buildSelectionOption(BiocentralConfigOption option) {
    final allowedValues = option.constraints?.allowedValues ?? {};
    final dynamic defaultValue = option.defaultValue.toString();
    var chosenOption = _chosenOptions[_selectedKey]?[option];

    if (chosenOption == null || chosenOption == '') {
      chosenOption = defaultValue != '' ? defaultValue : allowedValues.first;
      _chosenOptions[_selectedKey]?[option] = chosenOption;
    }

    return _buildOptionDecoration(
      option: option,
      child: Center(
        child: BiocentralDiscreteSelection(
          title: '',
          initialValue: chosenOption,
          selectableValues: allowedValues.toList(),
          onChangedCallback: (dynamic value) {
            if (value != _chosenOptions[_selectedKey]?[option]) {
              updateConfig(() {
                chosenOption = value;
                _chosenOptions[_selectedKey]?[option] = chosenOption;
              });
            }
          },
        ),
      ),
    );
  }
}
