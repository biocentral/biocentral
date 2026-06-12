import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_commands.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show FpdartOnIterable;

class AddExperimentalDataCommandDisplay extends StatefulWidget {
  const AddExperimentalDataCommandDisplay({super.key});

  @override
  State<AddExperimentalDataCommandDisplay> createState() => _AddExperimentalDataCommandDisplayState();
}

class _AddExperimentalDataCommandDisplayState extends State<AddExperimentalDataCommandDisplay> {
  Type? _selectedDatabaseType = Protein;

  ALCampaign? _selectedCampaign;

  final Map<String, String> _addedData = {};

  @override
  void initState() {
    super.initState();
  }

  ALAddExperimentalDataCommand? collectCommand() {
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    final addedNonEmptyData = <String, String>{};
    for(final (k, v) in _addedData.entriesRecord) {
      if(v.isNotEmpty) {
        addedNonEmptyData[k] = v;
      }
    }
    if (database != null && _selectedCampaign != null && addedNonEmptyData.isNotEmpty) {
      return ALAddExperimentalDataCommand(
        database: database,
        columnName: _selectedCampaign!.columnName,
        addedData: addedNonEmptyData,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ALHubBloc, ALHubState>(
      listenWhen: (previous, current) => previous.selectedCampaign != current.selectedCampaign,
      listener: (context, state) {
        setState(() {
          _selectedCampaign = state.selectedCampaign;
          _addedData.clear();
          if (_selectedCampaign != null) {
            final iterationSuggestions =
                _selectedCampaign!.iterationResults.lastOrNull?.$2.suggestions.toList() ?? [];
            _addedData.addEntries(iterationSuggestions.map((suggestion) => MapEntry(suggestion, '')));
          }
        });
      },
      builder: (context, state) {
        final availability = BiocentralCommandAvailability(
          available: state.campaigns.isNotEmpty,
          unavailableMessage: 'No current campaigns to add data to!',
        );
        return BiocentralCommandWidget(
          icon: const Icon(Icons.new_label),
          name: 'Add experimental data to campaign',
          description: 'Add experimentally verified data to a running active learning campaign',
          executeButtonLabel: 'Add',
          parameterSelection: () => buildParameterSelection(state.campaigns),
          collectCommand: collectCommand,
          visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
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
          withCondition(condition: _selectedCampaign != null, childFunction: buildDataInput),
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
          title: 'Select campaign to add data to',
          initialValue: _selectedCampaign,
          selectableValues: campaigns,
          displayConversion: (campaign) => campaign.config.name,
          onChangedCallback: (ALCampaign? selected) {
            setState(() {
              _selectedCampaign = selected;
              _addedData.clear();
              if (_selectedCampaign != null) {
                final iterationSuggestions =
                    _selectedCampaign!.iterationResults.lastOrNull?.$2.suggestions.toList() ?? [];
                _addedData.addEntries(iterationSuggestions.map((suggestion) => MapEntry(suggestion, '')));
              }
            });
          },
        ),
      ],
    );
  }

  Widget buildDataInput() {
    if (_selectedCampaign == null) {
      return Container();
    }
    if (_selectedCampaign!.iterationResults.isEmpty) {
      return const Text('Selected campaign does not have any results yet to add data!');
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Input Data'),
        ..._selectedCampaign!.iterationResults.last.$2.suggestions.map((suggestion) => TextFormField(
          decoration: InputDecoration(labelText: suggestion),
          textAlign: TextAlign.center,
          initialValue: _addedData[suggestion],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // TODO Improve validation
          validator: (val) => val == null || val.isEmpty ? 'Column name must not be empty!' : null,
          onChanged: (val) {
            setState(() {
              _addedData[suggestion] = val.toString();
            });
          },
        )),
      ],
    );
  }
}
