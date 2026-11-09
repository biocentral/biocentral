import 'package:biocentral/plugins/protein_engineering/domain/amino_acid_restrictions.dart';
import 'package:biocentral/plugins/protein_engineering/domain/sequence_validation.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

/// Edits an unapplied restriction draft. Null changes indicate invalid positions.
class EngineeringRestrictionsEditor extends StatefulWidget {
  final AminoAcidRestrictions initialValue;
  final int sequenceLength;
  final int addRuleRequest;
  final ValueChanged<AminoAcidRestrictions?> onChanged;
  final Future<Set<int>?> Function(Set<int>)? onPickPositions;

  const EngineeringRestrictionsEditor({
    required this.initialValue,
    required this.sequenceLength,
    required this.onChanged,
    this.onPickPositions,
    this.addRuleRequest = 0,
    super.key,
  });

  @override
  State<EngineeringRestrictionsEditor> createState() => _EngineeringRestrictionsEditorState();
}

class _PositionDraft {
  final TextEditingController controller;
  final Set<String> excluded;
  String? error;

  _PositionDraft(PositionRestriction value)
    : controller = TextEditingController(text: formatPositions(value.positions)),
      excluded = {...value.excludedAminoAcids};
}

class _EngineeringRestrictionsEditorState extends State<EngineeringRestrictionsEditor> {
  late final Set<String> _excluded = {...widget.initialValue.globallyExcluded};
  late final List<_PositionDraft> _rules = widget.initialValue.positionRestrictions.map(_PositionDraft.new).toList();

  @override
  void didUpdateWidget(EngineeringRestrictionsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.addRuleRequest != widget.addRuleRequest) {
      _rules.add(_PositionDraft(PositionRestriction(positions: {}, excludedAminoAcids: {})));
    }
  }

  @override
  void dispose() {
    for (final rule in _rules) {
      rule.controller.dispose();
    }
    super.dispose();
  }

  void _changed() {
    final rules = <PositionRestriction>[];
    for (final rule in _rules) {
      try {
        rules.add(
          PositionRestriction(
            positions: parsePositions(rule.controller.text, sequenceLength: widget.sequenceLength),
            excludedAminoAcids: rule.excluded,
          ),
        );
        rule.error = null;
      } on PositionParseException catch (error) {
        rule.error = error.message;
      }
    }
    setState(() {});
    widget.onChanged(
      _rules.any((rule) => rule.error != null)
          ? null
          : AminoAcidRestrictions(globallyExcluded: _excluded, positionRestrictions: rules),
    );
  }

  Future<void> _pick(_PositionDraft rule) async {
    final Set<int> current;
    try {
      current = parsePositions(rule.controller.text, sequenceLength: widget.sequenceLength);
    } on PositionParseException {
      return;
    }
    final positions = await widget.onPickPositions?.call(current);
    if (!mounted || positions == null || !_rules.contains(rule)) return;
    rule.controller.text = formatPositions(positions);
    _changed();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      BiocentralFormSection(title: 'Never introduce anywhere', child: _toggles(_excluded)),
      const SizedBox(height: 20),
      const Text('Position rules'),
      const Text('Exclude amino acids only at some positions, e.g. "34, 52, 67, 120-135".'),
      for (final rule in _rules)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: BiocentralSectionCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: rule.controller,
                        decoration: InputDecoration(
                          labelText: 'Positions (1-${widget.sequenceLength})',
                          errorText: rule.error,
                        ),
                        onChanged: (_) => _changed(),
                      ),
                    ),
                    if (widget.onPickPositions != null)
                      IconButton(
                        tooltip: 'Select positions in the structure',
                        onPressed: () => _pick(rule),
                        icon: const Icon(Icons.view_in_ar_outlined),
                      ),
                    IconButton(
                      tooltip: 'Remove rule',
                      onPressed: () {
                        _rules.remove(rule);
                        rule.controller.dispose();
                        _changed();
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _toggles(rule.excluded),
              ],
            ),
          ),
        ),
      TextButton.icon(
        onPressed: () {
          _rules.add(_PositionDraft(PositionRestriction(positions: {}, excludedAminoAcids: {})));
          _changed();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add position rule'),
      ),
    ],
  );

  Widget _toggles(Set<String> excluded) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final aminoAcid in standardAminoAcids)
        FilterChip(
          label: Text(aminoAcid),
          selected: excluded.contains(aminoAcid),
          tooltip: excluded.contains(aminoAcid) ? '$aminoAcid excluded' : '$aminoAcid permitted',
          onSelected: (selected) {
            selected ? excluded.add(aminoAcid) : excluded.remove(aminoAcid);
            _changed();
          },
        ),
    ],
  );
}
