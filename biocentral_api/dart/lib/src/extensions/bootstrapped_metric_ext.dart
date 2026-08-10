import '../model/bootstrapped_metric.dart';

extension BootstrappedMetricExt on BootstrappedMetric {

  /// Determines if the metric is ascending: The lower the better
  ///
  /// Defaults to false
  static bool isAscending(String name) {
    return ['loss', 'rmse', 'mse', 'mae', 'mean_squared_error', 'mean_absolute_error'].contains(name.toLowerCase());
  }

  /// Gets the bounds for the given metric
  ///
  /// E.g., accuracy must always be between 0.0 and 1.0
  ///
  /// Null value means no bound
  static (double?, double?) getBounds(String name) {
    final metricName = name.toLowerCase();
    final bool percentageMetric = ['accuracy', 'precision', 'recall', 'f1', 'auc', 'roc']
        .map((metric) => metricName.contains(metric))
        .reduce((v1, v2) => v1 || v2);
    if (percentageMetric) {
      return (0.0, 1.0);
    }
    final bool limitedByOneMetric = ['mcc', 'matthews-corr-coeff', 'spearmans-corr-coeff']
        .map((metric) => metricName.contains(metric))
        .reduce((v1, v2) => v1 || v2);
    if (limitedByOneMetric) {
      return (-1.0, 1.0);
    }
    final bool limitedByZeroMetric = ['loss', 'rmse', 'mse', 'mae', 'mean_squared_error', 'mean_absolute_error']
        .map((metric) => metricName.contains(metric))
        .reduce((v1, v2) => v1 || v2);
    if (limitedByZeroMetric) {
      return (0.0, null);
    }
    // Unbounded
    return (null, null);
  }

  BootstrappedMetric absolute() {
    return BootstrappedMetric((b) =>
      b..name = name
      ..mean = mean.abs()
      ..lower = lower.abs()
      ..upper = upper.abs()
      ..iterations = iterations
      ..sampleSize = sampleSize
      ..confidenceLevel = confidenceLevel
    );
  }

  /// Calculate approximate symmetrical error range from lower and upper bounds
  double get errorRange => (upper - lower) / 2;

  /// Checks if two metrics are comparable, i.e. the parameters of the uncertainty estimate are the same
  bool isComparableTo(BootstrappedMetric other) {
    return name == other.name &&
        iterations == other.iterations &&
        sampleSize == other.sampleSize &&
        confidenceLevel == other.confidenceLevel;
  }

  /// Implements the Comparable interface
  @override
  int compareTo(BootstrappedMetric other) {
    // Verify that the estimates are comparable
    if (!isComparableTo(other)) {
      throw ArgumentError('Cannot compare uncertainty estimates with different parameters:\n'
          'This: $this\n'
          'Other: $other');
    }

    final comp1 = absolute();
    final comp2 = other.absolute();

    // Check for exact equality
    if (comp1.mean == comp2.mean && comp1.lower == comp2.lower && comp1.upper == comp2.upper) {
      return 0;
    }

    // Compare non-overlapping ranges
    if (comp1.lower > comp2.upper) {
      return 1;
    }
    if (comp1.upper < comp2.lower) {
      return -1;
    }

    // Ranges overlap, consider them equal
    return 0;
  }

  String rangeString({int maxDoublePrecision = 3}) {
    return '${mean.toStringAsFixed(maxDoublePrecision)} '
        '±${errorRange.toStringAsFixed(maxDoublePrecision)}';
  }
}
