import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';

/// A resolved candidate and the predictions produced for it by one round.
class EngineeringCandidate {
  final MeasuredVariant variant;
  final String? prediction;
  final num? uncertainty;
  final num? score;
  final bool suggested;

  const EngineeringCandidate({
    required this.variant,
    this.prediction,
    this.uncertainty,
    this.score,
    this.suggested = false,
  });
}

/// Resolves round-relative mutation identifiers without changing applied measurements.
///
/// A null [round] combines all rounds and includes measurements entered at setup.
List<EngineeringCandidate> engineeringCandidates(EngineeringCampaign campaign, {EngineeringRound? round}) {
  final candidates = <String, EngineeringCandidate>{};
  for (final current in round == null ? campaign.rounds : [round]) {
    final suggestions = current.result.suggestions.toSet();
    for (final result in current.result.results) {
      try {
        final substitutions = parseMutationDescriptor(result.entityId);
        final sequence = applySubstitutions(current.parentSequence, substitutions);
        if (sequence == null) continue;
        candidates[sequence] = EngineeringCandidate(
          variant: MeasuredVariant(
            seqId: result.entityId,
            sequence: sequence,
            parentSequence: current.parentSequence,
            substitutions: substitutions,
            roundFound: current.sentConfig.iteration,
          ),
          prediction: result.prediction,
          uncertainty: result.uncertainty,
          score: result.score,
          suggested: suggestions.contains(result.entityId),
        );
      } on UnresolvableVariantException {
        // A prediction without a resolvable sequence cannot be measured or highlighted.
        continue;
      }
    }
  }
  if (round == null) {
    for (final measurement in campaign.measurements.values) {
      candidates.putIfAbsent(measurement.sequence, () => EngineeringCandidate(variant: measurement));
    }
  }
  return List.unmodifiable(candidates.values);
}
