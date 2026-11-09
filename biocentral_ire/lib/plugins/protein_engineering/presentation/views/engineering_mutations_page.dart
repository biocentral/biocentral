import 'package:biocentral/plugins/protein_engineering/bloc/engineering_commands.dart';
import 'package:biocentral/plugins/protein_engineering/domain/amino_acid_restrictions.dart';
import 'package:biocentral/plugins/protein_engineering/domain/engineering_repository.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/engineering_actions.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/widgets/engineering_restrictions_editor.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/widgets/engineering_structure_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Keeps a restriction draft until Apply, including while navigating other sections.
class EngineeringMutationsPage extends StatefulWidget {
  final EngineeringCampaign campaign;
  final int addRuleRequest;

  const EngineeringMutationsPage({required this.campaign, this.addRuleRequest = 0, super.key});

  @override
  State<EngineeringMutationsPage> createState() => _EngineeringMutationsPageState();
}

class _EngineeringMutationsPageState extends State<EngineeringMutationsPage> with AutomaticKeepAliveClientMixin {
  AminoAcidRestrictions? _draft;
  int _generation = 0;
  bool _dirty = false;
  late int _revision = widget.campaign.revision;

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(EngineeringMutationsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campaign.aminoAcidRestrictions != widget.campaign.aminoAcidRestrictions ||
        oldWidget.campaign.wildtypeSequence != widget.campaign.wildtypeSequence) {
      if (!_dirty || _draft == widget.campaign.aminoAcidRestrictions) {
        _draft = null;
        _dirty = false;
        _generation++;
        _revision = widget.campaign.revision;
      }
    } else if (_revision == oldWidget.campaign.revision) {
      // Unrelated measurements or structure updates do not invalidate this draft.
      _revision = widget.campaign.revision;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final busy = context.select<BiocentralCommandBloc, bool>((bloc) => bloc.state.isBusy());
    final changed = _draft != null && _draft != widget.campaign.aminoAcidRestrictions;
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 32),
      children: [
        BiocentralPageHeader(
          title: 'Mutation settings',
          description: 'Choose which amino acids may be introduced.',
          actions: [
            TextButton(
              onPressed: () => setState(() {
                _draft = null;
                _dirty = false;
                _generation++;
                _revision = widget.campaign.revision;
              }),
              child: const Text('Discard changes'),
            ),
            ElevatedButton(
              onPressed: !changed || busy || _revision != widget.campaign.revision
                  ? null
                  : () => submitEngineeringCommand(
                      context,
                      UpdateEngineeringRestrictionsCommand(
                        repository: context.read<EngineeringRepository>(),
                        campaign: widget.campaign,
                        restrictions: _draft!,
                      ),
                    ),
              child: const Text('Apply changes'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_revision != widget.campaign.revision)
          const BiocentralNotice(message: 'Campaign changed. Discard this draft and edit the current revision.'),
        BiocentralSectionCard(
          child: EngineeringRestrictionsEditor(
            key: ValueKey(_generation),
            initialValue: widget.campaign.aminoAcidRestrictions,
            addRuleRequest: widget.addRuleRequest,
            sequenceLength: widget.campaign.wildtypeSequence.length,
            onChanged: (value) => setState(() {
              _draft = value;
              _dirty = true;
            }),
            onPickPositions: (positions) => pickEngineeringPositions(context, widget.campaign, positions),
          ),
        ),
      ],
    );
  }
}
