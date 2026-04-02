import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/custom_models/bloc/models_commands.dart';
import 'package:biocentral/plugins/custom_models/data/biotrainer_output_dir_handler.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/domain/biocentral_database_column.dart';
import 'package:biocentral/sdk/model/split_set.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_directory_path_selection.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_ratio_slider.dart';
import 'package:biocentral/sdk/util/path_util.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplitDataCommandDisplay extends StatefulWidget {
  const SplitDataCommandDisplay({super.key});

  @override
  State<SplitDataCommandDisplay> createState() => _SplitDataCommandDisplayState();
}

class _SplitDataCommandDisplayState extends State<SplitDataCommandDisplay> {
  final Set<SplitSetGenerationMethod> _availableMethods = const {SplitSetGenerationMethod.random};
  final Map<BiocentralDatabaseColumn, Set<SplitSet>> _availableSourceSets = {};

  Type? _selectedDatabaseType = Protein;
  int? _selectedDatabaseLength;
  SplitSetGenerationMode? _mode;
  BiocentralDatabaseColumn? _selectedSetColumn;
  SplitSet? _subsplitSource;
  SplitSet? _subsplitTarget;
  SplitSetGenerationMethod? _method;
  SplitRatio? _splitRatio;

  @override
  void initState() {
    super.initState();
    final availableSourceSets = getAvailableSourceSets();
    _availableSourceSets.clear();
    _availableSourceSets.addAll(availableSourceSets);
  }
  SplitDataCommand? collectCommand() {
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    if (_mode == null || database == null) {
      return null;
    }
    if (_mode == SplitSetGenerationMode.generateNew) {
      if (_method != null && _splitRatio != null) {
        return SplitDataCommand(database: database, mode: _mode!, method: _method!, splitRatio: _splitRatio!);
      }
    } else {
      if (_selectedSetColumn != null && _subsplitSource != null && _subsplitTarget == null) {
        return SplitDataCommand(
            database: database,
            mode: _mode!,
            method: _method!,
            splitRatio: _splitRatio!,
            selectedSetColumn: _selectedSetColumn,
            subsplitSource: _subsplitSource,
            subsplitTarget: _subsplitTarget);
      }
    }
    return null;
  }

  void applyConfiguratorHierarchy() {
    // TODO Consider previous mode here
    if (_mode == null) {
      _selectedSetColumn = null;
    }

    if (_mode != SplitSetGenerationMode.subsplitExisting) {
      _subsplitSource = null;
      _subsplitTarget = null;
      _selectedSetColumn = null;
    }
    if (_selectedSetColumn == null) {
      _subsplitSource = null;
      _subsplitTarget = null;
    }
    if (_subsplitSource == null) {
      _subsplitTarget = null;
    }
    if (_method == null) {
      _splitRatio = null;
    }
    if (_mode != null && _method != null) {
      _splitRatio ??= SplitRatio.defaultForMode(_mode!);
    }
  }

  Map<BiocentralDatabaseColumn, Set<SplitSet>> getAvailableSourceSets() {
    Set<BiocentralDatabaseColumn>? existingSetColumns;
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    if (database != null) {
      existingSetColumns = database.getSetColumns();
    }

    existingSetColumns ??= {};

    // Get available sets from the selected column for subsplitting
    final availableSourceSets = Map.fromEntries(
      existingSetColumns
          .map((column) => MapEntry(column, column.detectSplitSets()))
          .where((entry) => entry.value.length <= 2),
    );
    return availableSourceSets;
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandWidget(
      icon: const Icon(Icons.splitscreen_outlined),
      name: 'Split your data',
      description: 'Split your data into robust sets (e.g. train/val/test) for model training',
      executeButtonLabel: 'Split',
      parameterSelection: buildParameterSelection,
      collectCommand: collectCommand,
      visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
      commandAvailability: BiocentralCommandAvailability.always(),
    );
  }

