import 'dart:async';
import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_database_column.dart';
import 'package:biocentral/sdk/domain/biocentral_repository_auto_saver.dart';
import 'package:biocentral/sdk/domain/streamable_database.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

abstract class BiocentralDatabase<T extends BioEntity> with AutoSaving, StreamableDatabase<Map<String, T>> {
  @override
  late final BiocentralRepositoryAutoSaver autoSaver;

  BiocentralDatabase(BiocentralProjectRepository? biocentralProjectRepository) {
    if (biocentralProjectRepository != null) {
      autoSaver = BiocentralRepositoryAutoSaver(
        projectRepository: biocentralProjectRepository,
        fileName: '${getEntityTypeName().toLowerCase()}.fasta',
        fileType: T,
        saveFunctionString: () async {
          final String content = await convertToString('fasta');
          return content; // TODO Make file extension customizable
        },
      );
    }
    // Virtual databases do not use autoSaving
  }

  // Create virtual database for database updates
  BiocentralDatabase<T> virtualize();

  // Accept database update: This is the only function that should actually change the employed database
  void acceptDatabaseUpdate(BiocentralDatabaseUpdate<T> update) {
    _acceptDatabaseUpdateImpl(update);
    updateStream();
    autosave();
  }

  void _acceptDatabaseUpdateImpl(BiocentralDatabaseUpdate<T> update) {
    clearDatabase();
    addAllEntities(update.result.values);
  }

  @override
  Map<String, T> toStreamable() => databaseToMap();

  // *** READ/WRITE/UPDATE ***
  void addEntity(T entity);

  void addAllEntities(Iterable<T> entities);

  void removeEntity(T? entity);

  void updateEntity(String id, T entityUpdated);

  void clearDatabase();

  bool containsEntity(String id);

  T? getEntityById(String id);

  T? getEntityByRow(int rowIndex);

  List<T> databaseToList();

  Map<String, T> databaseToMap();

  List<Map<String, dynamic>> entitiesAsMaps();

  String getEntityTypeName();

  Map<String, String>? getSequences();

  List<SequenceData> getTrainingData({
    required BiocentralDatabaseColumn targetColumn,
    BiocentralDatabaseColumn setColumn,
    String? maskColumn,
  });

  void syncFromDatabase(Map<String, BioEntity> entities, DatabaseImportMode importMode);

  Map<String, T> updateEmbeddings(Map<String, Embedding> newEmbeddings);

  /// Returns a set of column names that should be excluded from training and analysis
  /// These are typically system columns like ID, embeddings, etc.
  Set<String> getSystemColumns();

  List<BiocentralDatabaseColumn> getColumns() {
    final List<Map<String, dynamic>> entityMaps = entitiesAsMaps();
    final Set<String> encounteredIDs = {};
    final Map<String, Map<String, dynamic>> result = {};
    for (Map<String, dynamic> entityMap in entityMaps) {
      final String entityID = entityMap['id'] ?? '';
      if (entityID.isEmpty) {
        logger.w('Encountered entity without an ID!');
      }
      encounteredIDs.add(entityID);
      for (MapEntry<String, dynamic> entry in entityMap.entries) {
        result.putIfAbsent(entry.key, () => {});
        result[entry.key]?[entityID] = entry.value;
      }
    }
    // Add null values
    for (final (columnMap) in result.values) {
      for (final entityID in encounteredIDs) {
        columnMap.putIfAbsent(entityID, () => null);
      }
    }
    return result.entries.map((entry) => BiocentralDatabaseColumn(name: entry.key, values: entry.value)).toList();
  }

  BiocentralDatabaseColumn? getColumn(String? columnName) {
    // TODO This is not very efficient
    return getColumns().where((c) => c.name == columnName).toSet().firstOrNull;
  }

  /// Get the trainable column names, optionally filtered by type
  /// A column is trainable if it has at least one null or "Unknown" value
  ///
  /// Parameters:
  /// - [binaryTypes]: If true, only include binary columns
  /// - [numericTypes]: If true, only include numeric columns
  /// Add more types here as needed
  Set<BiocentralDatabaseColumn> getPartiallyUnlabeledColumnNames({
    required bool numericOnly,
    required bool binaryOnly,
  }) {
    final allColumns = getColumns();
    final Set<String> systemColumns = getSystemColumns();

    return allColumns.where((column) {
      if (systemColumns.contains(column.name)) {
        return false;
      }
      final bool isColumnBinary = column.isBinary;
      final bool isColumnNumeric = column.isNumeric;

      if (binaryOnly && isColumnBinary) return true;
      if (numericOnly && isColumnNumeric) return true;

      if (binaryOnly && numericOnly) return false;

      if (binaryOnly && numericOnly) return isColumnBinary;
      if (numericOnly && binaryOnly) return isColumnNumeric;

      return column.isPartiallyUnlabeled();
    }).toSet();
  }

