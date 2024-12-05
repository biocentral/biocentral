import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:collection/collection.dart';

/// Helper class to combine PredictionModel with dataset-specific information
class LeaderboardEntry {
  final PredictionModel model;
  final BenchmarkDataset benchmarkDataset;
  final DateTime? trainingDate;

  const LeaderboardEntry({
    required this.model,
    required this.benchmarkDataset,
    this.trainingDate,
  });
}

class Leaderboard {
  final List<LeaderboardEntry> entries;

  const Leaderboard._({required this.entries});

  const Leaderboard.empty() : entries = const [];

  // Factory constructor to create from CSV string
  factory Leaderboard.fromCsvString(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) {
      return const Leaderboard.empty();
    }

    // Parse header
    final headers = lines[0].split(',');

    final entries = <LeaderboardEntry>[];

    // Parse data rows
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;

      final values = lines[i].split(',');
      if (values.length != headers.length) continue;

      final row = Map<String, String>.fromIterables(headers, values);

      try {
        // Create base prediction model from row data
        final modelData = {
          'embedder_name': row['model_name'],
          'protocol': row['protocol'],
          'biotrainer_version': row['biotrainer_version'],
        };

        final predictionModel = PredictionModel.fromMap(modelData);
        if (predictionModel == null) continue;

        // Parse metrics
        final metrics = <BiocentralMLMetric>{};
        row.forEach((key, value) {
          if (!['model_name', 'dataset_name', 'split_name', 'biotrainer_version', 'training_date'].contains(key)) {
            final metric = BiocentralMLMetric.tryParse(key, value);
            if (metric != null) {
              metrics.add(metric);
            }
          }
        });

        // Parse training date
        DateTime? trainingDate;
        if (row['training_date'] != null) {
          try {
            trainingDate = DateTime.parse(row['training_date'] ?? '');
          } catch (e) {
            logger.w('Warning: Invalid date format for ${row['training_date']}');
          }
        }

        // Create training result with metrics
        final trainingResult = BiotrainerTrainingResult(
          trainingLoss: {},
          validationLoss: {},
          testSetMetrics: metrics,
          sanityCheckWarnings: {},
          sanityCheckBaselineMetrics: {},
          trainingLogs: [],
          trainingStatus: BiocentralTaskStatus.finished,
        );

        // Add training result to model
        final modelWithResults = predictionModel.copyWith(
          biotrainerTrainingResult: trainingResult,
        );

        if (row['dataset_name'] == null || row['split_name'] == null) {
          logger.e('Missing dataset_name or split_name from leaderboard row! Skipping entry!');
          continue;
        }

        final benchmarkDataset =
            BenchmarkDataset(datasetName: row['dataset_name'] ?? '', splitName: row['split_name'] ?? '');

        entries.add(
          LeaderboardEntry(
            model: modelWithResults,
            benchmarkDataset: benchmarkDataset,
            trainingDate: trainingDate,
          ),
        );
      } catch (e) {
        logger.e('Error parsing leaderboard row: $e');
        continue;
      }
    }

    return Leaderboard._(entries: entries);
  }

  // Get all unique dataset-split combinations
  Set<BenchmarkDataset> get benchmarkDatasets => entries.map((e) => e.benchmarkDataset).toSet();

  // Get entries for a specific benchmark dataset
  List<LeaderboardEntry> getEntriesForBenchmark(BenchmarkDataset benchmark) {
    return entries.where((e) => e.benchmarkDataset == benchmark).toList();
  }

  // Get all metrics for a specific benchmark dataset
  Map<String, Set<BiocentralMLMetric>> getMetricsForBenchmark(BenchmarkDataset benchmark) {
    final relevantEntries = getEntriesForBenchmark(benchmark);

    return Map.fromEntries(
      relevantEntries.map((entry) => MapEntry(
            entry.model.embedderName ?? 'Unknown',
            entry.model.biotrainerTrainingResult?.testSetMetrics ?? {},
          )),
    );
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

    final globalScores = allRankings.map(
      (model, rankings) => MapEntry(model, rankings.reduce((a, b) => a + b)) // / rankings.length for average
    );

    // Sort by average ranking
    final sortedGlobalScores = globalScores.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

    return sortedGlobalScores.map((e) => (e.key, e.value)).toList().reversed.toList();
  }
}
