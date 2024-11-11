import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:scidart/numdart.dart';

class EmbeddingsColumnWizardFactory extends ColumnWizardFactory {
  @override
  ColumnWizard create({required String columnName, required Map<String, dynamic> valueMap}) {
    return EmbeddingsColumnWizard(columnName, valueMap as Map<String, EmbeddingManager>);
  }

  @override
  TypeDetector getTypeDetector() {
    return TypeDetector(EmbeddingManager, (value) => value is EmbeddingManager);
  }
}

class EmbeddingsColumnWizard extends ColumnWizard {
  @override
  final Map<String, EmbeddingManager> valueMap;

  EmbeddingsColumnWizard(super.columnName, this.valueMap);

  Set<String>? _embedderNames;

  Set<String> getAllEmbedderNames() {
    _embedderNames ??= Set.unmodifiable(valueMap.values.expand((manager) => manager.getEmbedderNames()));
    return _embedderNames!;
  }

  // embedder name -> List with per sequence embeddings
  // TODO Refactor to Map<String, List> for embeddings to include keys
  Map<String, List<PerSequenceEmbedding?>>? _perSequenceEmbeddings;

  Map<String, List<PerSequenceEmbedding?>> getPerSequenceEmbeddings() {
    if (_perSequenceEmbeddings != null) {
      return _perSequenceEmbeddings!;
    }
    Map<String, List<PerSequenceEmbedding?>> result = {};
    for (EmbeddingManager embeddingManager in valueMap.values) {
      for (String embedderName in embeddingManager.getEmbedderNames()) {
        result.putIfAbsent(embedderName, () => []);
        result[embedderName]!.add(embeddingManager.perSequence(embedderName: embedderName));
      }
    }
    _perSequenceEmbeddings = result;
    _embedderNames = Set.unmodifiable(result.keys);
    return _perSequenceEmbeddings!;
  }

  // embedder name -> List with per residue embeddings
  Map<String, List<PerResidueEmbedding?>>? _perResidueEmbeddings;

  Map<String, List<PerResidueEmbedding?>> getPerResidueEmbeddings() {
    if (_perResidueEmbeddings != null) {
      return _perResidueEmbeddings!;
    }
    Map<String, List<PerResidueEmbedding?>> result = {};
    for (EmbeddingManager embeddingManager in valueMap.values) {
      for (String embedderName in embeddingManager.getEmbedderNames()) {
        result.putIfAbsent(embedderName, () => []);
        result[embedderName]!.add(embeddingManager.perResidue(embedderName: embedderName));
      }
    }
    _perResidueEmbeddings = result;
    // TODO Embedder names should always be filled completely in both methods (perSequence/perResidue)
    _embedderNames = Set.unmodifiable(result.keys);
    return _perResidueEmbeddings!;
  }

  Map<String, Set<EmbeddingType>>? _availableEmbeddingTypes;

  Set<EmbeddingType> getAvailableEmbeddingTypesForEmbedder(String embedderName) {
    _availableEmbeddingTypes ??= {};
    if (_availableEmbeddingTypes!.containsKey(embedderName)) {
      return _availableEmbeddingTypes![embedderName]!.toSet();
    }
    _availableEmbeddingTypes!.putIfAbsent(embedderName, () => {});
    for (final embeddings in [getPerSequenceEmbeddings()[embedderName], getPerResidueEmbeddings()[embedderName]]) {
      if (embeddings != null && embeddings.isNotEmpty && embeddings.any((emb) => emb != null)) {
        _availableEmbeddingTypes![embedderName]!.add(embeddings.firstWhere((emb) => emb != null)!.getType());
      }
    }
    return _availableEmbeddingTypes![embedderName]!;
  }

  Map<String, Map<EmbeddingType, EmbeddingStats>>? _embeddingStats;

  Future<EmbeddingStats> getEmbeddingStats(String embedderName, EmbeddingType embeddingType) async {
    _embeddingStats ??= {};
    _embeddingStats!.putIfAbsent(embedderName, () => {});

    if (!_embeddingStats![embedderName]!.containsKey(embeddingType)) {
      List<List<double>> embeddings = _getEmbeddingsForType(embedderName, embeddingType);
      _embeddingStats![embedderName]![embeddingType] = await compute(_calculateEmbeddingStats, embeddings);
    }

    return _embeddingStats![embedderName]![embeddingType]!;
  }

  List<List<double>> _getEmbeddingsForType(String embedderName, EmbeddingType embeddingType) {
    switch (embeddingType) {
      case EmbeddingType.perSequence:
        return getPerSequenceEmbeddings()[embedderName]!
            .where((emb) => emb != null)
            .map((emb) => emb!.rawValues())
            .toList();
      case EmbeddingType.perResidue:
        return getPerResidueEmbeddings()[embedderName]!
            .where((emb) => emb != null)
            .expand((emb) => emb!.rawValues())
            .toList();
    }
  }

  EmbeddingStats _calculateEmbeddingStats(List<List<double>> embeddings) {
    Matrix matrix = Matrix.fromList(embeddings);
    int n = embeddings.length;
    Vector mean = matrix.reduceRows((acc, column) =>
            Vector.fromList(List.generate(acc.length, (index) => acc.elementAt(index) + column.elementAt(index)))) /
        n;
    // TODO Not sure about these..
    Vector variance = matrix.reduceRows((acc, column) => Vector.fromList(List.generate(
            acc.length, (index) => acc.elementAt(index) + pow(column.elementAt(index) - mean.elementAt(index), 2)))) /
        n;
    Vector stdDev = variance.sqrt();
// Calculate min and max
    Vector minimum = matrix.reduceRows((acc, column) =>
        Vector.fromList(List.generate(acc.length, (index) => min(acc.elementAt(index), column.elementAt(index)))));

    Vector maximum = matrix.reduceRows((acc, column) =>
        Vector.fromList(List.generate(acc.length, (index) => max(acc.elementAt(index), column.elementAt(index)))));

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
