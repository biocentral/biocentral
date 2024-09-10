import 'package:bio_flutter/bio_flutter.dart';
import 'package:flutter/foundation.dart';

import 'ppi_repository.dart';

enum PPIRepositoryProperty { unique, duplicates, hviDataset, mixedDataset }

extension CalculateInteractionRepositoryProperties on PPIRepository {
  Future<List<PPIRepositoryProperty>> calculateProperties() async {
    List<ProteinProteinInteraction> interactions = databaseToList();
    if (interactions.isEmpty) {
      return [];
    }

    List<PPIRepositoryProperty> result = [];
    PPIRepositoryProperty unique = await compute(_calculateUnique, interactions);
    result.add(unique);

    PPIRepositoryProperty taxonomy = await compute(calculateTaxonomyProperty, interactions);
    result.add(taxonomy);

    return result;
  }

  Future<PPIRepositoryProperty> _calculateUnique(List<ProteinProteinInteraction> interactions) async {
    /// Calculates if the given interactions are unique, i.e. all interaction
    /// ids are unique in both ways (no flipped duplicates) or if there are duplicates

    Map<String, int> ids = {};
    for (ProteinProteinInteraction interaction in interactions) {
      String interactionID = interaction.getID();
      String interactionIDFlipped = ProteinProteinInteraction.flipInteractionID(interactionID);
      ids.update(
        interactionID,
        (value) => ++value,
        ifAbsent: () => 1,
      );
      ids.update(
        interactionIDFlipped,
        (value) => ++value,
        ifAbsent: () => 1,
      );
    }
    for (int value in ids.values) {
      if (value > 1) {
        return PPIRepositoryProperty.duplicates;
      }
    }
    return PPIRepositoryProperty.unique;
  }

  Future<PPIRepositoryProperty> calculateTaxonomyProperty(List<ProteinProteinInteraction> interactions) async {
    /// Calculates if the given interactions are only human-virus interactions, i.e. all interactions
    /// are either human-virus or virus-human

    for (ProteinProteinInteraction interaction in interactions) {
      bool interactor1Human = interaction.interactor1.taxonomy.isHuman();
      bool interactor2Viral = interaction.interactor2.taxonomy.isViral();
      bool interactor1Viral = interaction.interactor1.taxonomy.isViral();
      bool interactor2Human = interaction.interactor2.taxonomy.isHuman();
      if (!(interactor1Human && interactor2Viral || interactor1Viral && interactor2Human)) {
        return PPIRepositoryProperty.mixedDataset;
      }
    }
    return PPIRepositoryProperty.hviDataset;
  }

  Future<bool> containsNegativeInteractions(List<ProteinProteinInteraction> interactions) async {
    for (ProteinProteinInteraction interaction in interactions) {
      if (!interaction.interacting) {
        return true;
      }
    }
    return false;
  }

  Future<bool> containsPositiveInteractions(List<ProteinProteinInteraction> interactions) async {
    for (ProteinProteinInteraction interaction in interactions) {
      if (interaction.interacting) {
        return true;
      }
    }
    return false;
  }
}
