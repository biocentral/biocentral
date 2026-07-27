import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_commands.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/plugins/active_learning/presentation/commands/al_iteration_command_display.dart';
import 'package:biocentral/plugins/active_learning/presentation/displays/al_iteration_config_display.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/domain/biocentral_database_column.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/util/library_extensions_util.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:built_collection/src/list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewALCampaignCommandDisplay extends StatefulWidget {
  const NewALCampaignCommandDisplay({super.key});

  @override
  State<NewALCampaignCommandDisplay> createState() => _NewALCampaignCommandDisplayState();
}

class _NewALCampaignCommandDisplayState extends State<NewALCampaignCommandDisplay> {
  final Set<BiocentralDatabaseColumn> _availableFeatureColumns = {}; // Need to be partially unlabeled

  String _campaignName = 'AL-Campaign';
  Type? _selectedDatabaseType = Protein;

  // TODO Maybe refactor to separate campaign config selection
  ActiveLearningOptimizationMode? _selectedOptimizationMode;
  BiocentralDatabaseColumn? _selectedFeatureColumn;
  CommonEmbedder? _selectedEmbedder;
  ActiveLearningModelType? _selectedSurrogateModel;
  double? _targetValue;
  double? _targetLb;
  double? _targetUb;
  String? _desiredTargetClass;

  ActiveLearningScreeningIterationConfig? _iterationConfig;

  @override
  void initState() {
    super.initState();
  }

  ALIterationCommand? collectCommand() {
    final campaignConfig = buildCampaignConfig();
    if (campaignConfig != null && _iterationConfig != null) {
      final campaign = ALCampaign.startNew(config: campaignConfig, columnName: _selectedFeatureColumn!.name);
      return ALIterationCommand(
        biocentralDatabase: context.read<ProteinRepository>(),
        apiRepository: context.read(),
        alRepository: context.read(),
        campaign: campaign,
        iterationConfig: _iterationConfig!,
      );
    }
    return null;
  }

  bool isContinuousOptimizationModeSpecified() {
    final mode = _selectedOptimizationMode;
    if (mode == null || mode == ActiveLearningOptimizationMode.DISCRETE) {
      return false;
    }
    if (mode == ActiveLearningOptimizationMode.MINIMIZE || mode == ActiveLearningOptimizationMode.MAXIMIZE) {
      return true;
    }
    if (mode == ActiveLearningOptimizationMode.VALUE) {
      return _targetValue != null;
    }
    if (mode == ActiveLearningOptimizationMode.INTERVAL) {
      return _targetLb != null && _targetUb != null;
    }
    return false;
  }

  ActiveLearningScreeningCampaignConfig? buildCampaignConfig() {
    if (_selectedOptimizationMode != null &&
        _selectedEmbedder != null &&
        _selectedSurrogateModel != null &&
        (_desiredTargetClass != null || isContinuousOptimizationModeSpecified())) {
      return ActiveLearningScreeningCampaignConfig(
        (b) => b
          ..name = _campaignName
          ..embedderName = _selectedEmbedder!.wireName
          ..discreteTargets = ListBuilder<String>(_desiredTargetClass != null ? [_desiredTargetClass] : [])
          ..modelType = _selectedSurrogateModel
          ..optimizationMode = _selectedOptimizationMode
          ..targetLb = _targetLb
          ..targetUb = _targetUb,
      );
    }
    return null;
  }

  Set<BiocentralDatabaseColumn> getAvailableFeatureColumns(ActiveLearningOptimizationMode? mode) {
    if (mode == null) {
      return {};
    }

    Set<BiocentralDatabaseColumn>? existingPartiallyLabeledColumns;
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    if (database != null) {
      final numericOnly = mode != ActiveLearningOptimizationMode.DISCRETE;
      final binaryOnly = false;

      existingPartiallyLabeledColumns =
          database.getPartiallyUnlabeledColumnNames(numericOnly: numericOnly, binaryOnly: binaryOnly);
    }

    existingPartiallyLabeledColumns ??= {};

    return existingPartiallyLabeledColumns;
  }

  List<SequenceData> collectIterationData() {
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    if (database == null || _selectedFeatureColumn == null) {
      return [];
    }
    final trainingData = database.getTrainingData(targetColumn: _selectedFeatureColumn!);
    return trainingData;
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandWidget(
      icon: const Icon(Icons.model_training_outlined),
      name: 'Start a new active learning campaign',
      description: 'Find new interesting data points',
      executeButtonLabel: 'Start',
      parameterSelection: buildParameterSelection,
      collectCommand: collectCommand,
      visualizeResult: ALIterationCommandDisplay.visualizeIterationResult,
      commandAvailability: BiocentralCommandAvailability.always(),
    );
  }

