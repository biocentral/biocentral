import 'package:biocentral/plugins/protein_engineering/domain/lineage.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

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
    final width = 48 + (lineage.depthCount - 1).clamp(0, 10000) * 300 + 252.0;
    final height = 48 + lineage.rowCount.clamp(1, 10000) * 84.0;
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
                            left: 24 + node.depth * 300,
                            top: 24 + node.row * 84,
                            width: 252,
                            height: 72,
                            child: Container(
                              decoration: BoxDecoration(
                                color: node.onBestPath ? scheme.primary.withValues(alpha: 0.08) : scheme.surface,
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
        overflow: TextOverflow.ellipsis,
      ),
    ),
    VariantLineageNode() => Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(node.descriptor ?? 'Wildtype', overflow: TextOverflow.ellipsis),
          Text(
            node.measurement == null
                ? 'not measured'
                : node.measurement!.didNotExpress
                ? 'did not express'
                : '${node.measurement!.fitness} ${widget.campaign.measurementUnit}',
          ),
        ],
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
              if (node.best != null) Text('Best: ${node.best!.fitness}', style: const TextStyle(fontSize: 11)),
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
        final start = Offset(24 + node.depth * 300 + 252, 24 + node.row * 84 + 36);
        final end = Offset(24 + child.depth * 300, 24 + child.row * 84 + 36);
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
