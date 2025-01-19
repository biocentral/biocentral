import 'dart:math';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:ml_linalg/linalg.dart';

class EmbeddingsColumnWizardFactory extends ColumnWizardFactory {
  @override
  ColumnWizard create({required String columnName, required Map<String, dynamic> valueMap}) {
    return EmbeddingsColumnWizard(columnName, valueMap.map((k, v) => MapEntry(k, v as EmbeddingManager)));
  }

  @override
  TypeDetector getTypeDetector() {
    return TypeDetector(EmbeddingManager, (value) => value is EmbeddingManager);
  }
}

class EmbeddingsColumnWizard extends ColumnWizard {
  @override
  final Map<String, EmbeddingManager> valueMap;

  @override
  Type get type => EmbeddingManager;

  EmbeddingsColumnWizard(super.columnName, this.valueMap);

  Set<String>? _embedderNames;

  Set<String> getAllEmbedderNames() {
    _embedderNames ??= Set.unmodifiable(valueMap.values.expand((manager) => manager.getEmbedderNames()));
    return _embedderNames!;
  }

  // embedder name -> Map with per sequence embeddings
  Map<String, Map<String, PerSequenceEmbedding?>>? _perSequenceEmbeddings;

  Map<String, Map<String, PerSequenceEmbedding?>> _getPerSequenceEmbeddings() {
    if (_perSequenceEmbeddings != null) {
      return _perSequenceEmbeddings!;
    }
    final Map<String, Map<String, PerSequenceEmbedding?>> result = {};
    for (final entry in valueMap.entries) {
      for (String embedderName in entry.value.getEmbedderNames()) {
        result.putIfAbsent(embedderName, () => {});
        result[embedderName]!.putIfAbsent(entry.key, () => entry.value.perSequence(embedderName: embedderName));
      }
    }
    _perSequenceEmbeddings = result;
    _embedderNames = Set.unmodifiable(result.keys);
    return _perSequenceEmbeddings!;
  }

  Map<String, PerSequenceEmbedding>? perSequenceByEmbedderName(String? embedderName) {
    final embeddingMap = _getPerSequenceEmbeddings()[embedderName];
    if(embeddingMap == null) {
      return null;
    }
    return embeddingMap.filterNull<String, PerSequenceEmbedding>();
  }

  // embedder name -> List with per residue embeddings
  Map<String, Map<String, PerResidueEmbedding?>>? _perResidueEmbeddings;

  Map<String, Map<String, PerResidueEmbedding?>> _getPerResidueEmbeddings() {
    if (_perResidueEmbeddings != null) {
      return _perResidueEmbeddings!;
    }
    final Map<String, Map<String, PerResidueEmbedding?>> result = {};
    for (final entry in valueMap.entries) {
      for (String embedderName in entry.value.getEmbedderNames()) {
        result.putIfAbsent(embedderName, () => {});
        result[embedderName]!.putIfAbsent(entry.key, () => entry.value.perResidue(embedderName: embedderName));
      }
    }
    _perResidueEmbeddings = result;
    // TODO Embedder names should always be filled completely in both methods (perSequence/perResidue)
    _embedderNames = Set.unmodifiable(result.keys);
    return _perResidueEmbeddings!;
  }

  Map<String, PerResidueEmbedding>? perResidueByEmbedderName(String embedderName) {
    final embeddingMap = _getPerResidueEmbeddings()[embedderName];
    if(embeddingMap == null) {
      return null;
    }
    return embeddingMap.filterNull<String, PerResidueEmbedding>();
  }

  Map<String, Set<EmbeddingType>>? _availableEmbeddingTypes;

  Set<EmbeddingType> getAvailableEmbeddingTypesForEmbedder(String embedderName) {
    _availableEmbeddingTypes ??= {};
    if (_availableEmbeddingTypes!.containsKey(embedderName)) {
      return _availableEmbeddingTypes![embedderName]!.toSet();
    }
    _availableEmbeddingTypes!.putIfAbsent(embedderName, () => {});
    final allEmbeddingsLists = [
      perSequenceByEmbedderName(embedderName)?.values ?? [],
      perResidueByEmbedderName(embedderName)?.values ?? [],
    ];

    for (final embeddings in allEmbeddingsLists) {
      if (embeddings.isNotEmpty) {
        _availableEmbeddingTypes![embedderName]!.add(embeddings.first.getType());
      }
    }
    return _availableEmbeddingTypes![embedderName]!;
  }

