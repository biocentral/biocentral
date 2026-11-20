import 'dart:math';

import 'package:biocentral/sdk/model/split_set.dart';

class SetGenerator {
  final SplitRatio splitRatio;

  SetGenerator({required this.splitRatio});

  Map<String, SplitSet> splitByMethod({
    required SplitSetGenerationMethod method,
    required List<String> ids,
    SplitSet? subsplitSource,
    SplitSet? subsplitTarget,
    Map<String, List<String>>? clusters,
    int? seed,
  }) {
    assert(subsplitSource == null ? subsplitTarget == null : true);
    assert(subsplitTarget == null ? subsplitSource == null : true);
    final bool subsplit = subsplitSource != null && subsplitTarget != null;

    switch (method) {
      case SplitSetGenerationMethod.random:
        return subsplit
            ? randomSubsplit(
                ids: ids,
                subsplitSource: subsplitSource,
                subsplitTarget: subsplitTarget,
                seed: seed,
              )
            : randomFull(ids, seed: seed);

      case SplitSetGenerationMethod.existingCluster:
      case SplitSetGenerationMethod.newCluster:
        final resolvedClusters = clusters ?? {for (var id in ids) id: [id]};
        return subsplit
            ? clusterSubsplit(
                clusters: resolvedClusters,
                subsplitSource: subsplitSource,
                subsplitTarget: subsplitTarget,
                seed: seed,
              )
            : clusterFull(
                clusters: resolvedClusters,
                seed: seed,
              );
    }
  }

  Map<String, SplitSet> randomFull(List<String> ids, {int? seed}) {
    final (train, val, test) = splitRatio.full;
    final int rangeTrain = (train * 100).truncate();
    final int rangeValidation = rangeTrain + (val * 100).truncate();

    final Map<String, SplitSet> result = {};
    final Random random = seed != null ? Random(seed) : Random();
    for (String id in ids) {
      SplitSet set;
      final int randomValue = random.nextInt(100);
      if (_inRange(0, rangeTrain, randomValue)) {
        set = SplitSet.train;
      } else if (_inRange(rangeTrain, rangeValidation, randomValue)) {
        set = SplitSet.val;
      } else {
        set = SplitSet.test;
      }
      result[id] = set;
    }
    return result;
  }

  Map<String, SplitSet> randomSubsplit({
    required List<String> ids,
    required SplitSet subsplitSource,
    required SplitSet subsplitTarget,
    int? seed,
  }) {
    final Map<String, SplitSet> result = {};
    final Random random = seed != null ? Random(seed) : Random();

    final (source, target) = splitRatio.subsplit;
    final int numberOfItemsToMove = (ids.length * target).round();

    final List<String> shuffledIds = List.of(ids)..shuffle(random);
    final List<String> idsToMove = shuffledIds.take(numberOfItemsToMove).toList();

    for (String id in ids) {
      if (idsToMove.contains(id)) {
        result[id] = subsplitTarget;
      } else {
        result[id] = subsplitSource;
      }
    }

    return result;
  }

  /// Cluster-aware full partition using greedy bin-packing
  Map<String, SplitSet> clusterFull({
    required Map<String, List<String>> clusters,
    int? seed,
  }) {
    final rand = seed != null ? Random(seed) : Random();
    final clusterReps = clusters.keys.toList()..shuffle(rand);
    final (rTrain, rVal, rTest) = splitRatio.full;

    final totalReps = clusterReps.length;
    final targets = {
      SplitSet.train: totalReps * rTrain,
      SplitSet.val: totalReps * rVal,
      SplitSet.test: totalReps * rTest,
    };
    final counts = {
      SplitSet.train: 0,
      SplitSet.val: 0,
      SplitSet.test: 0,
    };

    final result = <String, SplitSet>{};
    for (final clusterRep in clusterReps) {
      final members = clusters[clusterRep] ?? [clusterRep];

      SplitSet bestSet = SplitSet.train;
      double maxDeficit = -double.infinity;
      for (final s in [SplitSet.train, SplitSet.val, SplitSet.test]) {
        final deficit = targets[s]! - counts[s]!;
        if (deficit > maxDeficit) {
          maxDeficit = deficit;
          bestSet = s;
        }
      }
      result[clusterRep] = bestSet;
      counts[bestSet] = counts[bestSet]! + 1;

      for (final member in members) {
        if (member != clusterRep) {
          result[member] = SplitSet.member;
        }
      }
    }
    return result;
  }

  /// Cluster-aware subsplit using greedy bin-packing
  Map<String, SplitSet> clusterSubsplit({
    required Map<String, List<String>> clusters,
    required SplitSet subsplitSource,
    required SplitSet subsplitTarget,
    int? seed,
  }) {
    final rand = seed != null ? Random(seed) : Random();
    final clusterReps = clusters.keys.toList()..shuffle(rand);
    final (_, targetRatio) = splitRatio.subsplit;
    final targetRepCount = (clusters.length * targetRatio).round();

    int currentTargetCount = 0;
    final result = <String, SplitSet>{};

    for (final clusterRep in clusterReps) {
      final members = clusters[clusterRep] ?? [clusterRep];

      final SplitSet assignedRepSet;
      if (currentTargetCount < targetRepCount || currentTargetCount == 0) {
        assignedRepSet = subsplitTarget;
        currentTargetCount++;
      } else {
        assignedRepSet = subsplitSource;
      }
      result[clusterRep] = assignedRepSet;

      for (final member in members) {
        if (member != clusterRep) {
          result[member] = SplitSet.member;
        }
      }
    }
    return result;
  }

  static bool _inRange(int start, int end, int value) {
    return start <= value && value < end;
  }
}