import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

import 'package:biocentral/plugins/ppi/domain/ppi_repository.dart';
import 'package:biocentral/plugins/ppi/domain/ppi_repository_properties.dart';

class PPIDatabaseTest {
  final String name;
  final PPIDatabaseTestType type;
  final List<PPIDatabaseTestRequirement> requirements;
  BiocentralTestResult? testResult;

  PPIDatabaseTest({required this.name, required this.type, required this.requirements, this.testResult});

  Future<PPIDatabaseTestRequirement?> canBeExecuted(PPIRepository ppiRepository) async {
    /// Returns null if all requirements are met
    /// If a requirement is not met, this requirement is returned
    final List<ProteinProteinInteraction> interactions = ppiRepository.databaseToList();
    for (PPIDatabaseTestRequirement requirement in requirements) {
      final bool requirementMet = switch (requirement) {
        PPIDatabaseTestRequirement.sequences => !(ppiRepository.hasMissingSequences()),
        PPIDatabaseTestRequirement.containsPositivesAndNegatives =>
          await ppiRepository.containsNegativeInteractions(interactions) &&
              await ppiRepository.containsPositiveInteractions(interactions),
        PPIDatabaseTestRequirement.containsOnlyHVI =>
          await ppiRepository.calculateTaxonomyProperty(interactions) == PPIRepositoryProperty.hviDataset,
        PPIDatabaseTestRequirement.none => true
      };
      if (!requirementMet) {
        return requirement;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PPIDatabaseTest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          requirements == other.requirements;

  @override
  int get hashCode => name.hashCode ^ type.hashCode ^ requirements.hashCode;
}

enum PPIDatabaseTestType {
  binary,
  metrics;
}

enum PPIDatabaseTestRequirement {
  sequences,
  containsPositivesAndNegatives,
  containsOnlyHVI,
  none;
}
