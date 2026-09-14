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
    Map<String, String>? entityIdToClusterId,

  }) {
    assert(subsplitSource == null ? subsplitTarget == null : true);
    assert(subsplitTarget == null ? subsplitSource == null : true);
    final bool subsplit = subsplitSource != null && subsplitTarget != null;

    switch (method) {
      case SplitSetGenerationMethod.random:
        return subsplit
            ? randomSubsplit(ids: ids, subsplitSource: subsplitSource, subsplitTarget: subsplitTarget)
            : randomFull(ids);

      case SplitSetGenerationMethod.existingCluster:
      
      case SplitSetGenerationMethod.newCluster:
        final clusterMap = entityIdToClusterId ?? {for (var id in ids) id: id};
        return subsplit
            ? clusterSubsplit(
                ids: ids,
                entityIdToClusterId: clusterMap,
                subsplitSource: subsplitSource!,
                subsplitTarget: subsplitTarget!,
              )
            : clusterFull(ids: ids, entityIdToClusterId: clusterMap);

    }
  }

  Map<String, SplitSet> randomFull(List<String> ids) {
    final (train, val, test) = splitRatio.full;
    final int rangeTrain = (train * 100).truncate();
    final int rangeValidation = rangeTrain + (val * 100).truncate();

    final Map<String, SplitSet> result = {};
    final Random random = Random();
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
  }) {
    final Map<String, SplitSet> result = {};
    final Random random = Random();

    // Calculate how many should be moved to the new set
    final (source, target) = splitRatio.subsplit;
    final int numberOfItemsToMove = (ids.length * target).round();

    // Randomly select items to move
    ids.shuffle(random);
    final List<String> idsToMove = ids.take(numberOfItemsToMove).toList();

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
    required List<String> ids,
    required Map<String, String> entityIdToClusterId,
    int seed = 42,
  }) {
    final rand = Random(seed);
    final clusterToEntities = <String, List<String>>{};
    for (final id in ids) {
      final cluster = entityIdToClusterId[id] ?? id;
      clusterToEntities.putIfAbsent(cluster, () => []).add(id);
    }

    final clusters = clusterToEntities.keys.toList()..shuffle(rand);
    final (rTrain, rVal, rTest) = splitRatio.full;
    final total = ids.length;

    final targets = {
      SplitSet.train: total * rTrain,
      SplitSet.val: total * rVal,
      SplitSet.test: total * rTest,
    };
    final counts = {
      SplitSet.train: 0,
      SplitSet.val: 0,
      SplitSet.test: 0,
    };

    final result = <String, SplitSet>{};
    for (final cluster in clusters) {
      final members = clusterToEntities[cluster]!;
      final memberCount = members.length;

      // Select partition bucket furthest below desired target
      SplitSet bestSet = SplitSet.train;
      double maxDeficit = -double.infinity;
      for (final s in SplitSet.values) {
        final deficit = targets[s]! - counts[s]!;
        if (deficit > maxDeficit) {
          maxDeficit = deficit;
          bestSet = s;
        }
      }

      for (final member in members) {
        result[member] = bestSet;
      }
      counts[bestSet] = counts[bestSet]! + memberCount;
    }
    return result;
  }

  /// Cluster-aware subsplit using greedy bin-packing
  Map<String, SplitSet> clusterSubsplit({
    required List<String> ids,
    required Map<String, String> entityIdToClusterId,
    required SplitSet subsplitSource,
    required SplitSet subsplitTarget,
    int seed = 42,
  }) {
    final rand = Random(seed);
    final clusterToEntities = <String, List<String>>{};
    for (final id in ids) {
      final cluster = entityIdToClusterId[id] ?? id;
      clusterToEntities.putIfAbsent(cluster, () => []).add(id);
    }

    final clusters = clusterToEntities.keys.toList()..shuffle(rand);
    final (_, targetRatio) = splitRatio.subsplit;
    final targetCount = ids.length * targetRatio;

    int currentTargetCount = 0;
    final result = <String, SplitSet>{};

    for (final cluster in clusters) {
      final members = clusterToEntities[cluster]!;
      if (currentTargetCount + members.length <= targetCount || currentTargetCount == 0) {
        for (final m in members) {
          result[m] = subsplitTarget;
        }
        currentTargetCount += members.length;
      } else {
        for (final m in members) {
          result[m] = subsplitSource;
        }
      }
    }
    return result;
  }

  static bool _inRange(int start, int end, int value) {
    return start <= value && value < end;
  }
}
