import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

import '../model/ppi_database_test.dart';

class PPIRepository extends BiocentralDatabase<ProteinProteinInteraction> {
  final Map<String, ProteinProteinInteraction> _interactions = {};
  final List<String> _interactionIDs = [];

  final List<PPIDatabaseTest> _associatedDatasetTests = [];

  PPIRepository() {
    // EXAMPLE DATA
    Protein p1 = Protein("P06213", sequence: AminoAcidSequence("MATGGRRGAA"));
    Protein p2 = Protein("P11111", sequence: AminoAcidSequence("MAGGRGAA"));
    Protein p3 = Protein("P22222", sequence: AminoAcidSequence("MATGGRRGAATTTTTT"));
    Protein p4 = Protein("P33333", sequence: AminoAcidSequence("MAGGRGAAMMMMMMAAAAGGGG"));
    addEntity(ProteinProteinInteraction(p1, p2, true));
    addEntity(ProteinProteinInteraction(p3, p4, false));
  }

  @override
  String getEntityTypeName() {
    return "ProteinProteinInteraction";
  }

  @override
  void addEntity(ProteinProteinInteraction entity) {
    String interactionID = entity.getID();
    _interactions[interactionID] = entity;
    _interactionIDs.add(interactionID);
  }

  @override
  void removeEntity(ProteinProteinInteraction? entity) {
    if (entity != null) {
      String interactionID = entity.getID();
      _interactions.remove(interactionID);
      _interactionIDs.remove(interactionID);
    }
  }

  @override
  void updateEntity(String id, ProteinProteinInteraction entityUpdated) {
    String flippedID = ProteinProteinInteraction.flipInteractionID(id);
    if (_interactions.containsKey(id)) {
      _interactions[id] = entityUpdated;
    }
    if (_interactions.containsKey(flippedID)) {
      _interactions.remove(flippedID);
      _interactions[id] = entityUpdated;
    }
  }

  @override
  void clearDatabase() {
    _interactions.clear();
    _interactionIDs.clear();
    _associatedDatasetTests.clear();
  }

  @override
  bool containsEntity(String id) {
    String flippedID = ProteinProteinInteraction.flipInteractionID(id);
    return _interactions.containsKey(id) || _interactions.containsKey(flippedID);
  }

  @override
  List<ProteinProteinInteraction> databaseToList() {
    return List.from(_interactions.values);
  }

  @override
  Map<String, ProteinProteinInteraction> databaseToMap() {
    return Map.from(_interactions);
  }

  @override
  List<Map<String, String>> entitiesAsMaps() {
    return _interactions.values.map((interaction) => interaction.toMap()).toList();
  }

  @override
  ProteinProteinInteraction? getEntityById(String id) {
    String flippedID = ProteinProteinInteraction.flipInteractionID(id);
    return _interactions[id] ?? _interactions[flippedID];
  }

  @override
  ProteinProteinInteraction? getEntityByRow(int rowIndex) {
    if (rowIndex >= _interactionIDs.length) {
      return null;
    }
    return _interactions[_interactionIDs[rowIndex]];
  }

  Future<int> removeDuplicates() async {
    Set<String> duplicates = {};
    for (String interactionID in _interactionIDs) {
      String flippedInteractionID = ProteinProteinInteraction.flipInteractionID(interactionID);
      if (_interactions.containsKey(flippedInteractionID) && !duplicates.contains(interactionID)) {
        duplicates.add(flippedInteractionID);
      }
    }
    for (String duplicate in duplicates) {
      _interactions.remove(duplicate);
    }
    _interactionIDs.clear();
    _interactionIDs.addAll(_interactions.keys);

    if (duplicates.isNotEmpty) {
      logger.i("Removed ${duplicates.length} duplicated interactions from interaction database!");
    }
    return duplicates.length;
  }

  /// Updates protein-protein interactions when proteins have been updated
  ///
  /// Interactions that are no longer found because their associated proteins are no longer available are removed
  @override
  void syncFromDatabase(Map<String, BioEntity> entities, DatabaseImportMode importMode) {
    // TODO Improve syncing condition, check for importMode, Future/await?
    if (entities.entries.first.value is Protein) {
      Map<String, ProteinProteinInteraction> alignedInteractions = databaseToMap();
      for (MapEntry<String, ProteinProteinInteraction> interactionEntry in _interactions.entries) {
        String interactor1ID = interactionEntry.value.interactor1.id;
        String interactor2ID = interactionEntry.value.interactor2.id;

        // Both proteins must still be contained in the protein database
        if (entities.containsKey(interactor1ID) && entities.containsKey(interactor2ID)) {
          alignedInteractions[interactionEntry.key] = interactionEntry.value
              .copyWith(interactor1: entities[interactor1ID], interactor2: entities[interactor2ID]);
        } else {
          alignedInteractions.remove(interactionEntry.key);
        }
      }
      _interactions.clear();
      _interactionIDs.clear();
      _interactions.addAll(alignedInteractions);
      _interactionIDs.addAll(alignedInteractions.keys);
    } else if (entities.entries.first.value is ProteinProteinInteraction) {
      importEntities(entities as Map<String, ProteinProteinInteraction>, importMode);
    }
  }

  @override
  Map<String, ProteinProteinInteraction> updateEmbeddings(Map<String, Embedding> newEmbeddings) {
    // TODO Can be ignored at the moment, because embeddings are calculated directly for interactions
    // TODO see (EmbeddingsCombiner)
    return Map.from(_interactions);
  }

  Set<Protein> _getCurrentProteins() {
    return _interactions.values
        .fold({}, (previous, interaction) => previous..addAll([interaction.interactor1, interaction.interactor2]));
  }

  /// Check if proteins have missing sequences
  bool hasMissingSequences() {
    for (Protein protein in _getCurrentProteins()) {
      if (protein.sequence.isEmpty()) {
        return true;
      }
    }
    return false;
  }

  /// Adds a new test if it does not exist yet
  ///
  /// If it does exist, only the test result is updated
  List<PPIDatabaseTest> addFinishedTest(PPIDatabaseTest newTest) {
    bool add = true;
    for (PPIDatabaseTest existingTest in _associatedDatasetTests) {
      if (existingTest == newTest) {
        existingTest.testResult = newTest.testResult;
        add = false;
        break;
      }
    }
    if (add) {
      _associatedDatasetTests.add(newTest);
    }
    return associatedDatasetTests;
  }

  List<PPIDatabaseTest> get associatedDatasetTests => List.from(_associatedDatasetTests);

}
