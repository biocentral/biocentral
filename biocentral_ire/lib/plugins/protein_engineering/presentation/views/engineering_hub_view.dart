import 'dart:convert';

import 'package:biocentral/biocentral/bloc/biocentral_sidebar_bloc.dart';
import 'package:biocentral/plugins/protein_engineering/bloc/engineering_commands.dart';
import 'package:biocentral/plugins/protein_engineering/bloc/engineering_hub_bloc.dart';
import 'package:biocentral/plugins/protein_engineering/domain/engineering_repository.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/engineering_actions.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/views/engineering_lineage_page.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/views/engineering_mutations_page.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/views/engineering_overview_page.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/views/engineering_rounds_page.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/views/new_engineering_campaign_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _engineeringCommandNames = {
  'NewEngineeringCampaignCommand',
  'UpdateEngineeringRestrictionsCommand',
  'AddEngineeringMeasurementsCommand',
  'UploadWildtypeStructureCommand',
  'DeleteEngineeringCampaignCommand',
  'LoadEngineeringCampaignCommand',
  'ExportEngineeringCampaignCommand',
  'RunEngineeringRoundCommand',
};

/// Composes engineering navigation and pages using shared SDK components.
class EngineeringHubView extends StatefulWidget {
  const EngineeringHubView({super.key});

  @override
  State<EngineeringHubView> createState() => _EngineeringHubViewState();
}

class _EngineeringHubViewState extends State<EngineeringHubView> {
  EngineeringCampaign? _source;
  int _wizardGeneration = 0;
  final Map<String, int> _positionRuleRequests = {};

  void _section(EngineeringSection section, {int? roundIndex}) =>
      context.read<EngineeringHubBloc>().add(EngineeringSectionSelected(section, roundIndex: roundIndex));

  void _newCampaign([EngineeringCampaign? source]) {
    setState(() {
      _source = source;
      _wizardGeneration++;
    });
    _section(EngineeringSection.newCampaign);
  }

