enum SplitSet { train, val, test }

enum SplitSetGenerationMode { generateNew, subsplitExisting }

enum SplitSetGenerationMethod { random }

class SplitRatio {
  final double r1;
  final double? r2;
  final double? r3;

  SplitRatio._({required this.r1, required this.r2, required this.r3});

  factory SplitRatio.defaultForMode(SplitSetGenerationMode mode) {
    return switch (mode) {
      SplitSetGenerationMode.generateNew => SplitRatio._(r1: 0.8, r2: 0.1, r3: 0.1),
      SplitSetGenerationMode.subsplitExisting => SplitRatio._(r1: 0.5, r2: null, r3: null),
    };
  }

  factory SplitRatio.fromRecord((double, double?, double?) ratio) {
    var (r1, r2, r3) = ratio;
    r2 ??= r3;
    r2 ??= 1 - r1;
    r3 ??= 1 - (r1 + r2);
    assert(r1 + r2 + r3 == 1.0);
    return SplitRatio._(r1: r1, r2: r2, r3: r3);
  }

  factory SplitRatio.fromRatio(double ratio) {
    return SplitRatio.fromRecord((ratio, null, null));
  }

  (double, double, double) get full => (r1, r2!, r3!);

  (double, double) get subsplit => (r1, r2 ?? 1 - r1);
}

class SplitResult {
  final Map<String, SplitSet> splits;
  final String newColumnName;

  SplitResult(this.splits, this.newColumnName);

  Map<String, dynamic> serialize() {
    return {
      'splits': splits,
      'newColumnName': newColumnName,
    };
  }
}
