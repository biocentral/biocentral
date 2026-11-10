import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/domain/sequence_validation.dart';
import 'package:biocentral_api/biocentral_api.dart';

/// Explains an unusable response, or returns null when every variant can be resolved.
///
/// Variant identifiers must describe substitutions against the submitted parent.
/// Opaque identifiers cannot safely be converted to scientific sequences.
String? engineeringResponseIssue(
  ActiveLearningIterationResult result, {
  required String parentSequence,
  required int iteration,
}) {
  if (result.iteration != iteration) return 'The response belongs to a different round.';
  if (result.results.isEmpty) return 'The server returned no candidate predictions.';
  if (result.suggestions.isEmpty) return 'The server returned no suggested variants.';
  final identifiers = <String>{};
  for (final prediction in result.results) {
    final identifier = prediction.entityId;
    if (!identifiers.add(identifier)) return 'The server returned duplicate variant ID "$identifier".';
    try {
      final substitutions = parseMutationDescriptor(identifier);
      final sequence = applySubstitutions(parentSequence, substitutions);
      if (sequence == null || sequence == parentSequence || findInvalidResidueIndex(sequence) != null) {
        return 'Variant "$identifier" does not describe a valid mutation of the submitted parent sequence.';
      }
    } on UnresolvableVariantException {
      return 'Variant ID "$identifier" is not a mutation descriptor such as A12V. '
          'Use a backend that returns parent-relative mutation descriptors.';
    }
  }
  final suggested = <String>{};
  for (final identifier in result.suggestions) {
    if (!identifiers.contains(identifier)) return 'Suggested variant "$identifier" has no corresponding prediction.';
    if (!suggested.add(identifier)) return 'The server suggested variant "$identifier" more than once.';
  }
  return null;
}
