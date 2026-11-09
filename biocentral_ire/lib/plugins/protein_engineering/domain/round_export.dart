import 'package:biocentral/plugins/protein_engineering/domain/csv_utils.dart';
import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';

/// Exports suggestions with a blank measured-value column for experimental results.
String roundCandidatesToCsv(EngineeringRound round) {
  final suggestionSet = round.result.suggestions.toSet();
  final suggestions = round.result.results.where((r) => suggestionSet.contains(r.entityId)).toList();

  final buffer = StringBuffer('variant,sequence,predicted,uncertainty,score,measured\n');
  for (final result in suggestions) {
    String variant = result.entityId;
    String sequence = '';
    try {
      final substitutions = parseMutationDescriptor(result.entityId);
      variant = formatSubstitutions(substitutions);
      sequence = applySubstitutions(round.parentSequence, substitutions) ?? '';
    } on UnresolvableVariantException {
      // Keep the raw entity_id as the variant label; sequence stays blank.
    }
    buffer.writeln(
      encodeCsvRecord([
        variant,
        sequence,
        result.prediction,
        result.uncertainty.toString(),
        result.score.toString(),
        '',
      ]),
    );
  }
  return buffer.toString();
}
