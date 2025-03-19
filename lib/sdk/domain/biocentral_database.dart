import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_repository_auto_saver.dart';
import 'package:biocentral/sdk/model/column_wizard_operations.dart';
import 'package:biocentral/sdk/util/logging.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

abstract class BiocentralDatabase<T extends BioEntity> with AutoSaving {
  @override
  late final BiocentralRepositoryAutoSaver autoSaver;

  BiocentralDatabase(BiocentralProjectRepository biocentralProjectRepository) {
    autoSaver = BiocentralRepositoryAutoSaver(
      biocentralProjectRepository: biocentralProjectRepository,
      fileName: '${getEntityTypeName().toLowerCase()}.fasta',
      fileType: T,
      saveFunctionString: () async {
        final String content = await convertToString('fasta');
        return content; // TODO Make file extension customizable
      },
    );
  }

  // *** READ/WRITE/UPDATE ***
  // ** AUTOSAVING **
  void addEntity(T entity) => withAutoSave(() => addEntityImpl(entity));

  void addEntityImpl(T entity);

  void addAllEntities(Iterable<T> entities) => withAutoSave(() => addAllEntitiesImpl(entities));

  void addAllEntitiesImpl(Iterable<T> entities);

  void removeEntity(T? entity) => withAutoSave(() => removeEntityImpl(entity));

  void removeEntityImpl(T? entity);

  void updateEntity(String id, T entityUpdated) => withAutoSave(() => updateEntityImpl(id, entityUpdated));

  void updateEntityImpl(String id, T entityUpdated);

  void clearDatabase() => withAutoSave(() => clearDatabaseImpl());

  void clearDatabaseImpl();

  // ** AUTOSAVING **

  bool containsEntity(String id);

  T? getEntityById(String id);

  T? getEntityByRow(int rowIndex);

  List<T> databaseToList();

  Map<String, T> databaseToMap();

  List<Map<String, dynamic>> entitiesAsMaps();

  String getEntityTypeName();

  void syncFromDatabase(Map<String, BioEntity> entities, DatabaseImportMode importMode);

  Map<String, T> updateEmbeddings(Map<String, Embedding> newEmbeddings);

  /// Returns a set of column names that should be excluded from training and analysis
  /// These are typically system columns like ID, embeddings, etc.
  Set<String> getSystemColumns();

  Map<String, Map<String, dynamic>> getColumns() {
    final List<Map<String, dynamic>> entityMaps = entitiesAsMaps();
    final Map<String, Map<String, dynamic>> result = {};
    for (Map<String, dynamic> entityMap in entityMaps) {
      final String entityID = entityMap['id'] ?? '';
      if (entityID.isEmpty) {
        logger.w('Encountered entity without an ID!');
      }
      for (MapEntry<String, dynamic> entry in entityMap.entries) {
        result.putIfAbsent(entry.key, () => {});
        result[entry.key]?[entityID] = entry.value;
      }
    }
    return result;
  }

  bool isNumeric(Map<String, dynamic> columnValues) {
    final nonNullValues = columnValues.values.where((value) => value != null && value.toString() != 'Unknown').toList();

    if (nonNullValues.isEmpty) return false;

    // To prevent the case where 0/1 only is tagged as numeric column
    return !isBinary(columnValues) &&
        nonNullValues.every((value) {
          final String strValue = value.toString().trim();
          return num.tryParse(strValue) != null;
        });
  }

  bool isBinary(Map<String, dynamic> columnValues) {
    final nonNullValues = columnValues.values
        .where((value) => value != null && value.toString() != 'Unknown')
        .map((value) => value.toString().trim())
        .toSet();

    return nonNullValues.length == 2;
  }

