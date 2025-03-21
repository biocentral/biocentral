import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:collection/collection.dart';


typedef ModelName = String;
typedef DatasetName = String;

/// Helper class to combine PredictionModel with dataset-specific information
class PLMLeaderboardEntry {
  final PredictionModel predictionModel;
  final BenchmarkDataset benchmarkDataset;
  final DateTime trainingDate;

  const PLMLeaderboardEntry({
    required this.predictionModel,
    required this.benchmarkDataset,
    required this.trainingDate,
  });
}

class PLMLeaderboard {
  final Map<ModelName, List<PLMLeaderboardEntry>> modelNameToEntries;

  const PLMLeaderboard._({required this.modelNameToEntries});

  const PLMLeaderboard.empty() : modelNameToEntries = const {};

  factory PLMLeaderboard.fromPersistentResults(List<PLMEvalPersistentResult> persistentResults) {
    final Map<ModelName, List<PLMLeaderboardEntry>> entries = {};
    for (final result in persistentResults) {
      entries[result.modelName] = [];
      for (final benchmarkResultEntry in result.results.entries) {
        if (benchmarkResultEntry.value == null) {
          // TODO [Error handling] This case should not happen, so throw an error here
          continue;
        }
        entries[result.modelName]?.add(
          PLMLeaderboardEntry(
            predictionModel: benchmarkResultEntry.value!,
            benchmarkDataset: benchmarkResultEntry.key,
            trainingDate: result.trainingDate,
          ),
        );
      }
    }
    return PLMLeaderboard._(modelNameToEntries: entries);
  }

  factory PLMLeaderboard.mixed(PLMLeaderboard remote, PLMLeaderboard local) {
    final mixedEntries = remote.modelNameToEntries;
    for(final (localModelName, map) in local.modelNameToEntries.entriesRecord) {
      String modelName = localModelName;
      if(mixedEntries.containsKey(localModelName)) {
        modelName = '$localModelName - LOCAL';
      }
      mixedEntries[modelName] = map;
    }
    return PLMLeaderboard._(modelNameToEntries: mixedEntries);
  }

  List<(String, double)> getRanking(Map<String, String> recommendedMetrics) {
    return PLMLeaderboardRankingCalculator().getRanking(modelNameToEntries, recommendedMetrics);
  }

  // Get all unique dataset-split combinations
  Set<BenchmarkDataset> get benchmarkDatasets => PLMLeaderboardRankingCalculator.benchmarkDatasets(modelNameToEntries);

  // Get entries for a specific benchmark dataset
  List<PLMLeaderboardEntry> getEntriesForBenchmark(BenchmarkDataset benchmark) =>
      PLMLeaderboardRankingCalculator.getEntriesForBenchmark(modelNameToEntries, benchmark).map((e) => e.$2).toList();

  Map<String, Set<BiocentralMLMetric>> getMetricsForBenchmark(BenchmarkDataset benchmark) {
    final relevantEntries = getEntriesForBenchmark(benchmark);

    return Map.fromEntries(
      relevantEntries.map(
        (entry) => MapEntry(
          entry.predictionModel.embedderName ?? 'Unknown',
          entry.predictionModel.biotrainerTrainingResult?.testSetMetrics ?? {},
        ),
      ),
    );
  }
}

class PLMLeaderboardRankingCalculator {
  static const Map<String, List<String>> flipCategories = {
    'VirusRelatedFitness': ['aav', 'gb1'],
  };

  List<(String, double)> getRanking(
    Map<ModelName, List<PLMLeaderboardEntry>> modelNameToEntries,
    Map<String, String> recommendedMetrics,
  ) {
    final Set<BenchmarkDataset> allBenchmarkDatasets = benchmarkDatasets(modelNameToEntries);
    final benchmarkMap = BenchmarkDataset.benchmarkDatasetsByDatasetName(allBenchmarkDatasets.toList());

    final Map<DatasetName, Map<ModelName, double>> datasetRankings = {};
    for (final benchmarkEntry in benchmarkMap.entries) {
      final datasetName = benchmarkEntry.key;

      // PER-SPLIT
      final List<Map<String, int>> splitRankings = [];
      for (final splitName in benchmarkEntry.value) {
        final entriesForSplit = getEntriesForBenchmark(
          modelNameToEntries,
          BenchmarkDataset(datasetName: datasetName, splitName: splitName),
        );
        final splitRanking = _getSplitRanking(recommendedMetrics[datasetName] ?? 'loss', entriesForSplit);
        splitRankings.add(splitRanking);
      }

      // PER-DATASET
      if (splitRankings.isEmpty) {
        // TODO [Error handling] This should not happen, should be caught earlier
        continue;
      }

      final Map<ModelName, double> datasetRanking = _getDatasetRanking(splitRankings);
      datasetRankings[datasetName] = datasetRanking;
    }

    // PER-CATEGORY
    final Map<DatasetName, Map<ModelName, double>> categoryRankings = _getCategoryRankings(datasetRankings);
    
    final Map<String, double> rankingResult = {};
    for(final rankingMap in categoryRankings.values) {
      for(final (modelName, rankingValue) in rankingMap.entriesRecord) {
        rankingResult.putIfAbsent(modelName, () => 0.0);
        final newValue = (rankingResult[modelName] ?? 0.0) + rankingValue;
        rankingResult[modelName] = newValue; 
      }
    }
    return _sortRanking(rankingResult);
  }

