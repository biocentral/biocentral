import 'dart:math';

class SetGenerator {
  final double train;
  final double validation;
  final double test;

  SetGenerator.holdOut({required this.train, required this.validation, required this.test})
      : assert((train + validation + test) <= 1.0,
            'Percentages must add up to 1.0 (current: ${(train + validation + test)})!',);

  SetGenerator.crossValidation({required this.train, required this.test})
      : validation = 0.0,
        assert((train + test) <= 1.0, 'Percentages must add up to 1.0!');

  Map<String, SplitSet> splitByMethod(SplitSetGenerationMethod method, List<String> ids) {
    switch (method) {
      case SplitSetGenerationMethod.random:
        return random(ids);
    }
  }

  Map<String, SplitSet> random(List<String> ids) {
    final int rangeTrain = (train * 100).truncate();
    final int rangeValidation = rangeTrain + (validation * 100).truncate();

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

  static bool _inRange(int start, int end, int value) {
    return start <= value && value < end;
  }
}

enum SplitSet { train, val, test }

enum SplitSetGenerationMethod { random }
