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

  // List<String> getTrainableColumnNames() {
  //   var columnNames = getColumnNames();
  //   return columnNames
  //       .where((column) {
  //         return _proteins.values.any((protein) {
  //           return protein.attributes.toMap()[column] == null ||
  //               protein.attributes.toMap()[column] == "Unknown";
  //         });
  //       })
  //       .where((column) =>
  //           column != "id" && column != "taxonomyID" && column != "embeddings")
  //       .toList();
  // }

  bool _isNumeric(String value) {
    return num.tryParse(value) != null;
  }

  bool _isBoolean(String value) {
    value = value.toLowerCase();
    return value == "true" || value == "false" || value == "1" || value == "0";
  }

  Map<String, String> getColumnDatatypesMap() {
    if (_proteins.isEmpty) return {};

    final Map<String, String> datatypes = {};
    final columnNames = getColumnNames();

    // First pass: initialize with most restrictive type possible
    for (var column in columnNames) {
      if (column == "id" ||
          column == "sequence" ||
          column == "taxonomyID" ||
          column == "embeddings") {
        datatypes[column] = "other";
        continue;
      }

      datatypes[column] = "numeric"; // Start with most restrictive
    }

    // Second pass: downgrade types as needed based on actual values
    for (var protein in _proteins.values) {
      final attributes = protein.attributes.toMap();

      for (var column in columnNames) {
        if (datatypes[column] == "other") continue;

        final value = attributes[column]?.toString();
        if (value == null || value == "Unknown") continue;

        if (datatypes[column] == "numeric" && !_isNumeric(value)) {
          datatypes[column] = _isBoolean(value) ? "boolean" : "other";
        } else if (datatypes[column] == "boolean" && !_isBoolean(value)) {
          datatypes[column] = "other";
        }
      }
    }

    return datatypes;
  }

  List<String> getTrainableColumnNames(
      [bool? booleanTypes, bool? numericTypes]) {
    var columnNames = getColumnNames();
    final datatypes = getColumnDatatypesMap();

    return columnNames.where((column) {
      // Check if column has any null or Unknown values (trainable)
      bool isTrainable = _proteins.values.any((protein) {
        return protein.attributes.toMap()[column] == null ||
            protein.attributes.toMap()[column] == "Unknown";
      });

      // Skip non-trainable columns
      if (!isTrainable) return false;

      // Skip system columns
      if (column == "id" || column == "taxonomyID" || column == "embeddings")
        return false;

      // If no type filters specified, include all trainable columns
      if (booleanTypes == null && numericTypes == null) return true;

      // Apply type filters
      String type = datatypes[column] ?? "other";
      if (booleanTypes == true && type == "boolean") return true;
      if (numericTypes == true && type == "numeric") return true;

      // If both filters are false, return false
      if (booleanTypes == false && numericTypes == false) return false;

      // If one filter is true and the other is null, only return that type
      if (booleanTypes == true && numericTypes == null)
        return type == "boolean";
      if (numericTypes == true && booleanTypes == null)
        return type == "numeric";

      return false;
    }).toList();
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
