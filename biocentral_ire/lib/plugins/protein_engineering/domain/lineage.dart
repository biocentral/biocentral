import 'package:biocentral/plugins/protein_engineering/domain/campaign_insights.dart';
import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral_api/biocentral_api.dart';

/// A node of the lineage tree.
sealed class LineageNode {
  final List<LineageNode> children = [];

  /// Position in the tidy layout, in grid units: [depth] columns, [row] rows (may be fractional).
  int depth = 0;
  double row = 0;

  /// On the path from a root to the best measured variant.
  bool onBestPath = false;

  LineageNode();
}

/// A sequence rounds started from without coming out of a round: the wildtype, a pasted
/// sequence, or a variant entered at setup.
final class StartLineageNode extends LineageNode {
  final String sequence;

  /// Mutations relative to the wildtype, e.g. "A12V:D88N"; null for the wildtype itself.
  final String? descriptor;
  final MeasuredVariant? measurement;

  StartLineageNode({required this.sequence, required this.descriptor, required this.measurement});

  bool get isWildtype => descriptor == null;
}

/// One round, shown as a panel. Expanded, its suggested variants hang below it.
final class RoundLineageNode extends LineageNode {
  final EngineeringRound round;

  /// Index into the campaign's rounds.
  final int roundIndex;

  /// The starting sequence relative to the wildtype; null if the round started from the wildtype.
  final String? startDescriptor;
  final int suggestedCount;
  final int measuredCount;

  /// The best expressed variant this round produced, if any were measured.
  final MeasuredVariant? best;
  final bool expanded;

  RoundLineageNode({
    required this.round,
    required this.roundIndex,
    required this.startDescriptor,
    required this.suggestedCount,
    required this.measuredCount,
    required this.best,
    required this.expanded,
  });
}

/// A variant suggested by an expanded round. Exists only while that round is expanded.
final class VariantLineageNode extends LineageNode {
  final String sequence;
  final String? descriptor;

  /// Null while the variant hasn't been measured.
  final MeasuredVariant? measurement;

  /// Index into the campaign's rounds of the round that suggested it.
  final int roundIndex;

  VariantLineageNode({
    required this.sequence,
    required this.descriptor,
    required this.measurement,
    required this.roundIndex,
  });
}

class Lineage {
  final List<StartLineageNode> roots;

  /// Rows used by the layout, i.e. the number of leaves.
  final int rowCount;
  final int depthCount;

  const Lineage({required this.roots, required this.rowCount, required this.depthCount});

  Iterable<LineageNode> get nodes sync* {
    final stack = <LineageNode>[...roots.reversed];
    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      yield node;
      stack.addAll(node.children.reversed);
    }
  }
}

