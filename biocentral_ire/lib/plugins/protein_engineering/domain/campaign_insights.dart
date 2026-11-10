import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral_api/biocentral_api.dart';

bool _maximizes(EngineeringCampaign campaign) =>
    campaign.config.optimizationMode == ActiveLearningOptimizationMode.MAXIMIZE;

/// The best-measured, expressed variant so far, or null if nothing has been measured.
MeasuredVariant? bestMeasuredVariant(EngineeringCampaign campaign) {
  final measured = campaign.measurements.values.where((variant) => variant.fitness != null).toList();
  if (measured.isEmpty) {
    return null;
  }
  final maximize = _maximizes(campaign);
  measured.sort((a, b) => maximize ? b.fitness!.compareTo(a.fitness!) : a.fitness!.compareTo(b.fitness!));
  return measured.first;
}

/// The best variant's improvement over the wildtype, or null if either is unknown.
double? bestOverWildtype(EngineeringCampaign campaign) {
  final best = bestMeasuredVariant(campaign);
  final wildtypeFitness = campaign.wildtypeFitness;
  if (best == null || wildtypeFitness == null) {
    return null;
  }
  return best.fitness! - wildtypeFitness;
}

/// The best measured value after each round, in round order. Only rounds with a measured
/// improvement are included, so the series may be shorter than the round count.
List<(int round, double value)> bestPerRound(EngineeringCampaign campaign) {
  final maximize = _maximizes(campaign);
  final maxRound = campaign.rounds.fold<int>(
    0,
    (max, round) => round.sentConfig.iteration > max ? round.sentConfig.iteration : max,
  );
  final series = <(int, double)>[];
  double? best;
  for (var round = 0; round <= maxRound; round++) {
    for (final variant in campaign.measurements.values.where((v) => v.roundFound == round && v.fitness != null)) {
      if (best == null || (maximize ? variant.fitness! > best : variant.fitness! < best)) {
        best = variant.fitness;
      }
    }
    if (best != null) {
      series.add((round, best));
    }
  }
  return series;
}

/// Measured minus predicted value for every variant of [round] that has been measured since.
/// Positive means the model underestimated the variant.
List<double> predictionErrors(EngineeringCampaign campaign, EngineeringRound round) {
  final errors = <double>[];
  for (final result in round.result.results) {
    final predicted = double.tryParse(result.prediction);
    if (predicted == null || !predicted.isFinite) {
      continue;
    }
    String? sequence;
    try {
      sequence = applySubstitutions(round.parentSequence, parseMutationDescriptor(result.entityId));
    } on UnresolvableVariantException {
      continue;
    }
    final measured = sequence != null ? campaign.measurements[sequence] : null;
    if (measured == null || measured.fitness == null) {
      continue;
    }
    errors.add(measured.fitness! - predicted);
  }
  return errors;
}

/// Five-number summary of a set of values, for box plots.
class BoxSummary {
  final double min;
  final double q1;
  final double median;
  final double q3;
  final double max;
  final int count;

  const BoxSummary({
    required this.min,
    required this.q1,
    required this.median,
    required this.q3,
    required this.max,
    required this.count,
  });

  /// Quartiles use linear interpolation between the closest ranks. [values] must not be empty.
  factory BoxSummary.of(List<double> values) {
    final sorted = [...values]..sort();
    double quantile(double q) {
      final position = (sorted.length - 1) * q;
      final lower = position.floor();
      final upper = position.ceil();
      return sorted[lower] + (sorted[upper] - sorted[lower]) * (position - lower);
    }

    return BoxSummary(
      min: sorted.first,
      q1: quantile(0.25),
      median: quantile(0.5),
      q3: quantile(0.75),
      max: sorted.last,
      count: sorted.length,
    );
  }
}

/// Measured values of the variants found in each round (round 0 = data entered at setup), not
/// cumulative. Variants that did not express are left out.
List<(int round, BoxSummary summary)> measuredValuesPerRound(EngineeringCampaign campaign) {
  final byRound = <int, List<double>>{};
  for (final variant in campaign.measurements.values) {
    final fitness = variant.fitness;
    if (fitness != null) {
      byRound.putIfAbsent(variant.roundFound, () => []).add(fitness);
    }
  }
  final rounds = byRound.keys.toList()..sort();
  return [for (final round in rounds) (round, BoxSummary.of(byRound[round]!))];
}

/// Prediction errors summarized per round, in round order. Rounds without measured
/// suggestions are left out.
List<(int round, BoxSummary summary)> predictionErrorsPerRound(EngineeringCampaign campaign) {
  final rounds = [...campaign.rounds]..sort((a, b) => a.sentConfig.iteration.compareTo(b.sentConfig.iteration));
  return [
    for (final round in rounds)
      if (predictionErrors(campaign, round) case final errors when errors.isNotEmpty)
        (round.sentConfig.iteration, BoxSummary.of(errors)),
  ];
}
