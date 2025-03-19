import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class ProteinRepository extends BiocentralDatabase<Protein> {
  final Map<String, Protein> _proteins = {};
  final List<String> _proteinIDs = [];

  ProteinRepository() {
    // EXAMPLE DATA
    final Protein p1 =
        Protein('P06213', sequence: AminoAcidSequence('MATGGRRGAA'));
    final Protein p2 =
        Protein('P11111', sequence: AminoAcidSequence('MAGGRGAA'));
    final Protein p3 =
        Protein('P22222', sequence: AminoAcidSequence('MATGGRRGAATTTTTT'));
    final Protein p4 = Protein('P33333',
        sequence: AminoAcidSequence('MAGGRGAAMMMMMMAAAAGGGG'));
    addEntity(p1);
    addEntity(p2);
    addEntity(p3);
    addEntity(p4);
  }

  @override
  String getEntityTypeName() {
    return 'Protein';
  }

  @override
  Set<String> getSystemColumns() {
    // Define system columns that should be excluded from training
    return {"id", "sequence", "taxonomyID", "embeddings"};
  }

  @override
  void addEntity(Protein entity) {
    _proteins[entity.id] = entity;
    _proteinIDs.add(entity.id);
  }

  @override
  void removeEntity(Protein? entity) {
    if (entity != null) {
      final String interactionID = entity.getID();
      _proteins.remove(interactionID);
      _proteinIDs.remove(interactionID);
    }
  }

  @override
  void updateEntity(String id, Protein entityUpdated) {
    if (containsEntity(id)) {
      _proteins[id] = entityUpdated;
    } else {
      addEntity(entityUpdated);
    }
  }

  @override
  void clearDatabase() {
    _proteins.clear();
    _proteinIDs.clear();
  }

  @override
  bool containsEntity(String id) {
    return _proteins.containsKey(id);
  }

  @override
  Protein? getEntityById(String id) {
    return _proteins[id];
  }

  @override
  Protein? getEntityByRow(int rowIndex) {
    if (rowIndex >= _proteinIDs.length) {
      return null;
    }
    return _proteins[_proteinIDs[rowIndex]];
  }

  @override
  List<Protein> databaseToList() {
    return List.from(_proteins.values);
  }

  @override
  Map<String, Protein> databaseToMap() {
    return Map.from(_proteins);
  }

  @override
  List<Map<String, dynamic>> entitiesAsMaps() {
    return _proteins.values.map((protein) => protein.toMap()).toList();
  }

  @override
  void syncFromDatabase(
      Map<String, BioEntity> entities, DatabaseImportMode importMode) async {
    if (entities.entries.first.value is Protein) {
      importEntities(entities as Map<String, Protein>, importMode);
    }
    if (entities.entries.first.value is ProteinProteinInteraction) {
      clearDatabase();
      for (BioEntity entity in entities.values) {
        final Protein interactor1 =
            (entity as ProteinProteinInteraction).interactor1;
        final Protein interactor2 = entity.interactor2;

        updateEntity(interactor1.getID(), interactor1);
        updateEntity(interactor2.getID(), interactor2);
      }
    }
  }

  // *** SEQUENCES ***

  bool hasMissingSequences() {
    for (Protein protein in _proteins.values) {
      if (protein.sequence.isEmpty()) {
        return true;
      }
    }
    return false;
  }

  // ** TAXONOMY ***

  Future<Map<String, Protein>> addTaxonomyData(
      Map<int, Taxonomy> taxonomyData) async {
    for (MapEntry<String, Protein> proteinEntry in _proteins.entries) {
      if (taxonomyData.keys.contains(proteinEntry.value.taxonomy.id)) {
        _proteins[proteinEntry.key] = proteinEntry.value
            .copyWith(taxonomy: taxonomyData[proteinEntry.value.taxonomy.id]);
      }
    }
    return Map.from(_proteins);
  }

  Set<int> getTaxonomyIDs() {
    final Set<int> taxonomyIDs = {};
    for (Protein protein in _proteins.values) {
      if (!protein.taxonomy.isUnknown()) {
        taxonomyIDs.add(protein.taxonomy.id);
      }
    }
    return taxonomyIDs;
  }

  // *** EMBEDDINGS ***

  @override
  Map<String, Protein> updateEmbeddings(Map<String, Embedding> newEmbeddings) {
    // TODO IMPORT MODE
    int numberUnknownProteins = 0;

    for (MapEntry<String, Embedding> proteinIDToEmbedding
        in newEmbeddings.entries) {
      final Protein? protein = _proteins[proteinIDToEmbedding.key];
      if (protein != null) {
        _proteins[proteinIDToEmbedding.key] = protein.copyWith(
            embeddings: protein.embeddings
                .addEmbedding(embedding: proteinIDToEmbedding.value));
      } else {
        numberUnknownProteins++;
      }
    }

    if (numberUnknownProteins > 0) {
      logger
          .w('Number unknown proteins from embeddings: $numberUnknownProteins');
    }
    return Map.from(_proteins);
  }

  List<String> getColumnNames() {
    if (_proteins.isEmpty) return [];
    return _proteins.values.first.toMap().keys.toList();
  }
}