  /// Get the trainable column names, optionally filtered by type
  /// A column is trainable if it has at least one null or "Unknown" value
  ///
  /// Parameters:
  /// - [binaryTypes]: If true, only include binary columns
  /// - [numericTypes]: If true, only include numeric columns
  /// Add more types here as needed
  List<String> getPartiallyUnlabeledColumnNames({bool? binaryTypes, bool? numericTypes}) {
    final Map<String, Map<String, dynamic>> allColumns = getColumns();
    final Set<String> systemColumns = getSystemColumns();

    int numberOfEntries = 0;
    if (allColumns.isNotEmpty) {
      numberOfEntries =
          allColumns.values.map((valueMap) => valueMap.length).reduce((max, current) => max > current ? max : current);
    }

    return allColumns.keys.where((column) {
      if (systemColumns.contains(column)) return false;

      final Map<String, dynamic> columnValues = allColumns[column] ?? {};

      bool isTrainable = columnValues.length < numberOfEntries ||
          columnValues.values.any((value) {
            return value == null || value.toString() == '' || value.toString() == 'Unknown';
          });

      if (!isTrainable) return false;

      if (binaryTypes == null && numericTypes == null) return true;

      bool isColumnBinary = isBinary(columnValues);
      bool isColumnNumeric = isNumeric(columnValues);

      if (binaryTypes == true && isColumnBinary) return true;
      if (numericTypes == true && isColumnNumeric) return true;

      if (binaryTypes == false && numericTypes == false) return false;

      if (binaryTypes == true && numericTypes == null) return isColumnBinary;
      if (numericTypes == true && binaryTypes == null) return isColumnNumeric;

      return false;
    }).toList();
  }

  Type getType() {
    return T;
  }

  Future<String> convertToString(String fileFormat) {
    final handler = BioFileHandler<T>().create(fileFormat);
    return handler.convertToString(databaseToMap()).then((val) => val ?? '');
  }

  Future<Map<String, T>> importEntities(Map<String, T> entities, DatabaseImportMode databaseImportMode) async {
    switch (databaseImportMode) {
      case DatabaseImportMode.overwrite:
        {
          clearDatabase();
          addAllEntities(entities.values);
          break;
        }
      case DatabaseImportMode.merge:
        {
          for (MapEntry<String, T> entry in entities.entries) {
            final T? existingEntity = getEntityById(entry.key);
            if (existingEntity != null) {
              updateEntity(existingEntity.getID(), entry.value.merge(existingEntity, failOnConflict: false) as T);
            } else {
              addEntity(entry.value);
            }
          }
          break;
        }
    }
    return databaseToMap();
  }

  Future<Map<String, T>> importEntitiesFromFile(LoadedFileData fileData, DatabaseImportMode databaseImportMode) async {
    final Map<String, T> loadedEntities = await compute(_loadEntitiesFromFile, fileData);
    return importEntities(loadedEntities, databaseImportMode);
  }

  static Future<Map<String, T>> _loadEntitiesFromFile<T>(LoadedFileData fileData) async {
    try {
      // TODO Add option for consistency check into UI
      // TODO Add different file formats: fileData.extension
      final handler = BioFileHandler<T>()
          .create('fasta', config: BioFileHandlerConfig.serialDefaultConfig().copyWith(checkFileConsistency: false));
      final Map<String, T>? entitiesFromFastaFile =
          await handler.readFromString(fileData.content, fileName: fileData.name);
      if (entitiesFromFastaFile == null) {
        logger.e('Error loading entities from file: no values returned!');
        return {};
      }
      return entitiesFromFastaFile;
    } catch (e) {
      logger.e('Error loading entities from file: $e');
      rethrow;
    }
  }

  Future<Map<String, T>> handleColumnWizardOperationResult(ColumnWizardOperationResult? operationResult) async {
    if (operationResult is ColumnWizardAddOperationResult) {
      // TODO ERROR HANDLING
      final String newColumnName = operationResult.newColumnName;
      final Map<String, dynamic> newValues = operationResult.newColumnValues;
      final Map<String, String> attributeMap =
          Map.fromEntries(newValues.entries.map((entry) => MapEntry(entry.key, entry.value.toString())));
      return addCustomAttribute(newColumnName, attributeMap);
    }
    if (operationResult is ColumnWizardRemoveOperationResult) {
      final List<int> indicesToRemove = operationResult.indicesToRemove;
      final List<T?> entitiesToRemove = indicesToRemove.map((index) => getEntityByRow(index)).toList();
      for (T? entity in entitiesToRemove) {
        removeEntity(entity);
      }
      return databaseToMap();
    }
    return databaseToMap(); // TODO
  }

  // *** HASHING ***

  Future<String> getHash() async {
    final String databaseString = await convertToString('fasta');
    final List<int> bytes = utf8.encode(databaseString);
    final String hash = sha256.convert(bytes).toString();
    return hash;
  }

