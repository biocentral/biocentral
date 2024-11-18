import 'package:biocentral/sdk/util/constants.dart';

class BiocentralMLMetric {
  final String name;
  final double value;

  BiocentralMLMetric({required this.name, required this.value});

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

  /// Determines if the metric is ascending: The lower the better
  ///
  /// Defaults to false
  static bool isAscending(String name) {
    return ['loss', 'rmse', 'mse', 'mae', 'mean_squared_error', 'mean_absolute_error'].contains(name.toLowerCase());
  }

  @override
  String toString() {
    return '$name: ${value.toStringAsPrecision(Constants.maxDoublePrecision)}';
  }
}