  Widget buildParameterSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          withCondition(condition: true, childFunction: buildDatasetSelection),
          withCondition(condition: _selectedDatabaseType != null, childFunction: buildModeSelection),
          withCondition(
            condition: _mode == SplitSetGenerationMode.subsplitExisting && _availableSourceSets.isNotEmpty,
            childFunction: buildExistingSetSelection,
          ),
          withCondition(
            condition: _mode == SplitSetGenerationMode.subsplitExisting && _selectedSetColumn != null,
            childFunction: buildSourceSetSelection,
          ),
          withCondition(
            condition: _mode == SplitSetGenerationMode.subsplitExisting &&
                _selectedSetColumn != null &&
                _subsplitSource != null,
            childFunction: buildNewSetNameSelection,
          ),
          withCondition(
            condition: _mode == SplitSetGenerationMode.generateNew || _subsplitTarget != null,
            childFunction: buildMethodSelection,
          ),
          withCondition(condition: _method != null, childFunction: buildRatioSlider),
        ].withPadding(
          const Padding(
            padding: EdgeInsetsGeometry.all(8.0),
          ),
        ),
      ),
    );
  }

  Widget buildDatasetSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Do you want to generate a set for proteins or protein-protein interactions?'),
        BiocentralEntityTypeSelection(
          initialValue: _selectedDatabaseType,
          onChangedCallback: (Type? selected) {
            final availableSourceSets = getAvailableSourceSets();
            setState(() {
              _selectedDatabaseType = selected;
              _availableSourceSets.clear();
              _availableSourceSets.addAll(availableSourceSets);
              applyConfiguratorHierarchy();
            });
          },
        ),
      ],
    );
  }

  Widget buildModeSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Do you want to create new splits or subsplit an existing set?'),
        Row(
          children: [
            Expanded(
              child: BiocentralDropdownMenu<SplitSetGenerationMode>(
                label: const Text('Mode..'),
                initialSelection: _mode,
                dropdownMenuEntries: [
                  const DropdownMenuEntry<SplitSetGenerationMode>(
                    value: SplitSetGenerationMode.generateNew,
                    label: 'Create new splits',
                  ),
                  DropdownMenuEntry<SplitSetGenerationMode>(
                    value: SplitSetGenerationMode.subsplitExisting,
                    label: 'Subsplit existing set',
                    enabled: _availableSourceSets.isNotEmpty,
                  ),
                ],
                onSelected: (SplitSetGenerationMode? value) {
                  setState(() {
                    _mode = value;
                    applyConfiguratorHierarchy();
                  });
                },
              ),
            ),
          ],
        ),
        if (_mode == SplitSetGenerationMode.subsplitExisting && _availableSourceSets.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'No existing set columns found in the database.',
              style: TextStyle(color: Colors.orange),
            ),
          ),
      ],
    );
  }

  Widget buildExistingSetSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Select the existing set column to subsplit:'),
        Row(
          children: [
            Expanded(
              child: BiocentralDropdownMenu<BiocentralDatabaseColumn>(
                label: const Text('Existing set column..'),
                dropdownMenuEntries: _availableSourceSets.keys
                    .map(
                      (BiocentralDatabaseColumn column) =>
                          DropdownMenuEntry<BiocentralDatabaseColumn>(value: column, label: column.name),
                    )
                    .toList(),
                onSelected: (BiocentralDatabaseColumn? value) {
                  setState(() {
                    _selectedSetColumn = value;
                    applyConfiguratorHierarchy();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSourceSetSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Select which set to split:'),
        Row(
          children: [
            Expanded(
              child: BiocentralDropdownMenu<SplitSet>(
                label: const Text('Source set..'),
                dropdownMenuEntries: _availableSourceSets[_selectedSetColumn]
                        ?.map((SplitSet set) => DropdownMenuEntry<SplitSet>(value: set, label: set.name))
                        .toList() ??
                    [],
                onSelected: (SplitSet? value) {
                  setState(() {
                    _subsplitSource = value;
                    applyConfiguratorHierarchy();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildNewSetNameSelection() {
    final List<SplitSet> availableNames = SplitSet.values.where((set) => set != _subsplitSource).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Select the name for the new subsplit:'),
        Row(
          children: [
            Expanded(
              child: BiocentralDropdownMenu<SplitSet>(
                label: const Text('New set name..'),
                dropdownMenuEntries: availableNames
                    .map((SplitSet set) => DropdownMenuEntry<SplitSet>(value: set, label: set.name))
                    .toList(),
                onSelected: (SplitSet? value) {
                  setState(() {
                    _subsplitTarget = value;
                    applyConfiguratorHierarchy();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMethodSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Which kind of set generation method should be applied?'),
        Row(
          children: [
            Expanded(
              child: BiocentralDropdownMenu<SplitSetGenerationMethod>(
                label: const Text('Method..'),
                dropdownMenuEntries: _availableMethods
                    .map(
                      (SplitSetGenerationMethod method) =>
                          DropdownMenuEntry<SplitSetGenerationMethod>(value: method, label: method.name),
                    )
                    .toList(),
                onSelected: (SplitSetGenerationMethod? value) => setState(() {
                  _method = value;
                  applyConfiguratorHierarchy();
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildRatioSlider() {
    Widget slider;
    if (_mode == SplitSetGenerationMode.subsplitExisting) {
      slider = BiocentralRatioSlider(
        ratio1: _splitRatio!.r1,
        totalN: _selectedSetColumn?.length,
        labels: [_subsplitSource!.name, _subsplitTarget!.name],
        colors: const [
          Colors.blue,
          Colors.black,
        ],
        onChanged: (ratios) {
          setState(() {
            _splitRatio = SplitRatio.fromRecord(ratios);
            applyConfiguratorHierarchy();
          });
        },
      );
    } else {
      slider = BiocentralRatioSlider(
        ratio1: _splitRatio!.r1,
        ratio2: _splitRatio?.r2,
        totalN: _selectedDatabaseLength,
        labels: const ['Training', 'Validation', 'Test'],
        colors: const [Colors.blue, Colors.black, Colors.blueGrey],
        onChanged: (ratios) {
          setState(() {
            _splitRatio = SplitRatio.fromRecord(ratios);
            applyConfiguratorHierarchy();
          });
        },
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Select the size of the subsplit:'),
        slider,
      ],
    );
  }
}
