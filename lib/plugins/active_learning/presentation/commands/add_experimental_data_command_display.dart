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

class AddExperimentalDataCommandDisplay extends StatefulWidget {
  const AddExperimentalDataCommandDisplay({super.key});

  @override
  State<AddExperimentalDataCommandDisplay> createState() => _AddExperimentalDataCommandDisplayState();
}

class _AddExperimentalDataCommandDisplayState extends State<AddExperimentalDataCommandDisplay> {
  Type? _selectedDatabaseType = Protein;

  ALCampaign? _selectedCampaign;

  // Suggested sequence IDs (from latest iteration suggestions)
  final Map<String, String> _addedData = {};
  // Extra sequence IDs (user-staged, not in suggestions)
  final Map<String, String> _extraData = {};

  // State for pending extra-entry row
  String? _pendingExtraId;
  final TextEditingController _extraValueController = TextEditingController();
  
  // Changing this key forces BiocentralDiscreteSelection to fully rebuild and clear its internal selection after an entry is staged.
  Key _dropdownKey = UniqueKey();

  @override
  void dispose() {
    _extraValueController.dispose();
    super.dispose();
  }

  void _resetCampaignState(ALCampaign? campaign) {
    _selectedCampaign = campaign;
    _addedData.clear();
    _extraData.clear();
    _pendingExtraId = null;
    _extraValueController.clear();
    _dropdownKey = UniqueKey();
    if (campaign != null) {
      final suggestions = campaign.iterationResults.lastOrNull?.$2.suggestions.toList() ?? [];
      _addedData.addEntries(suggestions.map((s) => MapEntry(s, '')));
    }
  }

  ALAddExperimentalDataCommand? collectCommand() {
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    final merged = {..._addedData, ..._extraData};
    final addedNonEmptyData = <String, String>{};
    for (final (k, v) in merged.entriesRecord) {
      if (v.isNotEmpty) {
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
          _resetCampaignState(state.selectedCampaign);
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
          parameterSelection: () => buildParameterSelection(state.campaigns, state.proteinDatabase),
          collectCommand: collectCommand,
          visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
          commandAvailability: availability,
        );
      },
    );
  }

  Widget buildParameterSelection(List<ALCampaign> campaigns, Map<String, Protein> proteinDatabase) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          withCondition(condition: true, childFunction: buildDatasetSelection),
          withCondition(
            condition: _selectedDatabaseType != null,
            childFunction: () => buildCampaignSelection(campaigns),
          ),
          withCondition(condition: _selectedCampaign != null, childFunction: () => buildDataInput(proteinDatabase)),
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
              _resetCampaignState(selected);
            });
          },
        ),
      ],
    );
  }

  Widget buildDataInput(Map<String, Protein> proteinDatabase) {
    if (_selectedCampaign == null) {
      return const SizedBox.shrink(); // TODO: compare to Container() to see if it makes any difference
    }
    if (_selectedCampaign!.iterationResults.isEmpty) {
      return const Text('Selected campaign does not have any results yet to add data!');
    }

    final suggestionSet = _addedData.keys.toSet();
    
    final availableForExtra = proteinDatabase.entries
        .where((e) {
          final existing = e.value.attributes[_selectedCampaign!.columnName];
          final hasData = existing != null && existing.toString().isNotEmpty;
          return !hasData && !suggestionSet.contains(e.key) && !_extraData.containsKey(e.key);
        })
        .map((e) => e.key).toList()..sort();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Suggested sequences'),
        ),
        ..._addedData.keys.map((suggestion) => TextFormField(
          decoration: InputDecoration(labelText: suggestion),
          textAlign: TextAlign.center,
          initialValue: _addedData[suggestion],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // TODO Improve validation
          validator: (val) => val == null || val.isEmpty ? 'Value must not be empty!' : null,
          onChanged: (val) {
            setState(() {
              _addedData[suggestion] = val; // TODO: check if val.toString() makes a difference
            });
          },
        ),),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(),
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Add data for other sequences (optional)'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: BiocentralDiscreteSelection<String>(
                key: _dropdownKey,
                title: 'Select sequence',
                selectableValues: availableForExtra,
                displayConversion: (id) => id,
                initialValue: _pendingExtraId,
                onChangedCallback: (String? selected) {
                  setState(() {
                    _pendingExtraId = selected;
                  });
                },
              ),
            ),
            const SizedBox(width: 8), // TODO: check if these should be in a single row instead of underneath each other
            Expanded(
              child: TextFormField(
                controller: _extraValueController,
                decoration: const InputDecoration(labelText: 'Value'),
                textAlign: TextAlign.center,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            BiocentralSmallButton(
              label: 'Stage',
              onTap: _pendingExtraId != null && _extraValueController.text.isNotEmpty ? () {
                final id = _pendingExtraId!;
                final value = _extraValueController.text;
                _extraValueController.clear();
                setState(() {
                  _extraData[id] = value;
                  _pendingExtraId = null;
                  _dropdownKey = UniqueKey();
                });
              } : null,
            ),
          ],
        ),
        
        if (_extraData.isNotEmpty) ...[
          const SizedBox(height: 8),
          ..._extraData.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(entry.key, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove',
                  onPressed: () {
                    setState(() {
                      _extraData.remove(entry.key);
                    });
                  },
                ),
              ],
            ),
          ),),
        ],
      ],
    );
  }
}
