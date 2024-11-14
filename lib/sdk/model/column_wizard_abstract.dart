import 'dart:math';

import 'package:collection/collection.dart';
import 'package:ml_linalg/vector.dart';

import 'package:biocentral/sdk/util/constants.dart';
import 'package:biocentral/sdk/model/column_wizard_operations.dart';

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

  int? _length;

  Future<int> length() async {
    return _length ??= valueMap.keys.length;
  }

  bool _valueIsInvalid(dynamic value) {
    return value == null || value.toString().isEmpty || double.tryParse(value.toString())?.isNaN == true;
  }

  List<int>? _missingIndices;

  Future<List<int>> getMissingIndices() async {
    if (_missingIndices != null) {
      return _missingIndices!;
    }
    final List<int> missingIndices = [];
    for ((int, dynamic) indexValue in valueMap.values.indexed) {
      final int index = indexValue.$1;
      final dynamic value = indexValue.$2;

      if (_valueIsInvalid(value)) {
        missingIndices.add(index);
      }
    }
    _missingIndices = missingIndices;
    return _missingIndices!;
  }

  Future<int> numberMissing() async {
    return (await getMissingIndices()).length;
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
    return {ColumnOperationType.toBinary, ColumnOperationType.removeMissing};
  }

  Future<List<(int, double)>> _getBarChartDataPoints() async {
    if (await handleAsDiscrete()) {
      final Map<String, int> counts = await getCounts();
      return counts.entries.indexed.map((indexEntry) => (indexEntry.$1, indexEntry.$2.value.toDouble())).toList();
    } else {
      // TODO BINS
      return [];
    }
  }

  Future<List<String>> _getBarChartBottomTitles() async {
    if (await handleAsDiscrete()) {
      final Map<String, int> counts = await getCounts();
      return counts.keys.toList();
    } else {
      // TODO BINS
      return [];
    }
  }

  Future<List<double>> _getBarChartLeftTitles() async {
    if (await handleAsDiscrete()) {
      final List<double> countValues = (await getCounts()).values.map((value) => value.toDouble()).toList();
      final double middle = Vector.fromList(countValues).median();
      final double max = countValues.max;
      return [0.0, middle, max];
    } else {
      // TODO BINS
      return [];
    }
  }

  Future<ColumnWizardBarChartData> getBarChartData() async {
    final List<String> bottomTitles = await _getBarChartBottomTitles();
    final List<double> leftTitleValues = await _getBarChartLeftTitles();
    final List<(int, double)> dataPoints = await _getBarChartDataPoints();
    final double maxY = Vector.fromList(dataPoints.map((e) => e.$2).toList()).max();
    return ColumnWizardBarChartData(
        maxY: maxY, bottomTitles: bottomTitles, leftTitleValues: leftTitleValues, dataPoints: dataPoints,);
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

class ColumnWizardBarChartData {
  final double maxY;
  final List<String> bottomTitles;
  final List<double> leftTitleValues;
  final List<(int, double)> dataPoints;

  ColumnWizardBarChartData(
      {required this.maxY, required this.bottomTitles, required this.leftTitleValues, required this.dataPoints,});
}
