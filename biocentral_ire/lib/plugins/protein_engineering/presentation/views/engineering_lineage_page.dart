import 'package:biocentral/plugins/protein_engineering/domain/lineage.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

const _columnWidth = 300.0;
const _rowHeight = 84.0;
const _roundSize = Size(252, 72);
const _sequenceSize = Size(156, 42);
const _canvasPadding = 24.0;

Size _nodeSize(LineageNode node) => node is RoundLineageNode ? _roundSize : _sequenceSize;

Offset _nodeCenter(LineageNode node) => Offset(
  _canvasPadding + node.depth * _columnWidth + _roundSize.width / 2,
  _canvasPadding + node.row * _rowHeight + _rowHeight / 2,
);

/// Expandable scientific parent/round lineage with navigation to the selected round.
class EngineeringLineagePage extends StatefulWidget {
  final EngineeringCampaign campaign;
  final ValueChanged<int> onOpenRound;

  const EngineeringLineagePage({required this.campaign, required this.onOpenRound, super.key});

  @override
  State<EngineeringLineagePage> createState() => _EngineeringLineagePageState();
}

class _EngineeringLineagePageState extends State<EngineeringLineagePage> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final lineage = buildLineage(widget.campaign, expandedRounds: _expanded);
    final nodes = lineage.nodes.toList();
    final width = _canvasPadding * 2 + (lineage.depthCount - 1).clamp(0, 10000) * _columnWidth + _roundSize.width;
    final height = _canvasPadding * 2 + lineage.rowCount.clamp(1, 10000) * _rowHeight;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BiocentralPageHeader(
            title: 'Lineage',
            description:
                'Which sequence each round started from. Click a round to show or hide its suggested variants.',
          ),
          const SizedBox(height: 12),
          const Text('Highlighted edges trace the path to the best measured variant. Drag to pan; scroll to zoom.'),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ColoredBox(
                color: scheme.surface,
                child: InteractiveViewer(
                  constrained: false,
                  minScale: 0.3,
                  maxScale: 2,
                  boundaryMargin: const EdgeInsets.all(200),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _LineageEdges(nodes, scheme.outlineVariant, scheme.primary)),
                        ),
                        for (final node in nodes)
                          Positioned(
                            left: _nodeCenter(node).dx - _nodeSize(node).width / 2,
                            top: _nodeCenter(node).dy - _nodeSize(node).height / 2,
                            width: _nodeSize(node).width,
                            height: _nodeSize(node).height,
                            child: Container(
                              decoration: BoxDecoration(
                                color: node.onBestPath
                                    ? scheme.primary.withValues(alpha: 0.08)
                                    : node is VariantLineageNode && node.measurement == null
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : scheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: node.onBestPath ? scheme.primary : scheme.outlineVariant),
                              ),
                              child: _node(node),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _node(LineageNode node) => switch (node) {
    StartLineageNode() => Center(
      child: Text(
        node.isWildtype ? 'Wildtype' : node.descriptor ?? 'Starting sequence',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    VariantLineageNode() => InkWell(
      onTap: () => widget.onOpenRound(node.roundIndex),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              node.descriptor?.replaceAll(':', ' + ') ?? 'Wildtype',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              node.measurement == null
                  ? 'not measured'
                  : node.measurement!.didNotExpress
                  ? 'did not express'
                  : '${node.measurement!.fitness!.toStringAsFixed(2)} ${widget.campaign.measurementUnit}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    ),
    RoundLineageNode() => Row(
      children: [
        IconButton(
          tooltip: 'Show / hide suggested variants',
          onPressed: () => setState(() {
            _expanded.contains(node.roundIndex) ? _expanded.remove(node.roundIndex) : _expanded.add(node.roundIndex);
          }),
          icon: Icon(node.expanded ? Icons.expand_less : Icons.expand_more),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Round ${node.round.sentConfig.iteration}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${node.suggestedCount} suggested · ${node.measuredCount} measured',
                style: const TextStyle(fontSize: 11),
              ),
              if (node.best != null)
                Text('Best: ${node.best!.fitness!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Open round',
          icon: const Icon(Icons.open_in_new, size: 16),
          onPressed: () => widget.onOpenRound(node.roundIndex),
        ),
      ],
    ),
  };
}

class _LineageEdges extends CustomPainter {
  final List<LineageNode> nodes;
  final Color border;
  final Color accent;

  _LineageEdges(this.nodes, this.border, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    for (final node in nodes) {
      for (final child in node.children) {
        final start = _nodeCenter(node) + Offset(_nodeSize(node).width / 2, 0);
        final end = _nodeCenter(child) - Offset(_nodeSize(child).width / 2, 0);
        final middle = (start.dx + end.dx) / 2;
        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(middle, start.dy, middle, end.dy, end.dx, end.dy);
        canvas.drawPath(
          path,
          Paint()
            ..color = (child.onBestPath ? accent : border)
            ..style = PaintingStyle.stroke
            ..strokeWidth = child.onBestPath ? 2 : 1,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_LineageEdges oldDelegate) =>
      nodes != oldDelegate.nodes || border != oldDelegate.border || accent != oldDelegate.accent;
}
