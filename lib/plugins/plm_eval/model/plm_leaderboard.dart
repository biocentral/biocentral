import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/sdk/model/biocentral_ml_metrics.dart';
import 'package:ranking_system/ranking_system.dart';

enum PLMLeaderboardKind { remote, local, mixed }

class PLMLeaderboard {
  final Ranking? ranking;
  final List<PLMEvalPersistentResult> _results;

  const PLMLeaderboard._(this.ranking, this._results);

  const PLMLeaderboard.empty()
      : ranking = null,
        _results = const [];

  factory PLMLeaderboard.fromResults(List<PLMEvalPersistentResult> results, recommendedMetrics) {
    final ranking = Ranking.calculate(
      entries: _convertToLeaderboardEntries(results, recommendedMetrics),
      groups: _getRankingGroups(),
      isAscendingMetric: BiocentralMLMetric.isAscending,
    );

    return PLMLeaderboard._(ranking, results);
  }

  factory PLMLeaderboard.mixed(
      {required PLMLeaderboard remote,
      required PLMLeaderboard local,
      required Map<String, String> recommendedMetrics}) {
    final allResults = List<PLMEvalPersistentResult>.from(remote._results)..addAll(local._results);
    final Map<String, PLMEvalPersistentResult> mergedResults = {};
    for (final result in allResults) {
      // TODO Check for consistency
      mergedResults[result.embedderName] = result;
    }
    return PLMLeaderboard.fromResults(mergedResults.values.toList(), recommendedMetrics);
  }

  static List<RankingEntry> _convertToLeaderboardEntries(
      List<PLMEvalPersistentResult> persistentResults, Map<String, String> recommendedMetrics) {
    return persistentResults
        .map(
          (result) => RankingEntry(
            name: result.embedderName,
            metrics: result.results.map(
              (taskName, modelResult) => MapEntry(taskName, modelResult.defaultTestResult!.metrics.first),
            ),
          ),
        )
        .toList();
  }

  static List<RankingGroup> _getRankingGroups() {
    return [
      RankingGroup(
        name: 'PathogenRelatedFitness',
        groupFunction: (categories) =>
            categories.where((category) => category.contains('aav') || category.contains('gb1')).toSet(),
      ),
    ];
  }
}
