import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/domain/biocentral_repository_auto_saver.dart';
import 'package:biocentral/sdk/domain/streamable_database.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ml_linalg/vector.dart';

class LazyEmbedding {
  final String key;
  final String path;
  final String embedderName;
  final EmbeddingMetadata metaData;

  final Future<Embedding?> Function() _getFunction;

  LazyEmbedding({
    required this.key,
    required this.path,
    required this.embedderName,
    required this.metaData,
    required Future<Embedding?> Function() getFunction,
  }) : _getFunction = getFunction;

  factory LazyEmbedding.lazy({
    required String key,
    required String path,
    required String embedderName,
    required EmbeddingMetadata metaData,
    required BiocentralPythonCompanion companion,
  }) {
    Future<Embedding?> getFunction() async {
      final embeddingEither = await companion.getEmbedding(key, path, embedderName);
      return embeddingEither.match((l) => null, (r) => r);
    }

    return LazyEmbedding(
      key: key,
      path: path,
      embedderName: embedderName,
      metaData: metaData,
      getFunction: getFunction,
    );
  }

  Embedding? _embedding;

  /// Actually loads the embedding. Possibly an expensive operation!
  Future<Embedding?> getEmbedding() async {
    if (_embedding != null) {
      return _embedding;
    }
    final embd = await _getFunction();
    _embedding = embd;
    return _embedding;
  }

  /// Function for web: Loading one embedding triggers loading of all embeddings and can be set here
  void setEmbedding(Embedding loaded) {
    _embedding = loaded;
  }
}

class EmbeddingMetadata {
  final EmbeddingType embeddingType;
  final int dimension; // Embedding dimension
  final int length; // Length of per Residue embedding (usually matches sequence length)
  final Map<String, dynamic> attributes;

  EmbeddingMetadata({
    required this.embeddingType,
    required this.dimension,
    required this.length,
    this.attributes = const {},
  });

  factory EmbeddingMetadata.deserialize(Map<String, dynamic> jsonMap) {
    EmbeddingType? embeddingType = enumFromString(jsonMap['embeddingType'].toString(), EmbeddingType.values);
    embeddingType ??= str2bool(jsonMap['embeddingType'].toString())
        ? EmbeddingType.perResidue
        : EmbeddingType.perSequence; // Companion API
    return EmbeddingMetadata(
      embeddingType: embeddingType,
      dimension: jsonMap['dimension'] as int,
      length: jsonMap['length'] as int,
      attributes: jsonMap['attributes'] as Map<String, dynamic>? ?? const {},
    );
  }
}

class EmbeddingsFileInformation {
  final Map<String, EmbeddingMetadata> metadata;

  EmbeddingsFileInformation(this.metadata);

  factory EmbeddingsFileInformation.fromCompanion(Map<String, dynamic> jsonMap) {
    final metadata = <String, EmbeddingMetadata>{};
    for (final (key, metadataMap) in jsonMap.entriesRecord) {
      final metadataDeserialized = EmbeddingMetadata.deserialize(metadataMap);
      metadata[key] = metadataDeserialized;
    }
    return EmbeddingsFileInformation(metadata);
  }

  int length() {
    return metadata.length;
  }

  List<EmbeddingMetadata> _getPerResidue() {
    return metadata.values.filter((v) => v.embeddingType == EmbeddingType.perResidue).toList();
  }

  Set<int> _getAvailableDimensions() {
    return metadata.values.map((v) => v.dimension).toSet();
  }

  double averagePerResidueLength() {
    final perResidue = _getPerResidue();
    final lengths = perResidue.map((embd) => embd.length).toList();
    if (lengths.isEmpty) {
      lengths.add(0); // Mitigate "vector is empty error" by linalg library
    }
    return Vector.fromList(lengths).mean();
  }

