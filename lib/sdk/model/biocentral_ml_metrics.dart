import 'package:biocentral/sdk/util/constants.dart';

class BiocentralMLMetric implements Comparable<BiocentralMLMetric> {
  final String name;
  final double value;

  final UncertaintyEstimate? uncertaintyEstimate;

  BiocentralMLMetric({required this.name, required this.value, this.uncertaintyEstimate});

  BiocentralMLMetric absolute() {
    return BiocentralMLMetric(name: name, value: value.abs(), uncertaintyEstimate: uncertaintyEstimate?.absolute());
  }

  static BiocentralMLMetric? tryParse(String? name, String? value) {
    if (name == null || name == '' || value == null || value == '') {
      return null;
    }
    final double? valueParsed = double.tryParse(value);
    if (valueParsed == null) {
      return null;
    }
    return BiocentralMLMetric(name: name, value: valueParsed);
  }

  static BiocentralMLMetric? fromMap(Map<String, dynamic> map) {
    final name = map['metric'];
    final value = double.tryParse(map['value'].toString());
    final uncertaintyEstimate =
        UncertaintyEstimate.fromMap(map['uncertaintyEstimate'] ?? map['uncertainty_estimate'] ?? {});
    if (name == null || value == null) {
      return null;
    }
    return BiocentralMLMetric(name: name, value: value, uncertaintyEstimate: uncertaintyEstimate);
  }

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
  static (double?, double?) getBounds(String metricName) {
    final name = metricName.toLowerCase();
    final bool percentageMetric = ['accuracy', 'precision', 'recall', 'f1', 'auc', 'roc']
        .map((metric) => name.contains(metric))
        .reduce((v1, v2) => v1 || v2);
    if (percentageMetric) {
      return (0.0, 1.0);
    }
    final bool limitedByOneMetric = ['mcc', 'matthews-corr-coeff', 'spearmans-corr-coeff']
        .map((metric) => name.contains(metric))
        .reduce((v1, v2) => v1 || v2);
    if (limitedByOneMetric) {
      return (-1.0, 1.0);
    }
    final bool limitedByZeroMetric = ['loss', 'rmse', 'mse', 'mae', 'mean_squared_error', 'mean_absolute_error']
        .map((metric) => name.contains(metric))
        .reduce((v1, v2) => v1 || v2);
    if (limitedByZeroMetric) {
      return (0.0, null);
    }
    // Unbounded
    return (null, null);
  }

  Map<String, dynamic> toMap() {
    final result = {'metric': name, 'value': value};
    if (uncertaintyEstimate != null) {
      result.addAll({'uncertainty_estimate': uncertaintyEstimate!.toMap()});
    }
    return result;
  }

  @override
  String toString() {
    if(uncertaintyEstimate != null) {
      return '$name - $uncertaintyEstimate';
    }
    return '$name - ${value.toStringAsPrecision(Constants.maxDoublePrecision)}';
  }

  @override
  int compareTo(BiocentralMLMetric other) {
    if(name != other.name) {
      throw Exception('Can only compare metrics with the same name!');
    }
    if(uncertaintyEstimate != null && other.uncertaintyEstimate != null) {
      return uncertaintyEstimate!.compareTo(other.uncertaintyEstimate!);
    }
    return value.compareTo(other.value);
  }
}

final class UncertaintyEstimate implements Comparable<UncertaintyEstimate> {
  final String method;
  final double mean;
  final double lower;
  final double upper;

  final int? iterations;
  final int? sampleSize;
  final double? confidenceLevel;

  const UncertaintyEstimate({
    required this.method,
    required this.mean,
    required this.lower,
    required this.upper,
    required this.iterations,
    required this.sampleSize,
    required this.confidenceLevel,
  });

  UncertaintyEstimate absolute() {
    return UncertaintyEstimate(
      method: method,
      mean: mean.abs(),
      lower: lower.abs(),
      upper: upper.abs(),
      iterations: iterations,
      sampleSize: sampleSize,
      confidenceLevel: confidenceLevel,
    );
  }

  static UncertaintyEstimate? fromMap(Map<String, dynamic> map) {
    final method = map['method'];
    final mean = map['mean'];
    if (method == null || mean == null) {
      return null;
    }

    var lower = map['lower'];
    var upper = map['upper'];

    if (lower == null || upper == null) {
      if((lower == null) ^ (upper == null)) {
        // Only one of the values is missing => Error
        return null;
      }
      // Symmetrical error range around mean
      final error = map['error'];
      if(error == null) {
        return null;
      }
      lower = mean - error;
      upper = mean + error;
    }

    final iterations = map['iterations'];
    final sampleSize = map['sampleSize'] ?? map['sample_size'];
    final confidenceLevel = map['confidenceLevel'] ?? map['confidence_level'];

    return UncertaintyEstimate(
      method: method,
      mean: mean,
      lower: lower,
      upper: upper,
      iterations: iterations,
      sampleSize: sampleSize,
      confidenceLevel: confidenceLevel,
    );
  }

  /// Calculate approximate symmetrical error range from lower and upper bounds
  double get errorRange => (upper - lower) / 2;

  /// Checks if two uncertainty estimates are comparable, i.e. the parameters of the uncertainty estimate are the same
  bool isComparableTo(UncertaintyEstimate other) {
    return method == other.method &&
        iterations == other.iterations &&
        sampleSize == other.sampleSize &&
        confidenceLevel == other.confidenceLevel;
  }

  /// Implements the Comparable interface
  @override
  int compareTo(UncertaintyEstimate other) {
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

  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'mean': mean,
      'lower': lower,
      'upper': upper,
      'iterations': iterations,
      'sample_size': sampleSize,
      'confidence_level': confidenceLevel,
    };
  }

  @override
  String toString() {
    return '${mean.toStringAsFixed(Constants.maxDoublePrecision)} '
        '±${errorRange.toStringAsFixed(Constants.maxDoublePrecision)}';
  }
}