  Future<void> _delete(BuildContext context, EngineeringCampaign campaign) async {
    final confirmed = await showBiocentralConfirmation(
      context,
      title: 'Delete campaign?',
      message: '"${campaign.config.name}" and its rounds and measurements will be deleted.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!context.mounted || !confirmed) return;
    submitEngineeringCommand(
      context,
      DeleteEngineeringCampaignCommand(repository: context.read<EngineeringRepository>(), campaign: campaign),
    );
  }

  Future<void> _import(BuildContext context) async {
    final input = await pickEngineeringInput('json');
    if (!context.mounted || input == null) return;
    final campaigns = decodeEngineeringCampaigns(utf8.decode(input.bytes));
    final repository = context.read<EngineeringRepository>();
    final conflicts = campaigns.where((campaign) => repository.campaign(campaign.id) != null).toList();
    final overwrite =
        conflicts.isEmpty ||
        await showBiocentralConfirmation(
          context,
          title: 'Replace existing campaigns?',
          message: conflicts.map((campaign) => campaign.config.name).join('\n'),
          confirmLabel: 'Replace',
        );
    if (!context.mounted || !overwrite) return;
    submitEngineeringCommand(
      context,
      LoadEngineeringCampaignCommand(repository: repository, input: input, mode: DatabaseImportMode.overwrite),
    );
  }

  Future<void> _export(BuildContext context, EngineeringCampaign campaign) async {
    final path = await FilePicker.platform.saveFile(fileName: '${campaign.config.name}.json');
    if (!context.mounted || path == null) return;
    final separator = path.lastIndexOf(RegExp(r'[/\\]'));
    submitEngineeringCommand(
      context,
      ExportEngineeringCampaignCommand(
        projectRepository: context.read<BiocentralProjectRepository>(),
        campaign: campaign,
        fileName: path.substring(separator + 1),
        directory: path.substring(0, separator + 1),
      ),
    );
  }

  Future<void> _perform(Future<void> Function() operation) => performEngineeringAction(context, operation);

  void _activity() => context.read<BiocentralSideBarBloc>().add(
    BiocentralSideBarChangeVisibilityEvent(displayMode: BiocentralSideBarDisplayMode.commandLog),
  );

  @override
  Widget build(BuildContext context) => BiocentralWorkspaceTheme(
    child: Builder(
      builder: (context) => BlocListener<BiocentralCommandBloc, BiocentralCommandState>(
        listenWhen: (previous, current) =>
            current.isErrored() &&
            _engineeringCommandNames.contains(current.currentCommandLog?.commandName) &&
            !identical(previous.currentCommandLog, current.currentCommandLog),
        listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.currentCommandLog?.metaData.error ?? 'Command failed.'),
            action: SnackBarAction(label: 'Activity', onPressed: _activity),
          ),
        ),
        child: BlocBuilder<EngineeringHubBloc, EngineeringHubState>(
          builder: (context, state) {
            final campaign = state.selectedCampaign;
            final busy = context.select<BiocentralCommandBloc, bool>((bloc) => bloc.state.isBusy());
            return BiocentralWorkspace(
              navigation: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const ListTile(leading: Icon(Icons.science_outlined), title: Text('Engineering')),
                        ElevatedButton.icon(
                          onPressed: () => _newCampaign(),
                          icon: const Icon(Icons.add),
                          label: const Text('New campaign'),
                        ),
                        BiocentralNavigationSection(
                          title: 'CAMPAIGNS',
                          children: [
                            for (final value in state.campaigns)
                              BiocentralNavigationItem(
                                label: value.config.name,
                                selected: campaign?.id == value.id,
                                onTap: () =>
                                    context.read<EngineeringHubBloc>().add(EngineeringCampaignSelected(value.id)),
                                trailing: IconButton(
                                  tooltip: 'Delete campaign',
                                  onPressed: busy ? null : () => _perform(() => _delete(context, value)),
                                  icon: const Icon(Icons.delete_outline, size: 16),
                                ),
                              ),
                          ],
                        ),
                        if (campaign != null) ...[
                          BiocentralNavigationSection(
                            title: 'THIS CAMPAIGN',
                            children: [
                              for (final (section, title) in [
                                (EngineeringSection.overview, 'Overview'),
                                (EngineeringSection.rounds, 'Rounds'),
                                (EngineeringSection.history, 'History'),
                                (EngineeringSection.lineage, 'Lineage'),
                                (EngineeringSection.mutations, 'Mutations'),
                              ])
                                BiocentralNavigationItem(
                                  label: title,
                                  selected: state.section == section,
                                  onTap: () => _section(section),
                                ),
                            ],
                          ),
                          BiocentralNavigationSection(
                            title: 'ACTIONS',
                            children: [
                              BiocentralNavigationItem(
                                label: 'Suggest next round',
                                onTap: busy
                                    ? null
                                    : () => _perform(() => showEngineeringRoundDialog(context, campaign)),
                              ),
                              BiocentralNavigationItem(
                                label: 'Import measurements',
                                onTap: busy
                                    ? null
                                    : () {
                                        _section(EngineeringSection.rounds);
                                        _perform(() => importEngineeringMeasurements(context, campaign));
                                      },
                              ),
                              BiocentralNavigationItem(
                                label: 'Export for the bench',
                                onTap: campaign.rounds.isEmpty
                                    ? null
                                    : () => _perform(
                                        () => exportEngineeringRoundForBench(
                                          campaign.rounds[(state.roundIndex ?? campaign.rounds.length - 1).clamp(
                                            0,
                                            campaign.rounds.length - 1,
                                          )],
                                        ),
                                      ),
                              ),
                              BiocentralNavigationItem(
                                label: 'Upload / replace structure',
                                onTap: busy
                                    ? null
                                    : () => _perform(() => uploadEngineeringStructure(context, campaign)),
                              ),
                              BiocentralNavigationItem(
                                label: 'Add position rule',
                                onTap: () {
                                  setState(
                                    () => _positionRuleRequests.update(
                                      campaign.id,
                                      (value) => value + 1,
                                      ifAbsent: () => 1,
                                    ),
                                  );
                                  _section(EngineeringSection.mutations);
                                },
                              ),
                              BiocentralNavigationItem(
                                label: 'New campaign from this',
                                onTap: () => _newCampaign(campaign),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        TextButton(onPressed: _activity, child: const Text('Activity')),
                        IconButton(
                          tooltip: 'Protein engineering settings',
                          onPressed: () => _section(EngineeringSection.settings),
                          icon: const Icon(Icons.settings_outlined),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) =>
                              _perform(value == 'import' ? () => _import(context) : () => _export(context, campaign!)),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'import', child: Text('Import campaign…')),
                            if (campaign != null) const PopupMenuItem(value: 'export', child: Text('Export campaign…')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              child: _content(state),
            );
          },
        ),
      ),
    ),
  );

  Widget _content(EngineeringHubState state) {
    final selectedIndex = state.campaigns.indexWhere((campaign) => campaign.id == state.selectedId);
    final index = state.section == EngineeringSection.newCampaign
        ? state.campaigns.length
        : state.section == EngineeringSection.settings
        ? state.campaigns.length + 1
        : selectedIndex < 0
        ? state.campaigns.length + 2
        : selectedIndex;
    return IndexedStack(
      index: index,
      children: [
        for (final campaign in state.campaigns)
          KeyedSubtree(
            key: ValueKey(campaign.id),
            child: IndexedStack(
              index: state.section.index.clamp(0, 4),
              children: [
                EngineeringOverviewPage(
                  campaign: campaign,
                  onOpenRound: (index) => _section(EngineeringSection.rounds, roundIndex: index),
                  onOpenHistory: () => _section(EngineeringSection.history),
                ),
                EngineeringRoundsPage(
                  campaign: campaign,
                  initialRoundIndex: campaign.id == state.selectedId ? state.roundIndex : null,
                  onRoundSelected: (index) => _section(EngineeringSection.rounds, roundIndex: index),
                ),
                EngineeringRoundsPage(campaign: campaign, history: true),
                EngineeringLineagePage(
                  campaign: campaign,
                  onOpenRound: (index) => _section(EngineeringSection.rounds, roundIndex: index),
                ),
                EngineeringMutationsPage(campaign: campaign, addRuleRequest: _positionRuleRequests[campaign.id] ?? 0),
              ],
            ),
          ),
        NewEngineeringCampaignView(
          key: ValueKey('wizard-$_wizardGeneration'),
          source: _source,
          onSourceSelected: _newCampaign,
          onCreated: (campaign) {
            context.read<EngineeringHubBloc>().add(EngineeringCampaignSelected(campaign.id));
            _section(EngineeringSection.overview);
          },
        ),
        const Padding(
          key: ValueKey('settings'),
          padding: EdgeInsets.fromLTRB(40, 32, 40, 32),
          child: BiocentralPageHeader(
            title: 'Settings',
            description: 'Apply to all protein engineering campaigns. No settings yet.',
          ),
        ),
        BiocentralEmptyState(
          key: const ValueKey('empty'),
          message: 'Start your first campaign',
          action: ElevatedButton(onPressed: () => _newCampaign(), child: const Text('New campaign')),
        ),
      ],
    );
  }
}