  Map<String, Map<EmbeddingType, EmbeddingStats>>? _embeddingStats;

  Future<EmbeddingStats> getEmbeddingStats(String embedderName, EmbeddingType embeddingType) async {
    _embeddingStats ??= {};
    _embeddingStats!.putIfAbsent(embedderName, () => {});

    if (!_embeddingStats![embedderName]!.containsKey(embeddingType)) {
      final List<List<double>> embeddings = _getEmbeddingsForType(embedderName, embeddingType);
      _embeddingStats![embedderName]![embeddingType] = await compute(_calculateEmbeddingStats, embeddings);
    }

    return _embeddingStats![embedderName]![embeddingType]!;
  }

  List<List<double>> _getEmbeddingsForType(String embedderName, EmbeddingType embeddingType) {
    switch (embeddingType) {
      case EmbeddingType.perSequence:
        return perSequenceByEmbedderName(embedderName)!
            .values
            .map((emb) => emb.rawValues())
            .toList();
      case EmbeddingType.perResidue:
        return perResidueByEmbedderName(embedderName)!
            .values
            .expand((emb) => emb.rawValues())
            .toList();
    }
  }

  EmbeddingStats _calculateEmbeddingStats(List<List<double>> embeddings) {
    final Matrix matrix = Matrix.fromList(embeddings);
    final int n = embeddings.length;
    final Vector mean = matrix.reduceRows(
          (acc, column) =>
              Vector.fromList(List.generate(acc.length, (index) => acc.elementAt(index) + column.elementAt(index))),
        ) /
        n;
    // TODO Not sure about these..
    final Vector variance = matrix.reduceRows(
          (acc, column) => Vector.fromList(
            List.generate(
              acc.length,
              (index) => acc.elementAt(index) + pow(column.elementAt(index) - mean.elementAt(index), 2),
            ),
          ),
        ) /
        n;
    final Vector stdDev = variance.sqrt();
// Calculate min and max
    final Vector minimum = matrix.reduceRows(
      (acc, column) =>
          Vector.fromList(List.generate(acc.length, (index) => min(acc.elementAt(index), column.elementAt(index)))),
    );

    final Vector maximum = matrix.reduceRows(
      (acc, column) =>
          Vector.fromList(List.generate(acc.length, (index) => max(acc.elementAt(index), column.elementAt(index)))),
    );

    // TODO Cosine, Euclidean
    //double averageCosineSimilarity = embeddings
    //    .map((emb) => cosineDistance(Vector(emb), mean))
    //    .reduce((a, b) => a + b) / embeddings.length;
//
    //double averageEuclideanDistance = embeddings
    //    .map((emb) => euclideanDistance(Vector(emb), mean))
    //    .reduce((a, b) => a + b) / embeddings.length;

    return EmbeddingStats(
      mean: mean,
      variance: variance,
      stdDev: stdDev,
      min: minimum,
      max: maximum,
      dimensionality: mean.length,
      numberOfEmbeddings: n,
      averageCosineSimilarity: 0.0,
      averageEuclideanDistance: 0.0,
    );
  }
}

class EmbeddingStats {
  final Vector mean;
  final Vector variance;
  final Vector stdDev;
  final Vector min;
  final Vector max;
  final int dimensionality;
  final int numberOfEmbeddings;
  final double averageCosineSimilarity;
  final double averageEuclideanDistance;

  EmbeddingStats({
    required this.mean,
    required this.variance,
    required this.stdDev,
    required this.min,
    required this.max,
    required this.dimensionality,
    required this.numberOfEmbeddings,
    required this.averageCosineSimilarity,
    required this.averageEuclideanDistance,
  });
}
