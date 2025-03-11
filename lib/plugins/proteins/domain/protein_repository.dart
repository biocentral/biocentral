import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class ProteinRepository extends BiocentralDatabase<Protein> {

  final Map<String, Protein> _proteins = {};

  ProteinRepository(super.biocentralProjectRepository) : super() {
    // EXAMPLE DATA
    final Protein p1 = Protein('Example1', sequence: AminoAcidSequence('MATGGRRGAA'));
    final Protein p2 = Protein('Example2', sequence: AminoAcidSequence('MAGGRGAA'));
    final Protein p3 = Protein('Example3', sequence: AminoAcidSequence('MATGGRRGAATTTTTT'));
    final Protein p4 = Protein('Example4', sequence: AminoAcidSequence('MAGGRGAAMMMMMMAAAAGGGG'));
    _proteins[p1.id] = p1;
    _proteins[p2.id] = p2;
    _proteins[p3.id] = p3;
    _proteins[p4.id] = p4;
  }

  @override
  String getEntityTypeName() {
    return 'Protein';
  }

  @override
  void addEntityImpl(Protein entity) {
    _proteins[entity.id] = entity;
  }

  @override
  void addAllEntitiesImpl(Iterable<Protein> entities) {
    final entityMap = Map.fromEntries(entities.map((entity) => MapEntry(entity.getID(), entity)));
    _proteins.addAll(entityMap);
  }

  @override
  void removeEntityImpl(Protein? entity) {
    if (entity != null) {
      final String interactionID = entity.getID();
      _proteins.remove(interactionID);
    }
  }

  @override
  void updateEntityImpl(String id, Protein entityUpdated) {
    if (containsEntity(id)) {
      _proteins[id] = entityUpdated;
    } else {
      addEntity(entityUpdated);
    }
  }

  @override
  void clearDatabaseImpl() {
    _proteins.clear();
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
    if (rowIndex >= _proteins.length) {
      return null;
    }
    return _proteins.values.toList()[rowIndex];
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
  void syncFromDatabase(Map<String, BioEntity> entities, DatabaseImportMode importMode) async {
    if(entities.isEmpty) {
      return;
    }

    if (entities.entries.first.value is Protein) {
      importEntities(entities as Map<String, Protein>, importMode);
    } else if (entities.entries.first.value is ProteinProteinInteraction) {
      clearDatabase();
      for (BioEntity entity in entities.values) {
        final Protein interactor1 = (entity as ProteinProteinInteraction).interactor1;
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

  Future<Map<String, Protein>> addTaxonomyData(Map<int, Taxonomy> taxonomyData) async {
    for (MapEntry<String, Protein> proteinEntry in _proteins.entries) {
      if (taxonomyData.keys.contains(proteinEntry.value.taxonomy.id)) {
        final updatedEntry = proteinEntry.value.copyWith(taxonomy: taxonomyData[proteinEntry.value.taxonomy.id]);
        updateEntity(proteinEntry.key, updatedEntry);
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

    for (MapEntry<String, Embedding> proteinIDToEmbedding in newEmbeddings.entries) {
      final Protein? protein = _proteins[proteinIDToEmbedding.key];
      if (protein != null) {
        _proteins[proteinIDToEmbedding.key] =
            protein.copyWith(embeddings: protein.embeddings.addEmbedding(embedding: proteinIDToEmbedding.value));
      } else {
        numberUnknownProteins++;
      }
    }

    if (numberUnknownProteins > 0) {
      logger.w('Number unknown proteins from embeddings: $numberUnknownProteins');
    }
    return Map.from(_proteins);
  }
}
/*
  void handleGridChangedEvent(PlutoGridOnChangedEvent event) {
    int columnIndex = event.columnIdx;
    int rowIndex = event.rowIdx;
    if (event.value != event.oldValue) {
      if (isNewlyAddedRow(columnIndex, rowIndex)) {
        addProtein(Protein(event.value));
      } else {
        _updateProteinFromPlutoGrid(columnIndex, rowIndex, event.value);
      }
    }
  }
    bool isNewlyAddedRow(int columnIndex, int rowIndex) {
    return rowIndex > (_proteins.length - 1) && columnIndex == 0;
  }
    void _updateProteinFromPlutoGrid(int columnIndex, int rowIndex, String value) {
    String proteinToChangeID = _proteinIDs[rowIndex];
    Protein toChange = _proteins[proteinToChangeID]!;
    _proteins[proteinToChangeID] = _copyProteinByColumnIndex(toChange, columnIndex, value);
  }

  Protein _copyProteinByColumnIndex(Protein toChange, int columnIndex, String value) {
    Map<String, String> newAttributes = Map.from(toChange.attributes.toMap());
    switch (columnIndex) {
      case 0:
        return toChange.copyWith(id: value);
      case 1:
        return toChange.copyWith(sequence: AminoAcidSequence(value));
      case 2:
        newAttributes["TARGET"] = value;
        return toChange.copyWith(attributes: newAttributes);
      case 3:
        newAttributes["SET"] = value;
        return toChange.copyWith(attributes: newAttributes);
    }
    return toChange;
  }
  */
