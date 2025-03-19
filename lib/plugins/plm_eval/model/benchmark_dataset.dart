class BenchmarkDataset implements Comparable<BenchmarkDataset> {
  final String datasetName;
  final String splitName;

  BenchmarkDataset({required this.datasetName, required this.splitName});

  static BenchmarkDataset? fromServerString(String? serverString) {
    if(serverString == null || serverString.isEmpty) {
      return null;
    }
    final values = serverString.split('-');
    if(values.length != 2) {
      return null;
    }
    return BenchmarkDataset(datasetName: values[0], splitName: values[1]);
  }

  static Map<String, List<String>> benchmarkDatasetsByDatasetName(List<BenchmarkDataset> datasets) {
    final result = <String, List<String>>{};
    for(final dataset in datasets) {
      result.putIfAbsent(dataset.datasetName, () => []);
      result[dataset.datasetName]?.add(dataset.splitName);
    }
    return result;
  }

  static Map<String, List<(String, T)>> separateBenchmarkDatasetsMapToSplitList<T>(Map<BenchmarkDataset, T> map) {
    final result = <String, List<(String, T)>>{};
    for(final entry in map.entries) {
      result.putIfAbsent(entry.key.datasetName, () => []);
      result[entry.key.datasetName]?.add((entry.key.splitName, entry.value));
    }
    return result;
  }

  @override
  int compareTo(BenchmarkDataset other) {
    if(datasetName == other.datasetName) {
      return splitName.compareTo(splitName);
    }
    return datasetName.compareTo(other.datasetName);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BenchmarkDataset &&
          runtimeType == other.runtimeType &&
          datasetName == other.datasetName &&
          splitName == other.splitName;

  @override
  int get hashCode => datasetName.hashCode ^ splitName.hashCode;
}
