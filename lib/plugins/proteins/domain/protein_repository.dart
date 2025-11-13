import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:crypto/crypto.dart';

class ProteinRepository extends BiocentralDatabase<Protein> {
  final Map<String, Protein> _proteins = {};
  final Map<String, Set<String>> _sequenceHashToIDs = {};

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
    _sequenceHashToIDs.putIfAbsent(calculateSequenceHash(p1.sequence.seq), () => {p1.id});
    _sequenceHashToIDs.putIfAbsent(calculateSequenceHash(p2.sequence.seq), () => {p2.id});
    _sequenceHashToIDs.putIfAbsent(calculateSequenceHash(p3.sequence.seq), () => {p3.id});
    _sequenceHashToIDs.putIfAbsent(calculateSequenceHash(p4.sequence.seq), () => {p4.id});
  }

  /// Matches biotrainer sequence hash calculation
  /// TODO Move to bio_flutter
  static String calculateSequenceHash(String sequence) {
    final suffix = sequence.length;
    final sequenceWithSuffix = '${sequence}_$suffix';
    final bytes = utf8.encode(sequenceWithSuffix);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  String getEntityTypeName() {
    return 'Protein';
  }

  @override
  void addEntityImpl(Protein entity) {
    _proteins[entity.id] = entity;
    final seqHash = calculateSequenceHash(entity.sequence.seq);
    _sequenceHashToIDs.putIfAbsent(seqHash, () => {});
    _sequenceHashToIDs[seqHash]?.add(entity.id);
  }

  @override
  void addAllEntitiesImpl(Iterable<Protein> entities) {
    final entityMap = Map.fromEntries(entities.map((entity) => MapEntry(entity.getID(), entity)));
    _proteins.addAll(entityMap);
    for (final entity in entities) {
      final seqHash = calculateSequenceHash(entity.sequence.seq);
      _sequenceHashToIDs.putIfAbsent(seqHash, () => {});
      _sequenceHashToIDs[seqHash]?.add(entity.id);
    }
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
      final oldEntity = getEntityById(id)!;
      _proteins[id] = entityUpdated;
      final oldSeqHash = calculateSequenceHash(oldEntity.sequence.seq);
      final seqHash = calculateSequenceHash(entityUpdated.sequence.seq);

      _sequenceHashToIDs[oldSeqHash]?.remove(oldEntity.id);
      _sequenceHashToIDs[seqHash]?.add(entityUpdated.id);
    } else {
      addEntity(entityUpdated);
    }
  }

  @override
  void clearDatabaseImpl() {
    _proteins.clear();
    _sequenceHashToIDs.clear();
  }

  @override
  Map<String, String>? getSequences() {
    final result = <String, String>{};
    for (final (id, protein) in _proteins.entriesRecord) {
      result[id] = protein.sequence.seq;
    }
    return result;
  }

  @override
  List<SequenceTrainingData> getTrainingData(
      {required String targetColumn, required String setColumn, String? maskColumn}) {
    final result = <SequenceTrainingData>[];
    for (final protein in databaseToList()) {
      final trainingData = SequenceTrainingData((b) =>
      b
        ..seqId = protein.id
        ..sequence = protein.sequence.seq
        ..label = protein.attributes[targetColumn]
        ..set_ = protein.attributes[setColumn]
        ..mask = protein.attributes[maskColumn],
      );
      result.add(trainingData);
    }
    return result;
  }


  @override
  Set<String> getSystemColumns() {
    // Define system columns that should be excluded from training
    return {'id', 'sequence', 'taxonomyID', 'embeddings'};
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
    if (entities.isEmpty) {
      return;
    }

    if (entities.entries.first.value is Protein) {
      importEntities(entities.map((id, entity) => MapEntry(id, entity as Protein)), importMode);
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

    for (final (seqHash, embedding) in newEmbeddings.entriesRecord) {
      final proteinIDs = _sequenceHashToIDs[seqHash] ?? {};
      if (proteinIDs.isNotEmpty) {
        for (final proteinID in proteinIDs) {
          final protein = getEntityById(proteinID);
          _proteins[proteinID] = protein!.copyWith(embeddings: protein.embeddings.addEmbedding(embedding: embedding));
        }
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
