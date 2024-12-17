import 'package:biocentral/plugins/plm_eval/data/plm_leaderboard_dto.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
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

  final Map<String, String> recommendedMetrics;

  const PLMLeaderboard._({required this.entries, required this.ranking, required this.recommendedMetrics});

  const PLMLeaderboard.empty()
      : entries = const [],
        ranking = const [],
        recommendedMetrics = const {};

  static Either<BiocentralParsingException, PLMLeaderboard> fromDTO(BiocentralDTO fullDTO) {
    final List<PLMLeaderboardEntry> parsedEntries = [];

    final recommendedMetrics = fullDTO.recommendedMetrics;

    if (recommendedMetrics.isEmpty) {
      // TODO Throw exception
    }

    final sortedRanking = fullDTO.ranking.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value));
    final sortedRankingTuples = List<(String, double)>.from(sortedRanking.map((entry) => (entry.key, entry.value)));

    if (sortedRankingTuples.isEmpty) {
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
    return right(
        PLMLeaderboard._(entries: parsedEntries, ranking: sortedRankingTuples, recommendedMetrics: recommendedMetrics));
  }

  String getRecommendedMetricByDataset(BenchmarkDataset dataset) {
    return recommendedMetrics[dataset.datasetName] ?? 'loss';
  }

  // Get all unique dataset-split combinations
  Set<BenchmarkDataset> get benchmarkDatasets => entries.map((e) => e.benchmarkDataset).toSet();

  // Get entries for a specific benchmark dataset
  List<PLMLeaderboardEntry> getEntriesForBenchmark(BenchmarkDataset benchmark) {
    return entries.where((e) => e.benchmarkDataset == benchmark).toList();
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
