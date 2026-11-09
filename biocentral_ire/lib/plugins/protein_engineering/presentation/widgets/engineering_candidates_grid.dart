import 'package:biocentral/plugins/protein_engineering/domain/campaign_candidates.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// A sortable, virtualized table with immutable measurements and separate drafts.
///
/// Selection changes only the inspected variant. [onEdit] opens the feature's draft
/// editor; neither the table nor its cell renderers dispatch scientific commands.
class EngineeringCandidatesGrid extends StatelessWidget {
  final List<EngineeringCandidate> candidates;
  final Map<String, MeasuredVariant> measurements;
  final Map<String, MeasuredVariant> drafts;
  final bool enabled;
  final ValueChanged<String> onSelected;
  final ValueChanged<MeasuredVariant> onEdit;
  final ValueChanged<String> onDiscardDraft;

  const EngineeringCandidatesGrid({
    required this.candidates,
    required this.measurements,
    required this.drafts,
    required this.enabled,
    required this.onSelected,
    required this.onEdit,
    required this.onDiscardDraft,
    super.key,
  });

  String _measurementLabel(MeasuredVariant? measurement) => measurement == null
      ? 'Untested'
      : measurement.didNotExpress
      ? 'Did not express'
      : measurement.fitness.toString();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final data = [
      for (final candidate in candidates)
        [
          candidate.variant.sequence,
          candidate.variant.seqId,
          candidate.variant.roundFound,
          candidate.prediction,
          candidate.uncertainty,
          candidate.score,
          candidate.suggested,
          _measurementLabel(measurements[candidate.variant.sequence]),
          drafts.containsKey(candidate.variant.sequence) ? _measurementLabel(drafts[candidate.variant.sequence]) : null,
        ],
    ];
    final bySequence = {for (final candidate in candidates) candidate.variant.sequence: candidate.variant};
    return PlutoGrid(
      key: ValueKey(_GridContents(data, enabled)),
      mode: PlutoGridMode.selectWithOneTap,
      columns: [
        PlutoColumn(title: 'Round', field: 'round', type: PlutoColumnType.number(), readOnly: true, width: 76),
        PlutoColumn(title: 'Variant', field: 'variant', type: PlutoColumnType.text(), readOnly: true, width: 150),
        PlutoColumn(
          title: 'Predicted',
          field: 'prediction',
          type: PlutoColumnType.number(format: '0.############', applyFormatOnInit: false),
          renderer: (cell) => Text(cell.cell.value?.toString() ?? '—'),
          readOnly: true,
          width: 100,
        ),
        PlutoColumn(
          title: 'Uncertainty',
          field: 'uncertainty',
          type: PlutoColumnType.number(format: '0.############', applyFormatOnInit: false),
          renderer: (cell) => Text(cell.cell.value?.toString() ?? '—'),
          readOnly: true,
          width: 110,
        ),
        PlutoColumn(
          title: 'Score',
          field: 'score',
          type: PlutoColumnType.number(format: '0.############', applyFormatOnInit: false),
          renderer: (cell) => Text(cell.cell.value?.toString() ?? '—'),
          readOnly: true,
          width: 90,
        ),
        PlutoColumn(
          title: 'Measured',
          field: 'measured',
          type: PlutoColumnType.text(),
          readOnly: true,
          width: 210,
          renderer: (cell) {
            final sequence = cell.row.cells['sequence']!.value as String;
            final draft = drafts[sequence];
            final measurement = measurements[sequence];
            return Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: enabled ? () => onEdit(bySequence[sequence]!) : null,
                    child: draft == null && measurement != null
                        ? BiocentralStatusBadge(
                            label: _measurementLabel(measurement),
                            color: measurement.didNotExpress
                                ? scheme.error
                                : Theme.of(context).extension<BiocentralWorkspaceColors>()!.success,
                          )
                        : Text(
                            draft == null ? 'Enter measurement' : '${_measurementLabel(draft)} (draft)',
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
                if (draft != null)
                  IconButton(
                    tooltip: 'Discard this draft',
                    onPressed: enabled ? () => onDiscardDraft(sequence) : null,
                    icon: const Icon(Icons.close, size: 14),
                  ),
              ],
            );
          },
        ),
        PlutoColumn(title: 'Sequence', field: 'sequence', type: PlutoColumnType.text(), readOnly: true, hide: true),
      ],
      rows: [
        for (final candidate in candidates)
          PlutoRow(
            cells: {
              'round': PlutoCell(value: candidate.variant.roundFound),
              'variant': PlutoCell(value: '${candidate.suggested ? '★ ' : ''}${candidate.variant.seqId}'),
              'prediction': PlutoCell(value: double.tryParse(candidate.prediction ?? '')),
              'uncertainty': PlutoCell(value: candidate.uncertainty),
              'score': PlutoCell(value: candidate.score),
              'measured': PlutoCell(
                value: _measurementLabel(
                  drafts[candidate.variant.sequence] ?? measurements[candidate.variant.sequence],
                ),
              ),
              'sequence': PlutoCell(value: candidate.variant.sequence),
            },
          ),
      ],
      onSelected: (event) {
        final sequence = event.row?.cells['sequence']?.value as String?;
        if (sequence != null) onSelected(sequence);
      },
      configuration: PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          gridBackgroundColor: scheme.surface,
          borderColor: scheme.outlineVariant,
          gridBorderColor: scheme.outlineVariant,
          activatedColor: scheme.primary.withValues(alpha: 0.08),
          cellTextStyle: Theme.of(context).textTheme.bodySmall!,
          columnTextStyle: Theme.of(context).textTheme.labelMedium!,
          rowHeight: 42,
          columnHeight: 40,
        ),
      ),
    );
  }
}

// PlutoGrid owns its row state. Replace it only when displayed data changes, so
// inspecting another variant preserves sorting and scrolling.
class _GridContents extends Equatable {
  final List<List<Object?>> values;
  final bool enabled;

  const _GridContents(this.values, this.enabled);

  @override
  List<Object?> get props => [values, enabled];
}