/// Builds the tree of rounds: each round hangs below the round whose variant it started from,
/// or below its starting sequence (usually the wildtype). Rounds in [expandedRounds] (indices into
/// the campaign's rounds) show all their suggested variants, and later rounds then hang below the
/// exact variant they started from.
Lineage buildLineage(EngineeringCampaign campaign, {Set<int> expandedRounds = const {}}) {
  final wildtype = campaign.wildtypeSequence;
  final rounds = campaign.rounds;
  final order = [for (var i = 0; i < rounds.length; i++) i]
    ..sort((a, b) => rounds[a].sentConfig.iteration.compareTo(rounds[b].sentConfig.iteration));

  // Each round's suggestions as sequences, in suggestion order.
  final suggestedSequences = <int, List<String>>{for (final i in order) i: _resolveSuggestions(rounds[i])};

  // The first round that produced each measured sequence: later rounds started from it hang there.
  final producedBy = <String, int>{};
  for (final i in order) {
    for (final sequence in suggestedSequences[i]!) {
      if (campaign.measurements.containsKey(sequence)) {
        producedBy.putIfAbsent(sequence, () => i);
      }
    }
  }

  // The round each round hangs below: the one that produced its starting sequence. Only earlier
  // rounds count, so a pasted start that a later round happens to suggest can't form a cycle.
  final anchor = <int, int?>{
    for (final i in order)
      i: switch (producedBy[rounds[i].parentSequence]) {
        final producer? when rounds[producer].sentConfig.iteration < rounds[i].sentConfig.iteration => producer,
        _ => null,
      },
  };

  /// Rounds started from [sequence] that hang below [producer] (null: below a start node).
  List<int> roundsStartedFrom(String sequence, int? producer) => [
    for (final i in order)
      if (rounds[i].parentSequence == sequence && anchor[i] == producer) i,
  ];

  RoundLineageNode buildRound(int i) {
    final round = rounds[i];
    final suggested = suggestedSequences[i]!;
    final measured = [
      for (final sequence in suggested)
        if (campaign.measurements[sequence] case final measurement?) measurement,
    ];
    final node = RoundLineageNode(
      round: round,
      roundIndex: i,
      startDescriptor: wildtypeRelativeDescriptor(wildtype, round.parentSequence),
      suggestedCount: suggested.length,
      measuredCount: measured.length,
      best: _best(campaign, measured),
      expanded: expandedRounds.contains(i),
    );

    if (node.expanded) {
      for (final sequence in suggested) {
        // Fresh nodes per round: a sequence suggested in two rounds appears under both.
        final variant = VariantLineageNode(
          sequence: sequence,
          descriptor: wildtypeRelativeDescriptor(wildtype, sequence),
          measurement: campaign.measurements[sequence],
          roundIndex: i,
        );
        variant.children.addAll(roundsStartedFrom(sequence, i).map(buildRound));
        node.children.add(variant);
      }
    } else {
      node.children.addAll(
        [
          for (final j in order)
            if (anchor[j] == i) j,
        ].map(buildRound),
      );
    }
    return node;
  }

  StartLineageNode buildStart(String sequence) {
    return StartLineageNode(
      sequence: sequence,
      descriptor: wildtypeRelativeDescriptor(wildtype, sequence),
      measurement: campaign.measurements[sequence],
    )..children.addAll(roundsStartedFrom(sequence, null).map(buildRound));
  }

  final roots = [buildStart(wildtype)];
  final otherStarts = <String>{};
  for (final i in order) {
    final parent = rounds[i].parentSequence;
    if (parent != wildtype && anchor[i] == null && otherStarts.add(parent)) {
      roots.add(buildStart(parent));
    }
  }

  final best = bestMeasuredVariant(campaign);
  if (best != null) {
    final bestRound = producedBy[best.sequence];
    bool isTarget(LineageNode node) => switch (node) {
      StartLineageNode(:final sequence) => bestRound == null && sequence == best.sequence,
      RoundLineageNode(:final roundIndex, :final expanded) => !expanded && roundIndex == bestRound,
      VariantLineageNode(:final sequence, :final roundIndex) => roundIndex == bestRound && sequence == best.sequence,
    };
    for (final root in roots) {
      if (_markPath(root, isTarget)) {
        break;
      }
    }
  }

  return _layout(roots);
}

/// Suggestions of [round] resolved to full sequences, without duplicates or unresolvable ones.
List<String> _resolveSuggestions(EngineeringRound round) {
  final sequences = <String>[];
  for (final entityId in round.result.suggestions) {
    try {
      final sequence = applySubstitutions(round.parentSequence, parseMutationDescriptor(entityId));
      if (sequence != null && !sequences.contains(sequence)) {
        sequences.add(sequence);
      }
    } on UnresolvableVariantException {
      // Can't be shown without a sequence.
    }
  }
  return sequences;
}

MeasuredVariant? _best(EngineeringCampaign campaign, List<MeasuredVariant> measured) {
  final expressed = measured.where((variant) => variant.fitness != null).toList();
  if (expressed.isEmpty) {
    return null;
  }
  final maximize = campaign.config.optimizationMode == ActiveLearningOptimizationMode.MAXIMIZE;
  return expressed.reduce((a, b) => (maximize ? a.fitness! >= b.fitness! : a.fitness! <= b.fitness!) ? a : b);
}

bool _markPath(LineageNode node, bool Function(LineageNode) isTarget) {
  // Visit every child (no short-circuit) so stale marks can't survive; only one path matches.
  var found = isTarget(node);
  for (final child in node.children) {
    found = _markPath(child, isTarget) || found;
  }
  node.onBestPath = found;
  return found;
}

/// Tidy left-to-right layout: leaves take consecutive rows, parents sit centered on their children.
Lineage _layout(List<StartLineageNode> roots) {
  var nextRow = 0.0;
  var maxDepth = 0;

  void place(LineageNode node, int depth) {
    node.depth = depth;
    if (depth > maxDepth) {
      maxDepth = depth;
    }
    if (node.children.isEmpty) {
      node.row = nextRow++;
      return;
    }
    for (final child in node.children) {
      place(child, depth + 1);
    }
    node.row = (node.children.first.row + node.children.last.row) / 2;
  }

  for (final root in roots) {
    place(root, 0);
  }
  return Lineage(roots: roots, rowCount: nextRow.toInt(), depthCount: maxDepth + 1);
}
