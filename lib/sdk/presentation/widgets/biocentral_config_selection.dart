import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/model/biocentral_config.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiocentralConfigSelection extends StatefulWidget {
  final BiocentralConfig config;
  final void Function(BiocentralConfig config) onConfigChanged;
  final String? label;
  final bool initiallyExpanded;
  final bool clusterByCategories;

  const BiocentralConfigSelection({
    required this.config,
    required this.onConfigChanged,
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

  BiocentralConfig _config = const BiocentralConfig.empty();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _config = widget.config;
  }

  @override
  void didUpdateWidget(covariant BiocentralConfigSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _config = widget.config;
  }

  void updateConfig(VoidCallback fn) {
    fn();
    if (_optionsFormKey.currentState != null && _optionsFormKey.currentState!.validate()) {
      widget.onConfigChanged(_config);
    }
    setState(() {});
  }

  Future<void> loadConfigFromFile(XFile? configFile, BiocentralProjectRepository projectRepository) async {
    if (_config.configHandler == null || configFile == null) {
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
      _config = await _config.load(configContent);

      updateConfig(
        () => setState(() {
          _isLoading = false;
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    return Column(
      children: [
        buildConfigLoading(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: buildConfigOptionsTable(),
        ),
      ],
    );
  }

  Widget buildConfigLoading() {
    if (_config.configHandler == null) {
      return Container();
    }
    final projectRepository = RepositoryProvider.of<BiocentralProjectRepository>(context);
    return BiocentralFilePathSelection(
      defaultName: 'Select existing config file..',
      fileSelectedCallback: (xFile, path) => loadConfigFromFile(xFile, projectRepository),
      allowedExtensions: _config.configHandler?.supportedFileExtensions().toList(),
    );
  }

  int _getNumberOfColumns(int numberOfOptions) {
    // TODO [Refactoring] Adjust dynamically also based on window size
    return 2;
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
    final String placeholder = '%placeholder%Key%!';
    var options = {placeholder: _config.options};
    if (options.isEmpty) {
      return Container();
    }
    if (widget.clusterByCategories) {
      options = _config.clusterByCategory();
    }
    return Form(
      key: _optionsFormKey,
      child: ExpansionTile(
        title: Text('${widget.label}-specific Configuration:'),
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
              ),
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
    if (option.constraints?.typeConstraint == Map) {
      return buildMapOption(option);
    }
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
          initialValue: _config.currentValueForKey(option.name).toString() ?? defaultValue,
          textAlign: TextAlign.center,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: option.constraints?.validator,
          onChanged: (String? newValue) {
            if (option.constraints != null) {
              final (valid, error, parsedValue) = option.constraints!.validate(newValue);
              if (valid) {
                updateConfig(() {
                  _config.update(option.name, parsedValue);
                });
              }
            } else {
              updateConfig(() {
                _config.update(option.name, newValue);
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
    var currentValue = _config.currentValueForKey(option.name);

    if (currentValue == null || currentValue.toString().isEmpty) {
      currentValue = defaultValue != '' ? defaultValue : allowedValues.first;
      _config.update(option.name, currentValue);
    }

    return _buildOptionDecoration(
      option: option,
      child: Center(
        child: BiocentralDiscreteSelection(
          title: '',
          initialValue: currentValue,
          selectableValues: allowedValues.toList(),
          onChangedCallback: (dynamic value) {
            if (value != currentValue) {
              updateConfig(() {
                _config.update(option.name, value);
              });
            }
          },
        ),
      ),
    );
  }

  Widget buildMapOption(BiocentralConfigOption option) {
    final Map<dynamic, dynamic> value = _config.currentValueForKey(option.name) ?? option.defaultValue;
    final int columnsPerRow = 4; // Adjust this number to change the number of columns

    return _buildOptionDecoration(
      option: option,
      child: SingleChildScrollView(
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: [
            for (int i = 0; i < value.length; i += columnsPerRow)
              TableRow(
                children: [
                  for (int j = 0; j < columnsPerRow; j++)
                    if (i + j < value.length)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: buildMapEntry(
                          option,
                          value.entries.elementAt(i + j),
                          value,
                        ),
                      )
                    else
                      Container(), // Empty container for padding
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildMapEntry(
    BiocentralConfigOption option,
    MapEntry entry,
    Map<dynamic, dynamic> value,
  ) {
    return SizedBox(
      width: 120,
      child: InputDecorator(
        decoration: InputDecoration(
          label: Text(entry.key.toString()),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: TextFormField(
          initialValue: entry.value.toString(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: option.constraints?.validator,
          textAlign: TextAlign.center,
          onChanged: (newValue) {
            updateConfig(() {
              final newMap = Map.of(value);
              newMap[entry.key] = int.tryParse(newValue) ?? entry.value;
              _config.update(option.name, newMap);
            });
          },
        ),
      ),
    );
  }
}
