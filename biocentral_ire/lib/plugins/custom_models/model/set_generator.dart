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
  }) {
    assert(subsplitSource == null ? subsplitTarget == null : true);
    assert(subsplitTarget == null ? subsplitSource == null : true);
    final bool subsplit = subsplitSource != null && subsplitTarget != null;

    switch (method) {
      case SplitSetGenerationMethod.random:
        return subsplit
            ? randomSubsplit(ids: ids, subsplitSource: subsplitSource, subsplitTarget: subsplitTarget)
            : randomFull(ids);
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

  static bool _inRange(int start, int end, int value) {
    return start <= value && value < end;
  }
}
