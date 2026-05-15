import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_commands.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/plugins/active_learning/presentation/displays/al_iteration_config_display.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show FpdartOnIterable;

class ALIterationCommandDisplay extends StatefulWidget {
  const ALIterationCommandDisplay({super.key});

  @override
  State<ALIterationCommandDisplay> createState() => _ALIterationCommandDisplayState();

  static Widget visualizeIterationResult(BiocentralCommandLog result) {
    final commandResult = result.result?.result;
    if (commandResult == null || commandResult is! ActiveLearningIterationResult) {
      // TODO ERROR HANDLING
      return BiocentralStatusIndicator(metaData: result.metaData);
    }
    final iterationResult = commandResult;
    return Column(
      children: [
        BiocentralStatusIndicator(metaData: result.metaData),
        const Text('Suggestions:'),
        ...iterationResult.suggestions.map((entityID) => Text(entityID)),
      ],
    );
  }
}

class _ALIterationCommandDisplayState extends State<ALIterationCommandDisplay> {
  Type? _selectedDatabaseType = Protein;

  ALCampaign? _selectedCampaign;

  ActiveLearningIterationConfig? _iterationConfig;

  @override
  void initState() {
    super.initState();
  }

  ALIterationCommand? collectCommand() {
    if (_selectedCampaign != null && _iterationConfig != null) {
      return ALIterationCommand(
        biocentralDatabase: context.read<ProteinRepository>(),
        apiRepository: context.read(),
        alRepository: context.read(),
        campaign: _selectedCampaign!,
        iterationConfig: _iterationConfig!,
      );
    }
    return null;
  }

  List<SequenceTrainingData> collectIterationData() {
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    final column = database?.getColumn(_selectedCampaign?.columnName);
    if (database == null || column == null) {
      return [];
    }
    final trainingData = database.getTrainingData(targetColumn: column);
    return trainingData;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ALHubBloc, ALHubState>(
      builder: (context, state) {
        final availability = BiocentralCommandAvailability(
          available: state.campaigns.isNotEmpty,
          unavailableMessage: 'No current campaigns to add data to!',
        );
        return BiocentralCommandWidget(
          icon: const Icon(Icons.newspaper),
          name: 'Run new active learning iteration',
          description: 'Run a new iteration for one of your existing active learning campaign',
          executeButtonLabel: 'Run',
          parameterSelection: () => buildParameterSelection(state.campaigns),
          collectCommand: collectCommand,
          visualizeResult: ALIterationCommandDisplay.visualizeIterationResult,
          commandAvailability: availability,
        );
      },
    );
  }

  Widget buildParameterSelection(List<ALCampaign> campaigns) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          withCondition(condition: true, childFunction: buildDatasetSelection),
          withCondition(
            condition: _selectedDatabaseType != null,
            childFunction: () => buildCampaignSelection(campaigns),
          ),
          withCondition(condition: _selectedCampaign != null, childFunction: buildIterationConfigSelection),
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
        const Text('Do you want to run a campaign for proteins or protein-protein interactions?'),
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

  Widget buildCampaignSelection(List<ALCampaign> campaigns) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        BiocentralDiscreteSelection(
          title: 'Select campaign',
          initialValue: _selectedCampaign,
          selectableValues: campaigns,
          displayConversion: (campaign) => campaign.config.name,
          onChangedCallback: (ALCampaign? selected) {
            setState(() {
              _selectedCampaign = selected;
            });
          },
        ),
      ],
    );
  }


  Widget buildIterationConfigSelection() {
    return AlIterationConfigDisplay(
      iteration: (_selectedCampaign?.iterationResults.length ?? 0) + 1,
      maxNumberPossibleSuggestions: 5, // TODO
      iterationData: collectIterationData(),
      onChanged: (config) {
        setState(() {
          _iterationConfig = config;
        });
      },
    );
  }
}