  Map<String, dynamic> stats() {
    final foundEmbeddings = length();
    final perResidue = _getPerResidue().length;
    final perSequence = foundEmbeddings - perResidue;
    return {
      'Found Embeddings': metadata.keys.length,
      '    - per Residue': perResidue,
      '    - per Sequence': perSequence,
      'Embedding Dimensions': _getAvailableDimensions().toList().toString(),
      'Average per Residue Embedding Length': averagePerResidueLength().toStringAsFixed(1),
    };
  }
}

class EmbeddingsFile {
  final String path; // TODO Path in Web
  final String embedderName;
  final EmbeddingsFileInformation fileInformation;

  EmbeddingsFile({required this.path, required this.embedderName, required this.fileInformation});

  static Future<Either<BiocentralException, EmbeddingsFile>> deserialize(
    Map<String, dynamic> jsonMap,
    BiocentralPythonCompanion companion,
  ) async {
    final path = jsonMap['path'] as String;
    final embedderName = jsonMap['embedderName'] as String;
    final fileInformation = await companion.getH5Info(path);
    return fileInformation.flatMap(
      (r) => right(EmbeddingsFile(path: path, embedderName: embedderName, fileInformation: r)),
    );
  }

  Map<String, String> serialize() {
    return {'path': path, 'embedderName': embedderName};
  }
}

enum EmbeddingsFileLoadMode {
  external,
  internal;

  static const EmbeddingsFileLoadMode defaultMode = EmbeddingsFileLoadMode.external;
}

final class EmbeddingsDatabaseDTO {
  final Map<String, Map<String, LazyEmbedding>> perResidue; // EmbedderName -> Key -> MetaData
  final Map<String, Map<String, LazyEmbedding>> perSequence;

  EmbeddingsDatabaseDTO({required this.perResidue, required this.perSequence});

  /// Filter to only contain available keys
  /// TODO Apply in Hub Bloc
  EmbeddingsDatabaseDTO filtered(List<String> keys) {
    final pR = <String, Map<String, LazyEmbedding>>{};
    final pS = <String, Map<String, LazyEmbedding>>{};
    for (final key in keys) {
      for (final embedderName in perResidue.keys) {
        if (perResidue[embedderName]!.containsKey(key)) {
          pR.putIfAbsent(embedderName, () => {});
          pR[embedderName]![key] = perResidue[embedderName]![key]!;
        }
      }
      for (final embedderName in perSequence.keys) {
        if (perSequence[embedderName]!.containsKey(key)) {
          pS.putIfAbsent(embedderName, () => {});
          pS[embedderName]![key] = perSequence[embedderName]![key]!;
        }
      }
    }
    return EmbeddingsDatabaseDTO(perResidue: pR, perSequence: pS);
  }

  bool isEmpty() => perResidue.isEmpty && perSequence.isEmpty;

  List<String> getAvailableEmbedders() {
    final allEmbedders = Set<String>.from(perResidue.keys)..addAll(perSequence.keys);
    return allEmbedders.toList();
  }

  Map<String, Map<String, LazyEmbedding>> byType(EmbeddingType type) =>
      type == EmbeddingType.perResidue ? perResidue : perSequence;

  Set<EmbeddingType> getAvailableTypesByEmbedder(String? embedderName) {
    final types = <EmbeddingType>{};
    if (perResidue.containsKey(embedderName)) {
      types.add(EmbeddingType.perResidue);
    }
    if (perSequence.containsKey(embedderName)) {
      types.add(EmbeddingType.perSequence);
    }
    return types;
  }
}

class _EmbeddingsDatabase {
  // Embedder Name -> Key -> Embedding
  final Map<String, Map<String, LazyEmbedding>> _perResidueEmbeddings = {}; // PerResidue Embeddings already in memory
  final Map<String, Map<String, LazyEmbedding>> _perSequenceEmbeddings = {}; // PerSequence Embeddings already in memory

  final Map<String, EmbeddingsFile> _embeddingFiles = {}; // Path -> EmbeddingsFile

  final BiocentralPythonCompanion companion;

