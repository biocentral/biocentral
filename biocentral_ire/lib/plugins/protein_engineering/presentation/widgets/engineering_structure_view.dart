import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/protein_engineering/bloc/engineering_hub_bloc.dart';
import 'package:biocentral/plugins/protein_engineering/domain/structure_sequence.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/engineering_actions.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Renders one immutable structure input and optional candidate or residue selection.
class EngineeringStructureView extends StatefulWidget {
  final EngineeringCampaign campaign;
  final String? candidateSequence;
  final VoidCallback? onUpload;
  final Set<int> selectedPositions;
  final ValueChanged<Set<int>>? onPositionsChanged;

  const EngineeringStructureView({
    required this.campaign,
    this.candidateSequence,
    this.onUpload,
    this.selectedPositions = const {},
    this.onPositionsChanged,
    super.key,
  });

  @override
  State<EngineeringStructureView> createState() => _EngineeringStructureViewState();
}

class _EngineeringStructureViewState extends State<EngineeringStructureView> {
  Future<WildtypeStructureMatch?>? _structure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(EngineeringStructureView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campaign.structureInputId != widget.campaign.structureInputId ||
        oldWidget.campaign.wildtypeSequence != widget.campaign.wildtypeSequence) {
      _load();
    }
  }

  void _load() {
    final content = widget.campaign.wildtypeStructureMmcif;
    _structure = content == null
        ? null
        : MmcifParser.parse(content)
              .then((parsed) => matchWildtypeStructure(parsed.structure, widget.campaign.wildtypeSequence));
  }

  @override
  Widget build(BuildContext context) {
    if (_structure == null) {
      return BiocentralEmptyState(
        message: 'Upload a structure of the wildtype to view mutations in 3D.',
        action: widget.onUpload == null
            ? null
            : OutlinedButton(onPressed: widget.onUpload, child: const Text('Upload structure')),
      );
    }
    return FutureBuilder<WildtypeStructureMatch?>(
      future: _structure,
      builder: (context, snapshot) {
        if (snapshot.hasError) return BiocentralEmptyState(message: 'Could not read structure: ${snapshot.error}');
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        final match = snapshot.data;
        if (match == null) return const BiocentralEmptyState(message: 'No structure chain matches the wildtype.');
        final positions = <ResidueKey, int>{};
        for (var position = 1; position <= widget.campaign.wildtypeSequence.length; position++) {
          final key = match.residueKeyForPosition(position);
          if (key != null) positions[key] = position;
        }
        return ProteinViewer(
          structure: match.structure,
          style: const CartoonStyle(
            helixColor: Color(0xFF9E793D),
            sheetColor: Color(0xFF2E7D32),
            outlineColor: Colors.black,
            outlineThickness: 0.12,
            pencilTexture: true,
          ),
          highlights: widget.candidateSequence == null
              ? const {}
              : highlightsForCandidate(
                  match: match,
                  wildtypeSequence: widget.campaign.wildtypeSequence,
                  candidateSequence: widget.candidateSequence!,
                  color: Colors.purple,
                ),
          selectedResidues: positions.keys.where((key) => widget.selectedPositions.contains(positions[key])).toSet(),
          onSelectionChanged: widget.onPositionsChanged == null
              ? null
              : (selection) => widget.onPositionsChanged!(
                  selection.where(positions.containsKey).map((key) => positions[key]!).toSet(),
                ),
        );
      },
    );
  }
}

/// Selects positions as a draft; returning them does not modify the campaign.
Future<Set<int>?> pickEngineeringPositions(BuildContext context, EngineeringCampaign campaign, Set<int> initial) {
  var positions = {...initial};
  final hub = context.read<EngineeringHubBloc>();
  return showDialog<Set<int>>(
    context: context,
    builder: (_) => BlocBuilder<EngineeringHubBloc, EngineeringHubState>(
      bloc: hub,
      builder: (_, state) {
        var current = campaign;
        for (final value in state.campaigns) {
          if (value.id == campaign.id) current = value;
        }
        return StatefulBuilder(
          builder: (dialogContext, setState) => BiocentralWorkspaceDialog(
            title: 'Select positions in the structure',
            maxWidth: 880,
            subtitle: 'Click a residue to select it; shift-click to add or remove residues.',
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: current.structureInputId == null ? null : () => Navigator.of(dialogContext).pop(positions),
                child: const Text('Save positions'),
              ),
            ],
            child: SizedBox(
              height: (MediaQuery.sizeOf(dialogContext).height - 300).clamp(240, 520),
              child: EngineeringStructureView(
                campaign: current,
                selectedPositions: positions,
                onPositionsChanged: (value) => setState(() => positions = value),
                onUpload: () => performEngineeringAction(context, () => uploadEngineeringStructure(context, current)),
              ),
            ),
          ),
        );
      },
    ),
  );
}