  Map<String, int> _getSplitRanking(String recommendedMetric, List<(ModelName, PLMLeaderboardEntry)> entriesForSplit) {
    final List<(ModelName, BiocentralMLMetric)> modelNamesToMetrics = [];
    for (final (modelName, entry) in entriesForSplit) {
      final metric = entry.predictionModel.biotrainerTrainingResult?.testSetMetrics
          .where((e) => e.name == recommendedMetric)
          .firstOrNull;
      if (metric == null || metric.uncertaintyEstimate == null) {
        // TODO [Error handling] This should not happen, should be caught earlier
        continue;
      }
      modelNamesToMetrics.add((modelName, metric));
    }
    if (modelNamesToMetrics.isEmpty) {
      // TODO [Error handling] Log error here
      return {};
    }
    List<(ModelName, BiocentralMLMetric)> sorted =
        modelNamesToMetrics.sorted((e1, e2) => e1.$2.uncertaintyEstimate!.compareTo(e2.$2.uncertaintyEstimate!));
    if (BiocentralMLMetric.isAscending(sorted.first.$2.name)) {
      sorted = sorted.reversed.toList();
    }
    final Map<ModelName, int> result = {};
    for (final (index, (name, metric)) in sorted.indexed) {
      result[name] = index;
    }
    return result;
  }

  /// Averages over the split rankings
  Map<ModelName, double> _getDatasetRanking(List<Map<ModelName, int>> splitRankings) {
    return _getRankingsAverage(splitRankings);
  }

  // Averages over datasets in the same category
  Map<DatasetName, Map<ModelName, double>> _getCategoryRankings(Map<DatasetName, Map<ModelName, double>> datasetRankings) {
    final Map<String, Map<String, double>> result = {};
    final Set<String> datasetsToSummarize = {};
    for (final datasetCategory in flipCategories.entries) {
      final List<Map<String, double>> rankingsForCategory = datasetRankings.entries
          .where((entry) => datasetCategory.value.contains(entry.key))
          .map((entry) => entry.value)
          .toList();
      final categoryRanking = _getRankingsAverage(rankingsForCategory);
      result[datasetCategory.key] = categoryRanking;
      datasetsToSummarize.addAll(datasetCategory.value);
    }
    for(final entry in datasetRankings.entries) {
      if(datasetsToSummarize.contains(entry.key)) {
        continue;
      }
      result[entry.key] = entry.value;
    }
    return result;
  }

  List<(ModelName, double)> _sortRanking(Map<ModelName, double> rankingMap) {
    return rankingMap.entries
        .map((entry) => (entry.key, entry.value))
        .toList()
        .sorted((e1, e2) => e1.$2.compareTo(e2.$2));
  }

  static Map<ModelName, double> _getRankingsAverage(List<Map<ModelName, num>> rankings) {
    final Map<String, double> result = {};
    final int numberSplits = rankings.length;
    for (final ranking in rankings) {
      for (final entry in ranking.entries) {
        result.putIfAbsent(entry.key, () => 0.0);
        final newValue = (result[entry.key] ?? 0.0) + entry.value;
        result[entry.key] = newValue;
      }
    }
    return result.map((k, v) => MapEntry(k, v / numberSplits));
  }

  // Get all unique dataset-split combinations
  static Set<BenchmarkDataset> benchmarkDatasets(
    Map<ModelName, List<PLMLeaderboardEntry>> modelNameToEntries,
  ) {
    final Set<BenchmarkDataset> result = {};
    for (final entries in modelNameToEntries.values) {
      result.addAll(entries.map((e) => e.benchmarkDataset));
    }
    return result;
  }

  static List<(ModelName, PLMLeaderboardEntry)> getEntriesForBenchmark(
    Map<ModelName, List<PLMLeaderboardEntry>> modelNameToEntries,
    BenchmarkDataset benchmark,
  ) {
    final List<(ModelName, PLMLeaderboardEntry)> result = [];
    for (final entry in modelNameToEntries.entries) {
      result.addAll(entry.value.where((e) => e.benchmarkDataset == benchmark).map((e) => (entry.key, e)));
    }
    return result;
  }
}
