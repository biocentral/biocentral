import 'package:biocentral/sdk/util/constants.dart';

class BiocentralMLMetric {
  final String name;
  final double value;

  final UncertaintyEstimate? uncertaintyEstimate;

  BiocentralMLMetric({required this.name, required this.value, this.uncertaintyEstimate});

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
    final uncertaintyEstimate = UncertaintyEstimate.fromMap(map['uncertaintyEstimate'] ?? {});
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

  Map<String, dynamic> toMap() {
    final result = {'metric': name, 'value': value};
    if (uncertaintyEstimate != null) {
      result.addAll({'uncertaintyEstimate': uncertaintyEstimate!.toMap()});
    }
    return result;
  }

  @override
  String toString() {
    return '$name: ${value.toStringAsPrecision(Constants.maxDoublePrecision)}';
  }
}

final class UncertaintyEstimate implements Comparable<UncertaintyEstimate> {
  final String method;
  final double mean;
  final double error;

  final int? iterations;
  final int? sampleSize;
  final double? confidenceLevel;

  const UncertaintyEstimate({
    required this.method,
    required this.mean,
    required this.error,
    required this.iterations,
    required this.sampleSize,
    required this.confidenceLevel,
  });

  static UncertaintyEstimate? fromMap(Map<String, dynamic> map) {
    final method = map['method'];
    final mean = map['mean'];
    final error = map['error'];
    final iterations = map['iterations'];
    final sampleSize = map['sampleSize'] ?? map['sample_size'];
    final confidenceLevel = map['confidenceLevel'] ?? map ['confidence_level'];

    if (method == null || mean == null || error == null) {
      return null;
    }
    return UncertaintyEstimate(
      method: method,
      mean: mean,
      error: error,
      iterations: iterations,
      sampleSize: sampleSize,
      confidenceLevel: confidenceLevel,
    );
  }

  /// Checks if two uncertainty estimates are comparable, i.e. the parameters of the uncertainty estimate are the same
  bool isComparableTo(UncertaintyEstimate other) {
    return method == other.method &&
        iterations == other.iterations &&
        sampleSize == other.sampleSize &&
        confidenceLevel == other.confidenceLevel;
  }

  /// Returns the lower bound of the confidence interval
  double get lowerBound => mean - error;

  /// Returns the upper bound of the confidence interval
  double get upperBound => mean + error;

  /// Implements the Comparable interface
  @override
  int compareTo(UncertaintyEstimate other) {
    // Verify that the estimates are comparable
    if (!isComparableTo(other)) {
      throw ArgumentError(
          'Cannot compare uncertainty estimates with different parameters:\n'
              'This: $this\n'
              'Other: $other'
      );
    }

    // Check for exact equality
    if (mean == other.mean && error == other.error) {
      return 0;
    }

    // Compare non-overlapping ranges
    if (lowerBound > other.upperBound) {
      return 1;
    }
    if (upperBound < other.lowerBound) {
      return -1;
    }

    // Ranges overlap, consider them equal
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'mean': mean,
      'error': error,
      'iterations': iterations,
      'sampleSize': sampleSize,
      'confidenceLevel': confidenceLevel
    };
  }
}