  Widget buildParameterSelection() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          withCondition(condition: true, childFunction: buildCampaignNameInput),
          withCondition(condition: true, childFunction: buildDatasetSelection),
          withCondition(condition: _selectedDatabaseType != null, childFunction: buildOptimizationModeSelection),
          withCondition(condition: _selectedOptimizationMode != null, childFunction: buildFeatureSelection),
          withCondition(condition: _selectedFeatureColumn != null, childFunction: buildFeatureConfiguration),
          withCondition(
              condition: _selectedFeatureColumn != null &&
                  (_desiredTargetClass != null || isContinuousOptimizationModeSpecified()),
              childFunction: buildEmbedderSelection),
          withCondition(condition: _selectedEmbedder != null, childFunction: buildSurrogateModelSelection),
          withCondition(
              condition: _selectedSurrogateModel != null, childFunction: buildFirstIterationConfig),
        ].withPadding(
          const Padding(
            padding: EdgeInsetsGeometry.all(8.0),
          ),
        ),
      ),
    );
  }

  Widget buildCampaignNameInput() {
    return TextFormField(
          initialValue: _campaignName,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Campaign name',
          ),
          onChanged: (value) {
            setState(() {
              _campaignName = value.trim().isEmpty ? 'AL-Campaign' : value.trim();
            });
          },
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
            setState(() {
              _selectedDatabaseType = selected;
            });
          },
        ),
      ],
    );
  }

  Widget buildOptimizationModeSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('What type of task do you need to do?'),
        BiocentralDiscreteSelection<ActiveLearningOptimizationMode>(
          title: 'Task Type',
          initialValue: _selectedOptimizationMode,
          selectableValues: ActiveLearningOptimizationMode.values.toList(),
          onChangedCallback: (selected) {
            final availableFeatureColumns = getAvailableFeatureColumns(selected);
            setState(() {
              _selectedOptimizationMode = selected;
              _availableFeatureColumns.clear();
              _availableFeatureColumns.addAll(availableFeatureColumns);
            });
          },
        ),
      ],
    );
  }

  Widget buildFeatureSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('What type of feature do you want to optimize?'),
        BiocentralDiscreteSelection<BiocentralDatabaseColumn>(
          title: 'Feature',
          initialValue: _selectedFeatureColumn,
          selectableValues: _availableFeatureColumns.toList(),
          displayConversion: (column) => column.name,
          onChangedCallback: (selected) {
            setState(() {
              _selectedFeatureColumn = selected;
            });
          },
        ),
      ],
    );
  }

  Widget buildFeatureConfiguration() {
    final modeWidget = switch (_selectedOptimizationMode) {
      ActiveLearningOptimizationMode.DISCRETE => buildDiscreteTargetClassSelection(),
      ActiveLearningOptimizationMode.VALUE => TextFormField(),
      ActiveLearningOptimizationMode.MAXIMIZE => Container(),
      ActiveLearningOptimizationMode.MINIMIZE => Container(),
      ActiveLearningOptimizationMode.INTERVAL => Row(
          children: [TextFormField(), TextFormField()],
        ),
      null => Container(),
      ActiveLearningOptimizationMode() => Container(),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        modeWidget,
      ],
    );
  }

  Widget buildDiscreteTargetClassSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select desired target class:', style: TextStyle(fontSize: 16)),
        BiocentralDiscreteSelection<String>(
          title: 'Target Class',
          initialValue: _desiredTargetClass,
          selectableValues: _selectedFeatureColumn?.uniqueValues().toList() ?? [],
          onChangedCallback: (selected) {
            setState(() {
              _desiredTargetClass = selected;
            });
          },
        ),
      ],
    );
  }

  Widget buildEmbedderSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Which embedder model do you want to use?'),
        Flexible(
          child: BiocentralDiscreteSelection(
            title: 'Select Embedder Model',
            initialValue: _selectedEmbedder,
            selectableValues: CommonEmbedder.values.toList(),
            displayConversion: (embedder) => embedder.displayName(),
            onChangedCallback: (embedder) {
              setState(() {
                _selectedEmbedder = embedder;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildSurrogateModelSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Which surrogate model do you want to use?'),
        Flexible(
          child: BiocentralDiscreteSelection(
            title: 'Select Surrogate Model',
            initialValue: _selectedSurrogateModel,
            selectableValues: ActiveLearningModelType.values.toList(),
            onChangedCallback: (surrogate) {
              setState(() {
                _selectedSurrogateModel = surrogate;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildFirstIterationConfig() {
    return AlIterationConfigDisplay(
      iteration: 1,
      maxNumberPossibleSuggestions: _selectedFeatureColumn!.numberNull,
      iterationData: collectIterationData(),
      onChanged: (config) {
        setState(() {
          _iterationConfig = config;
        });
      },
    );
  }
}