  Set<BiocentralDatabaseColumn> getTrainableColumns() {
    // TODO Maybe add reason why column is not trainable
    final systemColumns = getSystemColumns();
    final availableKeys = _getKeysWhereDataIsAvailableForAllEntries(
      entitiesAsMaps()
          .expand((element) => element.entries.where((entry) => !systemColumns.contains(entry.key)))
          .toList(),
      databaseToList().length,
    );
    final allColumns = getColumns();
    return allColumns.where((column) => availableKeys.contains(column.name)).toSet();
  }

  Type getType() {
    return T;
  }

  Future<String> convertToString(String fileFormat) {
    final handler = BioFileHandler<T>().create(fileFormat);
    return handler.convertToString(databaseToMap()).then((val) => val ?? '');
  }

  Future<BiocentralDatabaseUpdate<T>> _importEntities(Map<String, T> entities, DatabaseImportMode importMode) async {
    final updateBuilder = BiocentralDatabaseUpdateBuilder<T>(importMode);
    switch (importMode) {
      case DatabaseImportMode.overwrite:
        {
          updateBuilder.setDelete(databaseToMap().keys.toSet());
          clearDatabase();
          addAllEntities(entities.values);
          break;
        }
      case DatabaseImportMode.merge:
        {
          for (MapEntry<String, T> entry in entities.entries) {
            final T? existingEntity = getEntityById(entry.key);
            if (existingEntity != null) {
              final entityID = existingEntity.getID();
              updateBuilder.addUpdate(entityID);
              updateEntity(entityID, entry.value.merge(existingEntity, failOnConflict: false) as T);
            } else {
              addEntity(entry.value);
            }
          }
          break;
        }
    }
    updateBuilder.setResult(databaseToMap());
    return updateBuilder.collect();
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

  Future<BiocentralDatabaseUpdate<T>> importEntitiesFromFile(
    LoadedFileData fileData,
    DatabaseImportMode databaseImportMode,
  ) async {
    final Map<String, T> loadedEntities = await compute(_loadEntitiesFromFile, fileData);
    return virtualize()._importEntities(loadedEntities, databaseImportMode);
  }

  Future<BiocentralDatabaseUpdate<T>> _addColumnFromColumnWizardImpl(
    String newColumnName,
    ColumnWizard columnWizard,
  ) async {
    final updateBuilder = BiocentralDatabaseUpdateBuilder<T>(DatabaseImportMode.overwrite);

    final Map<String, dynamic> newValues = columnWizard.valueMap;
    final existingColumnNames = getColumns().map((c) => c.name).toSet();

    // Update existing column
    // TODO Check and make this work for non-custom columns as well
    if (existingColumnNames.contains(newColumnName)) {
      final Map<String, T> currentDatabase = databaseToMap();
      final Set<T?> entitiesToRemove = {};
      for (var entity in currentDatabase.values) {
        final entityID = entity.getID();
        if (newValues.containsKey(entityID)) {
          final updatedEntity = entity.updateFromCustomAttributes(
            CustomAttributes({newColumnName: newValues[entityID].toString()}),
          ) as T;
          updateEntity(entityID, updatedEntity);
          updateBuilder.addUpdate(entityID);
        } else {
          entitiesToRemove.add(currentDatabase[entityID]);
          updateBuilder.addDelete(entityID);
        }
      }
      for (final entity in entitiesToRemove) {
        removeEntity(entity);
      }
      updateBuilder.setResult(databaseToMap());
      return updateBuilder.collect();
    } else {
      // Add new column
      final Map<String, String> attributeMap =
          Map.fromEntries(newValues.entries.map((entry) => MapEntry(entry.key, entry.value.toString())));
      return addCustomAttributes(newColumnName, attributeMap);
    }
  }

  Future<BiocentralDatabaseUpdate<T>> addColumnFromColumnWizard(
    String newColumnName,
    ColumnWizard columnWizard,
  ) {
    return virtualize()._addColumnFromColumnWizardImpl(newColumnName, columnWizard);
  }

  // *** HASHING ***

  Future<String> getHash() async {
    final String databaseString = await convertToString('fasta');
    final List<int> bytes = utf8.encode(databaseString);
    final String hash = sha256.convert(bytes).toString();
    return hash;
  }

  // *** ATTRIBUTES ***

  Future<BiocentralDatabaseUpdate<T>> addCustomAttributes(String attributeName, Map<String, dynamic> attributeMap) {
    final Map<String, CustomAttributes> customAttributes = attributeMap
        .map((entityID, attributeValue) => MapEntry(entityID, CustomAttributes({attributeName: attributeValue})));
    return virtualize()._updateEntitiesFromCustomAttributes(customAttributes);
  }

  Future<BiocentralDatabaseUpdate<T>> importCustomAttributesFromFile(LoadedFileData fileData) async {
    final Map<String, CustomAttributes> customAttributes =
        await _loadCustomAttributesFromFile(fileData.content, fileData.extension);
    return virtualize()._updateEntitiesFromCustomAttributes(customAttributes);
  }

  Future<BiocentralDatabaseUpdate<T>> _updateEntitiesFromCustomAttributes(
    Map<String, CustomAttributes>? customAttributes,
  ) async {
    final updateBuilder = BiocentralDatabaseUpdateBuilder<T>(DatabaseImportMode.overwrite);
    if (customAttributes == null) {
      updateBuilder.setResult(databaseToMap());
      return updateBuilder.collect(); // TODO The if can maybe be deleted
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
        updateBuilder.addUpdate(entityUpdated.getID());
      } else {
        numberUnknownEntities++;
      }
    }
    if (numberUnknownEntities > 0) {
      logger.i('Number unknown entities during update: $numberUnknownEntities');
    }
    updateBuilder.setResult(databaseToMap());
    return updateBuilder.collect();
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

  Set<BiocentralDatabaseColumn> getSetColumns() {
    final availableKeys = _getKeysWhereDataIsAvailableForAllEntries(
      entitiesAsMaps()
          .expand(
            (element) => element.entries.where(
              (entry) => entry.key.toLowerCase().contains('set'),
            ),
          )
          .toList(),
      databaseToList().length,
    );
    final allColumns = getColumns();
    return allColumns.where((column) => availableKeys.contains(column.name)).toSet();
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
}

enum DatabaseImportMode {
  overwrite,
  merge;

  static const DatabaseImportMode defaultMode = DatabaseImportMode.overwrite;
}

class BiocentralDatabaseUpdate<R extends TypeNameMixin> {
  final Map<String, R> result; // Loaded/computed entities
  final Set<String> toUpdate; // Existing entity ids to update
  final Set<String> toDelete; // Existing entity ids to delete
  final DatabaseImportMode importMode;

  BiocentralDatabaseUpdate({
    required this.result,
    required this.toUpdate,
    required this.toDelete,
    required this.importMode,
  });

  factory BiocentralDatabaseUpdate.empty(DatabaseImportMode importMode) {
    return BiocentralDatabaseUpdate(result: {}, toUpdate: {}, toDelete: {}, importMode: importMode);
  }

  Map<String, dynamic> info() {
    return {
      'ResultType': result.values.firstOrNull?.typeName,
      'DatabaseLengthAfterUpdate': result.length,
      'OldEntriesToUpdate': toUpdate.length,
      'OldEntriesToDelete': toDelete.length,
      'ImportMode': importMode.name,
    };
  }

  Map<String, dynamic> serialize() {
    return {
      'resultName': typeName,
      'resultType': result.values.firstOrNull?.typeName,
      'result': result,
      'toUpdate': toUpdate,
      'toDelete': toDelete,
      'importMode': importMode,
    };
  }

  static String get typeName => 'BiocentralDatabaseUpdate';

  // TODO NOT SURE IF THAT WORKS / IS NECESSARY
  static BiocentralCommandResult<BiocentralDatabaseUpdate<R>>? reconstruct<R extends TypeNameMixin>(
    Map<String, dynamic> resultMap,
  ) {
    final resultName = resultMap['resultName'] ?? '';
    if (resultName == typeName) {
      final databaseUpdate = BiocentralDatabaseUpdate<R>(
        result: resultMap['result'],
        toUpdate: resultMap['toUpdate'],
        toDelete: resultMap['toDelete'],
        importMode: resultMap['importMode'],
      );
      return BiocentralCommandResult<BiocentralDatabaseUpdate<R>>(databaseUpdate, resultMap);
    }
    return null;
  }
}

final class BiocentralDatabaseUpdateBuilder<R extends TypeNameMixin> {
  final Map<String, R> _result = {}; // Loaded/computed entities
  final Set<String> _toUpdate = {}; // Existing entity ids to update
  final Set<String> _toDelete = {}; // Existing entity ids to delete
  final DatabaseImportMode _importMode;

  BiocentralDatabaseUpdateBuilder(this._importMode);

  void addResult(String id, R res) {
    _result[id] = res;
  }

  void setResult(Map<String, R> result) {
    _result.clear();
    _result.addAll(result);
  }

  void addUpdate(String id) => _toUpdate.add(id);

  void addDelete(String id) => _toDelete.add(id);

  void setDelete(Set<String> toDelete) {
    _toDelete.clear();
    _toDelete.addAll(toDelete);
  }

  BiocentralDatabaseUpdate<R> collect() {
    return BiocentralDatabaseUpdate(result: _result, toUpdate: _toUpdate, toDelete: _toDelete, importMode: _importMode);
  }
}
