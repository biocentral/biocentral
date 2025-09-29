import 'package:biocentral/sdk/biocentral_sdk.dart';

class BenchmarkDataset implements Comparable<BenchmarkDataset> {
  static const String _autoEvalSeparator = '-';

  final String taskName;

  final List<String> _values;

  BenchmarkDataset({required this.taskName}) : _values = taskName.split(_autoEvalSeparator);

  static BenchmarkDataset? fromCombinedString(String? serverString) {
    if (serverString == null || serverString.isEmpty) {
      return null;
    }
    return BenchmarkDataset(taskName: serverString);
  }

  static Map<String, List<String>> benchmarkDatasetsByDatasetName(List<BenchmarkDataset> datasets) {
    final result = <String, List<String>>{};
    for (final dataset in datasets) {
      if (dataset.datasetName != null && dataset.splitName != null) {
        result.putIfAbsent(dataset.datasetName!, () => []);
        result[dataset.datasetName!]?.add(dataset.splitName!);
      }
    }
    return result;
  }

  static Map<String, List<(String, T)>> separateBenchmarkDatasetsMapToSplitList<T>(Map<BenchmarkDataset, T> map) {
    final result = <String, List<(String, T)>>{};
    for (final (dataset, value) in map.entriesRecord) {
      if (dataset.datasetName != null && dataset.splitName != null) {
        result.putIfAbsent(dataset.datasetName!, () => []);
        result[dataset.datasetName]?.add((dataset.splitName!, value));
      }
    }
    return result;
  }

  String? get frameworkName => _values.length == 2 ? _values.first : null;

  String? get datasetName => _values.length == 3 ? _values[1] : _values[0];

  String? get splitName => _values.length >= 2 ? _values.last : null;

  @override
  int compareTo(BenchmarkDataset other) {
    return taskName.compareTo(other.taskName);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BenchmarkDataset && runtimeType == other.runtimeType && taskName == other.taskName;

  @override
  int get hashCode => taskName.hashCode ^ taskName.hashCode;
}
