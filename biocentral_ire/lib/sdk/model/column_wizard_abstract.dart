import 'dart:math';

import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_bar_plot.dart';
import 'package:collection/collection.dart';
import 'package:ml_linalg/vector.dart';


abstract class ColumnWizardFactory<T extends ColumnWizard> {
  T create({required String columnName, required Map<String, dynamic> valueMap});

  TypeDetector getTypeDetector();
}

final class TypeDetector {
  final Type type;
  final bool Function(dynamic value) detectionFunction;
  final double priority;

  TypeDetector(this.type, this.detectionFunction) : priority = _calculatePriority(type);

  static double _calculatePriority(Type type) {
    if (type == int) return 0.9;
    if (type == double) return 0.8;
    if (type == num) return 0.7;
    if (type == String) return 0.1;
    return 1; // Priority for custom types should always be the highest
  }
}

abstract class ColumnWizard {
  final String columnName;

  Map<String, dynamic> get valueMap;

  ColumnWizard(this.columnName);

  Type get type => valueMap.values.firstOrNull.runtimeType;

  int? _length;

  Future<int> length() async {
    return _length ??= valueMap.keys.length;
  }

  bool _valueIsInvalid(dynamic value) {
    return value == null || value.toString().isEmpty || double.tryParse(value.toString())?.isNaN == true;
  }

  Set<String>? _keysWithMissingValues;

  Future<Set<String>> getMissingValues() async {
    if (_keysWithMissingValues != null) {
      return _keysWithMissingValues!;
    }
    final Set<String> keysWithMissingValues = {};
    for(final (key, value) in valueMap.entriesRecord) {
      if (_valueIsInvalid(value)) {
        keysWithMissingValues.add(key);
      }
    }
    _keysWithMissingValues = keysWithMissingValues;
    return _keysWithMissingValues!;
  }

  Future<int> numberMissing() async {
    return (await getMissingValues()).length;
  }

  Map<String, int>? _counts;

  Future<Map<String, int>> getCounts() async {
    if (_counts != null) {
      return _counts!;
    }

    final Map<String, int> counts = {};
    for (dynamic value in valueMap.values) {
      if (_valueIsInvalid(value)) {
        continue;
      }
      final String valueString = value.toString();
      counts.putIfAbsent(valueString, () => 0);

      counts[valueString] = counts[valueString]! + 1;
    }
    _counts = counts;
    return _counts!;
  }

  Future<bool> handleAsDiscrete() async {
    final Map<String, int> counts = await getCounts();
    return counts.keys.length <= Constants.discreteColumnThreshold;
  }

  Set<ColumnOperationType> getAvailableOperations() {
    return {ColumnOperationType.toBinary, ColumnOperationType.removeMissing, ColumnOperationType.calculateLength};
  }

  Future<Map<String, int>> _getBarPlotDataPoints() async {
    if (await handleAsDiscrete()) {
      final Map<String, int> counts = await getCounts();
      return counts;
    } else {
      // TODO BINS
      return {};
    }
  }

  Future<BiocentralBarPlotData> getBarPlotData() async {
    final Map<String, int> dataPoints = await _getBarPlotDataPoints();
    return BiocentralBarPlotData.withoutErrors(dataPoints.map((k, v) => MapEntry(k, v.toDouble())));
  }
}

mixin NumericStats on ColumnWizard {
  Vector get numericValues;

  Future<double> max() async {
    return numericValues.max();
  }

  Future<double> min() async {
    return numericValues.min();
  }

  Future<double> mean() async {
    return numericValues.mean();
  }

  Future<double> median() async {
    return numericValues.median();
  }

  Future<double> percentile(int percentile) async {
    if (percentile < 0 || percentile > 100) {
      throw ArgumentError('Percentile must be between 0 and 100');
    }

    if (numericValues.isEmpty) {
      throw StateError('Cannot calculate percentile of empty vector');
    }

    // Convert vector to sorted list
    final sortedValues = numericValues.toList()..sort();

    // Handle edge cases
    if (percentile == 0) {
      return sortedValues.first;
    }
    if (percentile == 100) {
      return sortedValues.last;
    }

    // Calculate position using linear interpolation method
    final position = (percentile.toDouble() / 100) * (sortedValues.length - 1);
    final lowerIndex = position.floor();
    final upperIndex = position.ceil();

    // If position is exactly on an index, return that value
    if (lowerIndex == upperIndex) {
      return sortedValues[lowerIndex];
    }

    // Linear interpolation between two nearest values
    final lowerValue = sortedValues[lowerIndex];
    final upperValue = sortedValues[upperIndex];
    final fraction = position - lowerIndex;

    return lowerValue + (upperValue - lowerValue) * fraction;
  }

  double? _mode;

  Future<double> mode() async {
    if (_mode == null) {
      final Map<double, int> frequencyMap = {};
      for (final value in numericValues) {
        frequencyMap[value] = (frequencyMap[value] ?? 0) + 1;
      }
      int maxFrequency = 0;
      double modeValue = 0;
      frequencyMap.forEach((key, value) {
        if (value > maxFrequency) {
          maxFrequency = value;
          modeValue = key;
        }
      });
      _mode = modeValue;
    }
    return _mode!;
  }

  double? _variance;

  Future<double> variance() async {
    if (_variance == null) {
      final double mean = await this.mean();
      _variance = numericValues.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / (numericValues.length - 1);
    }
    return _variance!;
  }

  double? _stdDev;

  Future<double> stdDev() async {
    if (_stdDev == null) {
      final double variance = await this.variance();
      _stdDev = sqrt(variance);
    }
    return _stdDev!;
  }

  Future<List<int>> detectOutliers({double? lowerBound, double? upperBound}) async {
    (double, double) bounds = await calculateStandardBounds();
    lowerBound ??= bounds.$1;
    upperBound ??= bounds.$2;

    final List<int> outlierIndices = [];
    for ((int, num) indexValue in numericValues.indexed) {
      if (indexValue.$2 < lowerBound || indexValue.$2 > upperBound) {
        outlierIndices.add(indexValue.$1);
      }
    }
    return outlierIndices;
  }

  Future<(double, double)> calculateStandardBounds() async {
    final double mu = await mean();
    final double sigma = await stdDev();
    return (mu - 3 * sigma, mu + 3 * sigma);
  }

  Future<List<List<double>>> toBins({int numberBins = 10}) async {
    final double max = await this.max();
    final double min = await this.min();

    double binSize = (max - min).abs() / numberBins;
    if (binSize == 0.0) {
      binSize = min;
    }
    final List<List<double>> result = List.generate(numberBins, (_) => []);

    for (double value in numericValues.sorted((a, b) => a.compareTo(b))) {
      int binIndex = ((value - min) / binSize).floor();
      if (binIndex == numberBins) {
        // Handle edge case where value is the maximum
        binIndex--;
      }
      result[binIndex].add(value);
    }
    return result;
  }
}

mixin CounterStats on ColumnWizard {}