  _EmbeddingsDatabase(this.companion);

  Future<void> deserialize(Map<String, dynamic> jsonMap) async {
    final fileMaps = jsonMap['embeddingsDatabase'];
    final files = <EmbeddingsFile>[];
    for (final fileMap in fileMaps) {
      final deserializeEither = await EmbeddingsFile.deserialize(fileMap, companion);
      // TODO Improve error handling
      deserializeEither.match((l) => print(l), (r) => files.add(r));
    }
    for (final file in files) {
      _addFile(file);
    }
  }

  void _addFile(EmbeddingsFile file) {
    _embeddingFiles[file.path] = file;
    final path = file.path;
    final embedderName = file.embedderName;
    final metaData = file.fileInformation.metadata;
    for (final (key, data) in metaData.entriesRecord) {
      _addEmbedding(
        embedderName: embedderName,
        key: key,
        path: path,
        metaData: data,
        embeddingType: data.embeddingType,
      );
    }
  }

  Map<String, Map<String, LazyEmbedding>> _getEmbeddingMapByType(EmbeddingType embeddingType) {
    return embeddingType == EmbeddingType.perResidue ? _perResidueEmbeddings : _perSequenceEmbeddings;
  }

  void _addEmbedding({
    required String embedderName,
    required String key,
    required String path,
    required EmbeddingMetadata metaData,
    required EmbeddingType embeddingType,
  }) {
    final embeddingsMap = embeddingType == EmbeddingType.perResidue ? _perResidueEmbeddings : _perSequenceEmbeddings;
    embeddingsMap.putIfAbsent(embedderName, () => {});
    final lazyEmbedding =
        LazyEmbedding.lazy(key: key, path: path, embedderName: embedderName, metaData: metaData, companion: companion);
    embeddingsMap[embedderName]![key] = lazyEmbedding;
  }

  Future<Embedding?> getEmbedding({
    required String embedderName,
    required String key,
    required EmbeddingType embeddingType,
  }) async {
    final embeddingsMap = _getEmbeddingMapByType(embeddingType);
    final lazyEmbedding = embeddingsMap[embedderName]?[key];
    return lazyEmbedding?.getEmbedding();
  }

  Map<String, List<Map<String, dynamic>>> serialize() {
    return {'embeddingsDatabase': _embeddingFiles.values.map((f) => f.serialize()).toList()};
  }

  EmbeddingsDatabaseDTO toDTO() {
    return EmbeddingsDatabaseDTO(
      perResidue: Map.from(_perResidueEmbeddings),
      perSequence: Map.from(_perSequenceEmbeddings),
    );
  }

  int get numberOfFiles => _embeddingFiles.length;
}

class EmbeddingsRepository with AutoSaving, StreamableDatabase<EmbeddingsDatabaseDTO> {
  final _EmbeddingsDatabase _database;

  @override
  late final BiocentralRepositoryAutoSaver autoSaver;

  EmbeddingsRepository(BiocentralProjectRepository projectRepository, BiocentralPythonCompanion companion)
      : _database = _EmbeddingsDatabase(companion) {
    autoSaver = BiocentralRepositoryAutoSaver(
      projectRepository: projectRepository,
      fileName: 'embedding_db_info.json',
      fileType: EmbeddingsFile,
      saveFunctionString: saveDBInfo,
    );
  }

  void addFile(EmbeddingsFile file) {
    withAutoSave(() => _database._addFile(file));
    updateStream();
  }

  Future<int> deserializedLoad(Map<String, dynamic> jsonMap) async {
    await _database.deserialize(jsonMap);
    updateStream();
    return _database.numberOfFiles;
  }

  Future<String> saveDBInfo() async {
    final jsonMap = serialize();
    return jsonEncode(jsonMap);
  }

  Map<String, dynamic> serialize() => _database.serialize();

  @override
  EmbeddingsDatabaseDTO toStreamable() => _database.toDTO();
}
