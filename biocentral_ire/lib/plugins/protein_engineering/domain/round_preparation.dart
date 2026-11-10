import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/domain/sequence_validation.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:built_collection/built_collection.dart';

/// Prepares measured training data and parameters for backend mutant generation.
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
      ..nSuggestions = nSuggestions,
  );
}