  // *** ATTRIBUTES ***

  Future<Map<String, T>> addCustomAttribute(String attributeName, Map<String, dynamic> attributeMap) {
    final Map<String, CustomAttributes> customAttributes = attributeMap
        .map((entityID, attributeValue) => MapEntry(entityID, CustomAttributes({attributeName: attributeValue})));
    return _updateEntitiesFromCustomAttributes(customAttributes);
  }

  Future<Map<String, T>> importCustomAttributesFromFile(LoadedFileData fileData) async {
    final Map<String, CustomAttributes> customAttributes =
        await _loadCustomAttributesFromFile(fileData.content, fileData.extension);
    return _updateEntitiesFromCustomAttributes(customAttributes);
  }

  Future<Map<String, T>> _updateEntitiesFromCustomAttributes(Map<String, CustomAttributes>? customAttributes) async {
    if (customAttributes == null) {
      return databaseToMap();
    }
    int numberUnknownEntities = 0;
    for (MapEntry<String, CustomAttributes> entityIDToAttributes in customAttributes.entries) {
      final T? entityToUpdate = getEntityById(entityIDToAttributes.key);
      if (entityToUpdate != null) {
        final T entityUpdated = entityToUpdate.updateFromCustomAttributes(entityIDToAttributes.value);
        if (entityUpdated.getID() != entityToUpdate.getID()) {
          logger.e('Changing IDs via custom attributes is not allowed for biological entities!');
          continue;
        }
        updateEntity(entityUpdated.getID(), entityUpdated);
      } else {
        numberUnknownEntities++;
      }
    }
    if (numberUnknownEntities > 0) {
      logger.i('Number unknown entities during update: $numberUnknownEntities');
    }
    return databaseToMap();
  }

  static Future<Map<String, CustomAttributes>> _loadCustomAttributesFromFile(
    String? fileContent,
    String fileType,
  ) async {
    try {
      final handler = BioFileHandler<CustomAttributes>().create(fileType);
      final Map<String, CustomAttributes>? customAttributesFromFile = await handler.readFromString(fileContent);
      if (customAttributesFromFile == null) {
        logger.e('Error loading custom attributes from file: no values returned!');
        return {};
      }
      return customAttributesFromFile;
    } catch (e) {
      logger.e('Error loading custom attributes from file: $e');
      rethrow;
    }
  }

  Set<String> getAllCustomAttributeKeys() {
    return databaseToList().expand((entity) => entity.getCustomAttributes().keys()).toSet();
  }

  Set<String> getAvailableAttributesForAllEntities() {
    return _getKeysWhereDataIsAvailableForAllEntries(
      entitiesAsMaps().expand((element) => element.entries).toList(),
      databaseToList().length,
    );
  }

  Set<String> getAvailableSetColumnsForAllEntities() {
    return _getKeysWhereDataIsAvailableForAllEntries(
      entitiesAsMaps()
          .expand((element) => element.entries.where((entry) => entry.key.toLowerCase().contains('set')))
          .toList(),
      databaseToList().length,
    );
  }

  static Set<String> _getKeysWhereDataIsAvailableForAllEntries(
    List<MapEntry<String, dynamic>> entries,
    int repositoryLength,
  ) {
    final Set<String> result = {};
    // category name -> number of occurrences
    final Map<String, int> uniqueMap = {};
    for (MapEntry<String, dynamic> entry in entries) {
      uniqueMap.putIfAbsent(entry.key, () => 0);

      if (entry.value.toString() != '') {
        final int count = uniqueMap[entry.key]! + 1;
        uniqueMap[entry.key] = count;
      }
    }

    for (MapEntry<String, int> categoryOccurrences in uniqueMap.entries) {
      if (categoryOccurrences.value == repositoryLength) {
        result.add(categoryOccurrences.key);
      }
    }
    return result;
  }

  Map<String, EmbeddingManager> getAllEmbeddings() {
    return Map.fromEntries(databaseToMap().entries.map((entry) => MapEntry(entry.key, entry.value.getEmbeddings())));
  }
}

enum DatabaseImportMode {
  overwrite,
  merge;

  static const DatabaseImportMode defaultMode = DatabaseImportMode.overwrite;
}
