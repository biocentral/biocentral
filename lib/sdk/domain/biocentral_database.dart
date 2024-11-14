import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'package:biocentral/sdk/model/column_wizard_operations.dart';
import 'package:biocentral/sdk/util/logging.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';

abstract class BiocentralDatabase<T extends BioEntity> {
  // *** READ/WRITE/UPDATE ***
  void addEntity(T entity);

  void removeEntity(T? entity);

  void updateEntity(String id, T entityUpdated);

  bool containsEntity(String id);

  T? getEntityById(String id);

  T? getEntityByRow(int rowIndex);

  void clearDatabase();

  List<T> databaseToList();

  Map<String, T> databaseToMap();

  List<Map<String, String>> entitiesAsMaps();

  String getEntityTypeName();

  void syncFromDatabase(Map<String, BioEntity> entities, DatabaseImportMode importMode);

  Map<String, T> updateEmbeddings(Map<String, Embedding> newEmbeddings);

  Map<String, Map<String, dynamic>> getColumns() {
    final List<Map<String, String>> entityMaps = entitiesAsMaps();
    final Map<String, Map<String, dynamic>> result = {};
    for (Map<String, String> entityMap in entityMaps) {
      final String entityID = entityMap['id'] ?? '';
      if (entityID.isEmpty) {
        logger.w('Encountered entity without an ID!');
      }
      for (MapEntry<String, String> entry in entityMap.entries) {
        result.putIfAbsent(entry.key, () => {});
        result[entry.key]?[entityID] = entry.value;
      }
    }
    return result;
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
          for (T entity in entities.values) {
            addEntity(entity);
          }
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

  Future<Map<String, T>> importEntitiesFromFile(FileData fileData, DatabaseImportMode databaseImportMode) async {
    final Map<String, T> loadedEntities = await compute(_loadEntitiesFromFile, fileData);
    return importEntities(loadedEntities, databaseImportMode);
  }

  Future<Map<String, T>> _loadEntitiesFromFile(FileData fileData) async {
    try {
      // TODO Add option for consistency check into UI
      // TODO Add different file formats: fileData.extension
      final handler = BioFileHandler<T>()
          .create('fasta', config: BioFileHandlerConfig.serialDefaultConfig().copyWith(checkFileConsistency: false));
      final Map<String, T>? entitiesFromFastaFile = await handler.readFromString(fileData.content, fileName: fileData.name);
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

  Future<Map<String, T>> importCustomAttributesFromFile(FileData fileData) async {
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
      String? fileContent, String fileType,) async {
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
        entitiesAsMaps().expand((element) => element.entries).toList(), databaseToList().length,);
  }

  Set<String> getAvailableSetColumnsForAllEntities() {
    return _getKeysWhereDataIsAvailableForAllEntries(
        entitiesAsMaps()
            .expand((element) => element.entries.where((entry) => entry.key.toLowerCase().contains('set')))
            .toList(),
        databaseToList().length,);
  }

  static Set<String> _getKeysWhereDataIsAvailableForAllEntries(
      List<MapEntry<String, String>> entries, int repositoryLength,) {
    final Set<String> result = {};
    // category name -> number of occurrences
    final Map<String, int> uniqueMap = {};
    for (MapEntry<String, String> keyValue in entries) {
      uniqueMap.putIfAbsent(keyValue.key, () => 0);

      if (keyValue.value != '') {
        final int count = uniqueMap[keyValue.key]! + 1;
        uniqueMap[keyValue.key] = count;
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
