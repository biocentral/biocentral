import 'dart:async';
import 'dart:convert';

import 'package:biocentral/plugins/protein_engineering/bloc/engineering_commands.dart';
import 'package:biocentral/plugins/protein_engineering/domain/campaign_insights.dart';
import 'package:biocentral/plugins/protein_engineering/domain/engineering_repository.dart';
import 'package:biocentral/plugins/protein_engineering/domain/round_export.dart';
import 'package:biocentral/plugins/protein_engineering/domain/round_import.dart';
import 'package:biocentral/plugins/protein_engineering/domain/round_preparation.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';

/// Presents input and file errors without changing command or repository state.
Future<void> performEngineeringAction(BuildContext context, FutureOr<void> Function() action) async {
  try {
    await action();
  } catch (error) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

/// Dispatches through the shared runner; sidebar and page controls share this path.
void submitEngineeringCommand(BuildContext context, BiocentralCommand command) {
  context.read<BiocentralCommandBloc>().add(
    BiocentralCommandExecuteEvent(
      command: command,
      visualizeResult: (log) => BiocentralStatusIndicator(metaData: log.metaData),
      autoAccept: true,
    ),
  );
}

/// Reads exact input bytes without changing campaign state.
Future<EngineeringInput?> pickEngineeringInput(String format) async {
  final result = await FilePicker.platform.pickFiles(withData: true);
  if (result == null) return null;
  final file = result.files.single;
  if (file.bytes == null) throw const FormatException('Could not read selected file.');
  return EngineeringInput(name: file.name, format: format, bytes: file.bytes!);
}

typedef _RoundSubmission = ({String parent, ActiveLearningEngineeringIterationConfig iteration});

enum _StartingPoint { wildtype, bestSoFar, measuredVariant, custom }

/// Collects round parameters and dispatches exactly the validated request.
Future<void> showEngineeringRoundDialog(BuildContext context, EngineeringCampaign campaign) async {
  final submission = await showDialog<_RoundSubmission>(
    context: context,
    builder: (_) => _EngineeringRoundDialog(campaign: campaign),
  );
  if (!context.mounted || submission == null) return;
  submitEngineeringCommand(
    context,
    RunEngineeringRoundCommand(
      apiRepository: context.read<BiocentralAPIRepository>(),
      repository: context.read<EngineeringRepository>(),
      campaign: campaign,
      iteration: submission.iteration,
      parentSequence: submission.parent,
    ),
  );
}

class _EngineeringRoundDialog extends StatefulWidget {
  final EngineeringCampaign campaign;

  const _EngineeringRoundDialog({required this.campaign});

  @override
  State<_EngineeringRoundDialog> createState() => _EngineeringRoundDialogState();
}

class _EngineeringRoundDialogState extends State<_EngineeringRoundDialog> {
  final _custom = TextEditingController();
  int _suggestions = 8;
  double _coefficient = 0.5;
  _StartingPoint _startingPoint = _StartingPoint.wildtype;
  MeasuredVariant? _chosenVariant;
  String? _error;

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  String? get _parentSequence => switch (_startingPoint) {
    _StartingPoint.wildtype => widget.campaign.wildtypeSequence,
    _StartingPoint.bestSoFar => bestMeasuredVariant(widget.campaign)?.sequence,
    _StartingPoint.measuredVariant => _chosenVariant?.sequence,
    _StartingPoint.custom =>
      _custom.text.trim().isEmpty ? null : _custom.text.replaceAll(RegExp(r'\s'), '').toUpperCase(),
  };

  void _submit() {
    final parent = _parentSequence;
    if (parent == null) return;
    try {
      final iteration = prepareEngineeringRound(
        campaign: widget.campaign,
        parentSequence: parent,
        nSuggestions: _suggestions,
        coefficient: _coefficient,
      );
      Navigator.of(context).pop((parent: parent, iteration: iteration));
    } on FormatException catch (error) {
      setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final measured = widget.campaign.measurements.values.where((variant) => variant.fitness != null).toList();
    return BiocentralWorkspaceDialog(
      title: 'Suggest next round',
      subtitle: 'Using ${measured.length} measurements.',
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: measured.isEmpty || _parentSequence == null ? null : _submit,
          child: const Text('Suggest variants'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('How many variants can you test this round?'),
          Row(
            children: [
              IconButton(
                onPressed: _suggestions > 1 ? () => setState(() => _suggestions--) : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$_suggestions'),
              IconButton(onPressed: () => setState(() => _suggestions++), icon: const Icon(Icons.add)),
            ],
          ),
          const Text('Exploration–exploitation balance'),
          Slider(
            value: _coefficient,
            divisions: 10,
            label: _coefficient.toStringAsFixed(1),
            onChanged: (value) => setState(() => _coefficient = value),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Prioritize predicted performance'), Text('Explore uncertain variants')],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<_StartingPoint>(
            initialValue: _startingPoint,
            decoration: const InputDecoration(labelText: 'Build variants from'),
            items: [
              for (final source in _StartingPoint.values)
                if (measured.isNotEmpty || source == _StartingPoint.wildtype || source == _StartingPoint.custom)
                  DropdownMenuItem(
                    value: source,
                    child: Text(switch (source) {
                      _StartingPoint.wildtype => 'Wildtype',
                      _StartingPoint.bestSoFar => 'Best so far',
                      _StartingPoint.measuredVariant => 'A measured variant…',
                      _StartingPoint.custom => 'A pasted sequence…',
                    }),
                  ),
            ],
            onChanged: (value) => setState(() {
              _startingPoint = value!;
              _error = null;
            }),
          ),
          if (_startingPoint == _StartingPoint.measuredVariant) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<MeasuredVariant>(
              initialValue: _chosenVariant,
              decoration: const InputDecoration(labelText: 'Measured variant'),
              items: [
                for (final value in measured)
                  DropdownMenuItem(value: value, child: Text('${value.seqId} (${value.fitness!.toStringAsFixed(2)})')),
              ],
              onChanged: (value) => setState(() => _chosenVariant = value),
            ),
          ],
          if (_startingPoint == _StartingPoint.custom) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _custom,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Sequence (${widget.campaign.wildtypeSequence.length} residues)'),
              onChanged: (_) => setState(() => _error = null),
            ),
          ],
          if (!widget.campaign.aminoAcidRestrictions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Applied amino acid restrictions will be enforced for this round.'),
            ),
          if (measured.isEmpty) const Text('Enter at least one measured fitness before running a round.'),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
        ],
      ),
    );
  }
}

