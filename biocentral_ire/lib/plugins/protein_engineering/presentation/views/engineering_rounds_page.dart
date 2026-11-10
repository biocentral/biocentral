import 'package:biocentral/plugins/protein_engineering/bloc/engineering_commands.dart';
import 'package:biocentral/plugins/protein_engineering/domain/campaign_candidates.dart';
import 'package:biocentral/plugins/protein_engineering/domain/engineering_repository.dart';
import 'package:biocentral/plugins/protein_engineering/domain/round_response.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/engineering_actions.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/widgets/engineering_candidates_grid.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/widgets/engineering_round_tabs.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/widgets/engineering_structure_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// One round's candidates, structure inspection and batch measurement draft.
class EngineeringRoundsPage extends StatefulWidget {
  final EngineeringCampaign campaign;
  final int? initialRoundIndex;
  final bool history;
  final ValueChanged<int>? onRoundSelected;

  const EngineeringRoundsPage({
    required this.campaign,
    this.initialRoundIndex,
    this.history = false,
    this.onRoundSelected,
    super.key,
  });

  @override
  State<EngineeringRoundsPage> createState() => _EngineeringRoundsPageState();
}

class _EngineeringRoundsPageState extends State<EngineeringRoundsPage> with AutomaticKeepAliveClientMixin {
  String? _selected;
  String _filter = 'All';
  final Map<String, MeasuredVariant> _pending = {};
  final Map<String, MeasuredVariant?> _baselines = {};
  String? _draftWildtype;

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(EngineeringRoundsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pending.removeWhere((sequence, value) => widget.campaign.measurements[sequence] == value);
    _baselines.removeWhere((sequence, _) => !_pending.containsKey(sequence));
    if (oldWidget.campaign.wildtypeSequence != widget.campaign.wildtypeSequence) _selected = null;
  }

