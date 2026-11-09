import 'dart:math';

import 'package:biocentral/plugins/protein_engineering/domain/amino_acid_restrictions.dart';
import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/domain/sequence_validation.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/sdk/util/seed_util.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:built_collection/built_collection.dart';

/// Resolves a round once, so preview and submission use identical candidates.
ActiveLearningEngineeringIterationConfig prepareEngineeringRound({
  required EngineeringCampaign campaign,
  required String parentSequence,
  required int nSuggestions,
  required double coefficient,
}) {
  if (parentSequence.length != campaign.wildtypeSequence.length || findInvalidResidueIndex(parentSequence) != null) {
    throw const FormatException('Starting sequence must contain standard amino acids and match the wildtype length.');
  }
  if (nSuggestions < 1 || !coefficient.isFinite || coefficient < 0 || coefficient > 1) {
    throw const FormatException('Invalid suggestion count or exploration coefficient.');
  }
  final measured = campaign.measurements.values.where((value) => value.fitness != null).toList();
  if (measured.isEmpty) throw const FormatException('Enter at least one measured fitness before running a round.');
  final candidates = campaign.aminoAcidRestrictions.isEmpty
      ? null
      : campaign.aminoAcidRestrictions.sampleCandidates(
          parentSequence,
          knownSequences: campaign.measurements.keys.toSet(),
          random: Random((campaign.config.seed ?? biocentralDefaultSeed) + campaign.rounds.length),
        );
  if (candidates != null && candidates.isEmpty) {
    throw const FormatException('The applied restrictions leave no variants to suggest.');
  }
  return ActiveLearningEngineeringIterationConfig(
    (builder) => builder
      ..iteration = campaign.rounds.length + 1
      ..baseSequences = ListBuilder([parentSequence])
      ..trainingData = ListBuilder(
        measured.map(
          (value) => SequenceData(
            (builder) => builder
              ..seqId = (wildtypeRelativeDescriptor(campaign.wildtypeSequence, value.sequence) ?? value.seqId)
              ..seq = value.sequence
              ..set_ = 'train'
              ..label = value.fitness.toString(),
          ),
        ),
      )
      ..coefficient = coefficient
      ..nSuggestions = nSuggestions
      ..nMutations = defaultCandidatesPerRound
      ..candidateSequences = candidates == null ? null : ListBuilder(candidates),
  );
}