/// Previews a CSV import, then records its original bytes with accepted measurements.
Future<void> importEngineeringMeasurements(BuildContext context, EngineeringCampaign campaign) async {
  final input = await pickEngineeringInput('csv');
  if (!context.mounted || input == null) return;
  final parsed = parseMeasurementsCsv(utf8.decode(input.bytes), campaign);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => BiocentralWorkspaceDialog(
      title: 'Import measurements',
      subtitle: input.name,
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: parsed.canImport ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Import'),
        ),
      ],
      child: Text(
        parsed.errors.isEmpty
            ? '${parsed.newMeasurements.length} measurements ready.\n'
                  '${parsed.alreadyMeasured} already measured; ${parsed.blank} blank rows.'
            : parsed.errors.join('\n'),
      ),
    ),
  );
  if (!context.mounted || confirmed != true) return;
  submitEngineeringCommand(
    context,
    AddEngineeringMeasurementsCommand(
      repository: context.read<EngineeringRepository>(),
      campaign: campaign,
      measurements: parsed.newMeasurements,
      input: input,
    ),
  );
}

/// Uploads a matching structure as a logged change, retaining the exact source bytes.
Future<void> uploadEngineeringStructure(BuildContext context, EngineeringCampaign campaign) async {
  final input = await pickEngineeringInput('mmcif');
  if (!context.mounted || input == null) return;
  submitEngineeringCommand(
    context,
    UploadWildtypeStructureCommand(repository: context.read<EngineeringRepository>(), campaign: campaign, input: input),
  );
}

/// Saves a bench worksheet without changing scientific campaign state.
Future<void> exportEngineeringRoundForBench(EngineeringRound round) async {
  final path = await FilePicker.platform.saveFile(fileName: 'round_${round.sentConfig.iteration}.csv');
  if (path != null) await File(path).writeAsString(roundCandidatesToCsv(round));
}