  Future<void> _edit(MeasuredVariant base) async {
    final value = _pending[base.sequence] ?? widget.campaign.measurements[base.sequence];
    final original = value ?? base;
    final controller = TextEditingController(text: value?.fitness?.toString() ?? '');
    var dne = value?.didNotExpress ?? false;
    final measurement = await showDialog<MeasuredVariant>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => BiocentralWorkspaceDialog(
          title: 'Enter measurement',
          subtitle: base.seqId,
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: !dne && double.tryParse(controller.text)?.isFinite != true
                  ? null
                  : () => Navigator.of(context).pop(
                      MeasuredVariant(
                        seqId: original.seqId,
                        sequence: original.sequence,
                        parentSequence: original.parentSequence,
                        substitutions: original.substitutions,
                        roundFound: original.roundFound,
                        fitness: dne ? null : double.parse(controller.text),
                      ),
                    ),
              child: const Text('Save draft'),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                enabled: !dne,
                decoration: InputDecoration(labelText: widget.campaign.measurementName),
                onChanged: (_) => setState(() {}),
              ),
              CheckboxListTile(
                value: dne,
                title: const Text('Did not express'),
                onChanged: (value) => setState(() => dne = value!),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (!mounted || measurement == null) return;
    setState(() {
      if (_pending.isEmpty) _draftWildtype = widget.campaign.wildtypeSequence;
      if (!_pending.containsKey(measurement.sequence)) {
        _baselines[measurement.sequence] = widget.campaign.measurements[measurement.sequence];
      }
      _pending[measurement.sequence] = measurement;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final campaign = widget.campaign;
    final conflictingDraft =
        _pending.isNotEmpty &&
        (_draftWildtype != campaign.wildtypeSequence ||
            _baselines.entries.any((entry) => campaign.measurements[entry.key] != entry.value));
    final busy = context.select<BiocentralCommandBloc, bool>((bloc) => bloc.state.isBusy());
    final round = campaign.rounds.isEmpty
        ? null
        : campaign.rounds[(widget.initialRoundIndex ?? campaign.rounds.length - 1).clamp(
            0,
            campaign.rounds.length - 1,
          )];
    final responseIssues = <String>[
      for (final current in widget.history ? campaign.rounds : [if (round != null) round])
        if (engineeringResponseIssue(
              current.result,
              parentSequence: current.parentSequence,
              iteration: current.sentConfig.iteration,
            )
            case final String issue)
          'Round ${current.sentConfig.iteration}: $issue '
              'Run a new round against the matching backend to obtain usable variants.',
    ];
    final candidates = engineeringCandidates(campaign, round: widget.history ? null : round);
    final rows = candidates.where((candidate) {
      final measurement = campaign.measurements[candidate.variant.sequence];
      return _filter == 'All' ||
          (_filter == 'Measured' && measurement?.fitness != null) ||
          (_filter == 'Did not express' && measurement?.didNotExpress == true);
    }).toList();
    final grid = BiocentralSectionCard(
      child: SizedBox(
        height: 460,
        child: rows.isEmpty
            ? const BiocentralEmptyState(message: 'No variants to display.')
            : EngineeringCandidatesGrid(
                candidates: rows,
                measurements: campaign.measurements,
                drafts: Map.unmodifiable(_pending),
                enabled: !busy,
                onSelected: (sequence) => setState(() => _selected = sequence),
                onEdit: _edit,
                onDiscardDraft: (sequence) => setState(() {
                  _pending.remove(sequence);
                  _baselines.remove(sequence);
                }),
              ),
      ),
    );
    final structure = BiocentralSectionCard(
      title: 'Structure',
      child: SizedBox(
        height: 420,
        child: EngineeringStructureView(campaign: campaign, candidateSequence: _selected),
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 32),
      children: [
        BiocentralPageHeader(
          title: widget.history ? 'History' : 'Rounds',
          actions: [
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () => performEngineeringAction(context, () => importEngineeringMeasurements(context, campaign)),
              child: const Text('Import measurements'),
            ),
            if (round != null)
              OutlinedButton(
                onPressed: () => performEngineeringAction(context, () => exportEngineeringRoundForBench(round)),
                child: const Text('Export for the bench'),
              ),
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () => performEngineeringAction(context, () => uploadEngineeringStructure(context, campaign)),
              child: const Text('Upload / replace structure'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final issue in responseIssues)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BiocentralNotice(message: issue, icon: Icons.error_outline),
          ),
        if (!widget.history && campaign.rounds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EngineeringRoundTabs(
              iterations: [for (final current in campaign.rounds) current.sentConfig.iteration],
              selectedIndex: campaign.rounds.indexOf(round!),
              onSelected: widget.onRoundSelected,
            ),
          ),
        Wrap(
          spacing: 8,
          children: [
            for (final filter in ['All', 'Measured', 'Did not express'])
              ChoiceChip(
                label: Text(filter),
                selected: _filter == filter,
                onSelected: (_) => setState(() => _filter = filter),
              ),
          ],
        ),
        if (conflictingDraft)
          const BiocentralNotice(
            message: 'Applied data changed for these drafts. Discard them and enter measurements against the current campaign.',
          ),
        if (_pending.isNotEmpty)
          Row(
            children: [
              Text('${_pending.length} measurement drafts'),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _pending.clear();
                  _baselines.clear();
                }),
                child: const Text('Discard drafts'),
              ),
              ElevatedButton(
                onPressed: busy || conflictingDraft
                    ? null
                    : () => performEngineeringAction(
                        context,
                        () => submitEngineeringCommand(
                          context,
                          AddEngineeringMeasurementsCommand(
                            repository: context.read<EngineeringRepository>(),
                            campaign: campaign,
                            measurements: _pending.values.toList(),
                          ),
                        ),
                      ),
                child: const Text('Submit measurements'),
              ),
            ],
          ),
        const SizedBox(height: 16),
        if (widget.history)
          grid
        else
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 900
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: grid),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: structure),
                    ],
                  )
                : Column(children: [grid, const SizedBox(height: 16), structure]),
          ),
      ],
    );
  }
}
