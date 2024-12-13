import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';

extension PlmLeaderboardDTO on BiocentralDTO {
  Set<String> get keys => responseMap.keys.map((key) => key.toString()).toSet();

  BiocentralDTO? operator [](String key) {
    return BiocentralDTO(responseMap[key]);
  }

  BiocentralDTO get leaderboard => BiocentralDTO(responseMap['leaderboard'] ?? {});

  Map<String, double> get ranking => Map.fromEntries((get<Map<String, dynamic>>('ranking') ?? {})
      .entries
      .where((entry) => entry.value != null && entry.value.toString().trim().isNotEmpty && entry.value is num)
      .map((entry) => MapEntry(entry.key.toString(), double.parse(entry.value.toString())))
      .whereType<MapEntry<String, double>>(),
  );

  BiocentralDTO get metadata => BiocentralDTO(responseMap['metadata'] ?? {});

  Set<BiocentralMLMetric> get metrics => (get<Map<String, dynamic>>('metrics') ?? {})
      .entries
      .where((entry) => entry.value != null && entry.value.toString().trim().isNotEmpty && entry.value is num)
      .map((entry) => BiocentralMLMetric.tryParse(entry.key.toString(), entry.value.toString()))
      .whereType<BiocentralMLMetric>()
      .toSet();

  DateTime? get trainingDate {
    try {
      return DateTime.parse(metadata.get<String>('training_date')?.split('.').first ?? '');
    } catch (e) {
      return null;
    }
  }

  String? get biotrainerVersion => metadata.get<String>('biotrainer_version');

  String? get modelName => metadata.get<String>('model_name');

  String? get _datasetName => metadata.get<String>('dataset_name');

  String? get _splitName => metadata.get<String>('split_name');

  BenchmarkDataset? get benchmarkDataset {
    final datasetName = _datasetName;
    final splitName = _splitName;

    if (datasetName == null || splitName == null) {
      return null;
    }
    return BenchmarkDataset(datasetName: datasetName, splitName: splitName);
  }
}
