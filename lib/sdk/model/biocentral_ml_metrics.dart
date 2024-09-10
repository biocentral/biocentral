import '../util/constants.dart';

class BiocentralMLMetric {
  final String name;
  final double value;

  BiocentralMLMetric({required this.name, required this.value});

  static BiocentralMLMetric? tryParse(String? name, String? value) {
    if (name == null || name == "" || value == null || value == "") {
      return null;
    }
    double? valueParsed = double.tryParse(value);
    if (valueParsed == null) {
      return null;
    }
    return BiocentralMLMetric(name: name, value: valueParsed);
  }

  @override
  String toString() {
    return "$name: ${value.toStringAsPrecision(Constants.maxDoublePrecision)}";
  }
}
