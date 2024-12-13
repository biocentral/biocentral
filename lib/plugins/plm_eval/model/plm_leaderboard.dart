import 'package:biocentral/plugins/plm_eval/data/plm_leaderboard_dto.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';

/// Helper class to combine PredictionModel with dataset-specific information
class PLMLeaderboardEntry {
  final PredictionModel model;
  final BenchmarkDataset benchmarkDataset;
  final DateTime? trainingDate;

  const PLMLeaderboardEntry({
    required this.model,
    required this.benchmarkDataset,
    this.trainingDate,
  });
}

class PLMLeaderboard {
  final List<PLMLeaderboardEntry> entries;

  final List<(String, double)> ranking;

  const PLMLeaderboard._({required this.entries, required this.ranking});

  const PLMLeaderboard.empty() : entries = const [], ranking = const [];

  static Either<BiocentralParsingException, PLMLeaderboard> fromDTO(BiocentralDTO fullDTO) {
    final List<PLMLeaderboardEntry> parsedEntries = [];

    final sortedRanking = fullDTO.ranking.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value));
    final sortedRankingTuples = List<(String, double)>.from(sortedRanking.map((entry) => (entry.key, entry.value)));

    if(sortedRankingTuples.isEmpty) {
      // TODO Throw exception
    }

    final leaderboardDTO = fullDTO.leaderboard;

    for (String key in leaderboardDTO.keys) {
      final BiocentralDTO? dto = leaderboardDTO[key];

      if (dto == null) {
        return left(BiocentralParsingException(message: 'Could not parse leaderboard entry from DTO (key: $key)!'));
      }

      final benchmarkDataset = dto.benchmarkDataset;
      if (benchmarkDataset == null) {
        return left(BiocentralParsingException(message: 'Could not parse benchmark dataset from server DTO!'));
      }

      final Set<BiocentralMLMetric> metrics = dto.metrics;
      if (metrics.isEmpty) {
        return left(BiocentralParsingException(message: 'Could not parse any metrics from server DTO!'));
      }

      final String? modelName = dto.modelName;
      if (modelName == null || modelName.isEmpty) {
        return left(BiocentralParsingException(message: 'Could not parse model name from server DTO!'));
      }

      final String? biotrainerVersion = dto.biotrainerVersion;
      final modelData = {
        'embedder_name': modelName,
        'biotrainer_version': biotrainerVersion,
      };
      final predictionModel = PredictionModel.fromMap(modelData);
      if (predictionModel == null) {
        return left(BiocentralParsingException(message: 'Could not parse model information from server DTO!'));
      }
      final results = BiotrainerTrainingResult(
          trainingLoss: {},
          validationLoss: {},
          testSetMetrics: metrics,
          sanityCheckWarnings: {},
          sanityCheckBaselineMetrics: {},
          trainingLogs: [],
          trainingStatus: BiocentralTaskStatus.finished);
      final modelWithResults = predictionModel.copyWith(
        biotrainerTrainingResult: results,
      );
      final DateTime? trainingDate = dto.trainingDate;
      if (trainingDate == null) {
        logger.w('Could not parse training date from DTO!');
      }
      parsedEntries.add(
        PLMLeaderboardEntry(model: modelWithResults, benchmarkDataset: benchmarkDataset, trainingDate: trainingDate),
      );
    }
    return right(PLMLeaderboard._(entries: parsedEntries, ranking: sortedRankingTuples));
  }

  // Get all unique dataset-split combinations
  Set<BenchmarkDataset> get benchmarkDatasets => entries.map((e) => e.benchmarkDataset).toSet();

  // Get entries for a specific benchmark dataset
  List<PLMLeaderboardEntry> getEntriesForBenchmark(BenchmarkDataset benchmark) {
    return entries.where((e) => e.benchmarkDataset == benchmark).toList();
  }

  // Calculate rankings for each benchmark dataset
  Map<BenchmarkDataset, Map<String, int>> calculateBenchmarkRankings(String metricName) {
    final rankings = <BenchmarkDataset, Map<String, int>>{};
    final bool higherIsBetter = !BiocentralMLMetric.isAscending(metricName);

    // Calculate rankings for each benchmark dataset
    for (final benchmark in benchmarkDatasets) {
      final benchmarkEntries = getEntriesForBenchmark(benchmark);
      final embedderScores = <String, double>{};

      // Get scores for each model
      for (final entry in benchmarkEntries) {
        final modelName = entry.model.embedderName;
        if (modelName == null) continue;

        final metric =
            entry.model.biotrainerTrainingResult?.testSetMetrics.firstWhereOrNull((m) => m.name == metricName)?.value;

        if (metric != null) {
          embedderScores[modelName] = metric;
        }
      }

      // Sort models by score
      final sortedEmbedders = embedderScores.keys.toList()
        ..sort((a, b) {
          final comparison = embedderScores[b]!.compareTo(embedderScores[a]!);
          return higherIsBetter ? comparison : -comparison;
        });

      // Assign rankings
      rankings[benchmark] = Map.fromIterables(
        sortedEmbedders,
        List.generate(sortedEmbedders.length, (index) => index + 1).reversed,
      );
    }

    return rankings;
  }

  // Calculate global ranking across all benchmarks
  List<(String, int)> calculateGlobalRanking({
    String metricName = 'loss',
  }) {
    final benchmarkRankings = calculateBenchmarkRankings(metricName);

    // Collect all rankings for each model
    final allRankings = <String, List<int>>{};

    for (final rankingEntry in benchmarkRankings.entries) {
      for (final modelRanking in rankingEntry.value.entries) {
        allRankings.putIfAbsent(modelRanking.key, () => []).add(modelRanking.value);
      }
    }

    final globalScores = allRankings
        .map((model, rankings) => MapEntry(model, rankings.reduce((a, b) => a + b)) // / rankings.length for average
            );

    // Sort by average ranking
    final sortedGlobalScores = globalScores.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

    return sortedGlobalScores.map((e) => (e.key, e.value)).toList().reversed.toList();
  }

  Map<String, Set<BiocentralMLMetric>> getMetricsForBenchmark(BenchmarkDataset benchmark) {
    final relevantEntries = getEntriesForBenchmark(benchmark);

    return Map.fromEntries(
      relevantEntries.map((entry) => MapEntry(
        entry.model.embedderName ?? 'Unknown',
        entry.model.biotrainerTrainingResult?.testSetMetrics ?? {},
      )),
    );
  }
}
