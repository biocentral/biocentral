import 'package:biocentral/plugins/prediction_models/model/prediction_protocol.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

@immutable
class PredictionModel extends Equatable {
  final Map<String, dynamic>? config;
  final String? databaseType;
  final Map<String, dynamic>? derivedValues;
  final Map<String, TrainingResult>? trainingResults;
  final Map<String, TestResult>? testResults;

  final List<String> trainingLogs;
  final Map<String, Uint8List> checkpoints;

  final BiocentralTaskStatus? trainingStatus;

  // TODO final Map<String, dynamic>? predictions;

  const PredictionModel({
    required this.config,
    required this.databaseType,
    required this.derivedValues,
    required this.trainingResults,
    required this.testResults,
    required this.trainingLogs,
    required this.checkpoints,
    required this.trainingStatus,
  });

  const PredictionModel.empty()
      : config = null,
        databaseType = null,
        derivedValues = null,
        trainingResults = null,
        testResults = null,
        trainingLogs = const [],
        checkpoints = const {},
        trainingStatus = null;

  static PredictionModel fromTrainingConfig(Map<String, dynamic> trainingConfig) {
    return PredictionModel(
      config: trainingConfig,
      databaseType: null,
      derivedValues: null,
      trainingResults: null,
      testResults: null,
      trainingLogs: const [],
      checkpoints: const {},
      trainingStatus: null,
    );
  }

  static PredictionModel? fromMap(Map<String, dynamic> map) {
    final config = map['config'];
    final databaseType = map['database_type'] ?? 'Protein';

    final derivedValues = map['derived_values'];
    Map<String, dynamic>? parsedDerivedValues;
    if (derivedValues != null) {
      parsedDerivedValues = Map<String, dynamic>.from(derivedValues);
    }

    final Map<String, TrainingResult> parsedTrainingResults = {};
    final trainingResults = Map<String, dynamic>.from(map['training_results'] ?? {});
    if (trainingResults.isNotEmpty) {
      for (final (splitName, resultMap) in trainingResults.entriesRecord) {
        final trainingResult = TrainingResult.fromMap(Map<String, dynamic>.from(resultMap));
        if (trainingResult != null) {
          parsedTrainingResults[splitName] = trainingResult;
        }
      }
    }

    final Map<String, TestResult> parsedTestResults = {};
    final testResults = Map<String, dynamic>.from(map['test_results'] ?? {});
    if (testResults.isNotEmpty) {
      for (final (testSetName, testSetMap) in testResults.entriesRecord) {
        final testResult = TestResult.fromMap(Map<String, dynamic>.from(testSetMap ?? {}));
        if (testResult != null) {
          parsedTestResults[testSetName] = testResult;
        }
      }
    }

    final trainingLogs = map['training_logs'] ?? <String>[];
    final trainingStatus = BiocentralTaskStatus.finished;
    return PredictionModel(
      config: config != null ? Map<String, dynamic>.from(config) : null,
      databaseType: databaseType,
      derivedValues: parsedDerivedValues,
      trainingResults: parsedTrainingResults,
      testResults: parsedTestResults,
      trainingLogs: trainingLogs,
      checkpoints: {},
      trainingStatus: trainingStatus,
    );
  }

  PredictionModel addLogs(List<String> logs) {
    return copyWith(trainingLogs: Set<String>.from((trainingLogs)..addAll(logs)).toList());
  }

  PredictionModel addCheckpoints(Map<String, Uint8List> checkpoints) {
    return copyWith(
      checkpoints: Map<String, Uint8List>.from(this.checkpoints)..addAll(checkpoints),
    );
  }

  PredictionModel copyWith({
    config,
    databaseType,
    derivedValues,
    trainingResults,
    testResults,
    trainingLogs,
    checkpoints,
    trainingStatus,
  }) {
    return PredictionModel(
        config: config ?? this.config,
        databaseType: databaseType ?? this.databaseType,
        derivedValues: derivedValues ?? this.derivedValues,
        trainingResults: trainingResults ?? this.trainingResults,
        testResults: testResults ?? this.testResults,
        trainingLogs: trainingLogs ?? this.trainingLogs,
        checkpoints: checkpoints ?? this.checkpoints,
        trainingStatus: trainingStatus ?? this.trainingStatus);
  }

  PredictionModel updateFromDTO(TaskDTO taskDTO) {
    final outputData = taskDTO.biotrainerUpdate;
    if (outputData == null) {
      return this;
    }

    PredictionModel updatedModel = this;
    final config = outputData.config?.toMap().map((k, v) => MapEntry(k, v.toString()));
    if (config != null) {
      updatedModel = updatedModel.copyWith(config: this.config?.merge<String, String>(config) ?? config);
    }
    final derivedValues = outputData.derivedValues?.toMap().map((k, v) => MapEntry(k, v.toString()));
    if (derivedValues != null) {
      updatedModel = updatedModel.copyWith(
          derivedValues: this.derivedValues?.merge<String, dynamic>(derivedValues) ?? derivedValues);
    }

    // TODO Not included in DTO yet
    final databaseType = 'Protein';
    updatedModel = updatedModel.copyWith(databaseType: databaseType);

    final trainingIterations = outputData.trainingIteration?.toList();
    if (trainingIterations != null && trainingIterations.isNotEmpty) {
      final splitName = trainingIterations[0].toString();
      final epochMetrics = trainingIterations[1];

      // TODO Parse EpochMetrics

      final existingTrainingResult = trainingResults?[splitName] ?? TrainingResult.empty();
      final updatedTrainingResult =
          existingTrainingResult.update(epochMetrics?.asMap.map((k, v) => MapEntry(k.toString(), v)) ?? {});
      if (updatedTrainingResult != null) {
        // TODO Error handling
        final newTrainingResults = Map<String, TrainingResult>.from(trainingResults ?? {});
        newTrainingResults[splitName] = updatedTrainingResult;
        updatedModel = updatedModel.copyWith(trainingResults: newTrainingResults);
      }
    }

    final testResults =
        outputData.testResults?.toMap().map((k, v) => MapEntry(k, Map<String, dynamic>.from(v?.asMap ?? {})));
    final updatedTestResults = Map<String, TestResult>.from(this.testResults ?? {});
    if (testResults != null) {
      for (final (testSetName, testSetResult) in testResults.entriesRecord) {
        final parsedTestSetResult = TestResult.fromMap(testSetResult);
        if (parsedTestSetResult != null) {
          updatedTestResults[testSetName] = parsedTestSetResult;
        }
      }
    }
    updatedModel = updatedModel.copyWith(testResults: updatedTestResults);

    return updatedModel;
  }

  // Getters for commonly used values
  String? get embedderName => config?['embedder_name'];

  String? get modelChoice => config?['model_choice'];

  String? get modelHash => derivedValues?['model_hash'];

  TrainingResult? get holdOutResult => trainingResults?['hold_out'];

  TestResult? get defaultTestResult => testResults?['test'];

  PredictionProtocol? get protocol =>
      enumFromString<PredictionProtocol>(config?['protocol'], PredictionProtocol.values);

  String getReadableModelID() {
    String modelID = '';
    modelID += '${modelHash?.substring(0, 4) ?? '????'}-';
    modelID += '${modelChoice ?? '?'}-';
    modelID += '${embedderName ?? '?'}-';
    modelID += (protocol?.name ?? '?');
    return modelID;
  }

  bool isEmpty() {
    return !isNotEmpty();
  }

  bool isNotEmpty() {
    return props.any((element) => element != null);
  }

  Map<String, String> getModelInformationMap() {
    return {
      'Embedder Name': embedderName ?? 'Unknown',
      'Architecture': modelChoice ?? 'Unknown',
      'Type': databaseType?.toString() ?? 'Unknown',
      'Training Protocol': protocol?.name ?? 'Unknown',
      'Model Hash': modelHash ?? 'Unknown',
    };
  }

  Map<String, dynamic> toMap({bool includeTrainingLogs = true}) {
    // Checkpoints are not included at the moment
    return {
      'config': config,
      'database_type': databaseType,
      'derived_values': derivedValues,
      'training_results': Map<String, dynamic>.from(
          trainingResults?.map((splitName, result) => MapEntry(splitName, result.toMap())) ?? {}),
      'test_results': Map<String, dynamic>.from(
          testResults?.map((testSetName, result) => MapEntry(testSetName, result.toMap())) ?? {}),
      if (includeTrainingLogs) 'training_logs': trainingLogs,
      'training_status': trainingStatus?.name,
    };
  }

  @override
  List<Object?> get props =>
      [config, databaseType, derivedValues, trainingResults, testResults, trainingLogs, trainingStatus];
}

class TrainingResult {
  final Map<int, double> trainingLoss;
  final Map<int, double> validationLoss;

  final int? bestEpoch;
  final Map<String, Set<BiocentralMLMetric>>? bestEpochMetrics; // Training + Validation

  final Map<String, dynamic>? metadata;

  TrainingResult({
    required this.trainingLoss,
    required this.validationLoss,
    required this.bestEpoch,
    required this.bestEpochMetrics,
    required this.metadata,
  });

  TrainingResult.empty()
      : trainingLoss = {},
        validationLoss = {},
        bestEpoch = null,
        bestEpochMetrics = null,
        metadata = null;

  static TrainingResult? fromMap(Map<String, dynamic> map) {
    final trainingLoss = Map<int, double>.from(
      (map['training_loss'] ?? {}).map((k, v) => MapEntry(int.parse(k), v)),
    );
    if (trainingLoss.isEmpty) {
      return null;
    }
    final Map<int, double> validationLoss = Map<int, double>.from(
      (map['validation_loss'] ?? {}).map((k, v) => MapEntry(int.parse(k), v)),
    );
    if (validationLoss.isEmpty) {
      return null;
    }
    final Map<String, dynamic> bestTrainingEpochMetrics =
        Map<String, dynamic>.from(map['best_training_epoch_metrics'] ?? {});
    if (bestTrainingEpochMetrics.isEmpty) {
      return null;
    }
    final int? bestEpoch = int.tryParse(bestTrainingEpochMetrics['epoch'].toString() ?? '');
    if (bestEpoch == null) {
      return null;
    }
    final bestEpochMetrics = {'training': <BiocentralMLMetric>{}, 'validation': <BiocentralMLMetric>{}};
    for (final splitType in ['training', 'validation']) {
      final splitMap = Map<String, dynamic>.from(bestTrainingEpochMetrics[splitType] ?? {});
      for (final (metricName, metricValue) in splitMap.entriesRecord) {
        final mlMetric = BiocentralMLMetric.tryParse(metricName, metricValue.toString());
        if (mlMetric == null) {
          return null;
        }
        bestEpochMetrics[splitType]?.add(mlMetric);
      }
    }

    final metadata =
        map.filterWithKey((k, v) => !['training_loss', 'validation_loss', 'best_training_epoch_metrics'].contains(k));

    return TrainingResult(
      trainingLoss: trainingLoss,
      validationLoss: validationLoss,
      bestEpoch: bestEpoch,
      bestEpochMetrics: bestEpochMetrics,
      metadata: metadata,
    );
  }

  TrainingResult? update(Map<String, dynamic> epochMetrics) {
    final epoch = int.tryParse(epochMetrics['epoch'].toString());
    final trainingLossUpdate = epochMetrics['training']?['loss'];
    final validationLossUpdate = epochMetrics['validation']?['loss'];

    if (epoch == null || trainingLossUpdate == null || validationLossUpdate == null) {
      return null;
    }
    return copyWith(
        trainingLoss: trainingLoss..addAll({epoch: trainingLossUpdate}),
        validationLoss: validationLoss..addAll({epoch: validationLossUpdate}));
  }

  TrainingResult copyWith({
    trainingLoss,
    validationLoss,
    bestEpoch,
    bestEpochMetrics,
    metadata,
  }) {
    return TrainingResult(
        trainingLoss: trainingLoss ?? this.trainingLoss,
        validationLoss: validationLoss ?? this.validationLoss,
        bestEpoch: bestEpoch ?? this.bestEpoch,
        bestEpochMetrics: bestEpochMetrics ?? this.bestEpochMetrics,
        metadata: metadata ?? this.metadata);
  }

  int getLastEpoch() {
    return trainingLoss.keys.max;
  }

  Map<String, dynamic> toMap() {
    final result = Map<String, dynamic>.of(metadata ?? {});
    result.addAll({
      'training_loss': trainingLoss.map((epoch, loss) => MapEntry(epoch.toString(), loss)),
      'validation_loss': validationLoss.map((epoch, loss) => MapEntry(epoch.toString(), loss)),
    });
    return result;
  }
}

class TestResult {
  final Set<BiocentralMLMetric> metrics;
  final Set<String> sanityCheckWarnings;
  final Map<String, Set<BiocentralMLMetric>> baselineMetrics;

  TestResult({
    required this.metrics,
    required this.sanityCheckWarnings,
    required this.baselineMetrics,
  });

  static Set<BiocentralMLMetric> _parseBootstrapping(Map<String, dynamic> bootstrappingMap) {
    final Set<BiocentralMLMetric> result = {};
    final resultMap = Map<String, dynamic>.from(bootstrappingMap['results'] ?? {});

    for (final (metricName, metricMap) in resultMap.entriesRecord) {
      final mean = metricMap?['mean'];
      if (mean == null) {
        continue;
      }

      final mlMetric = BiocentralMLMetric(
        name: metricName,
        value: mean,
        uncertaintyEstimate: UncertaintyEstimate.fromMap(
          Map.from(bootstrappingMap)
            ..addAll(Map.from(metricMap))
            ..addAll({'method': 'bootstrapping'}),
        ),
      );
      result.add(mlMetric);
    }

    return result;
  }

  static TestResult? fromMap(Map<String, dynamic> map) {
    final Set<BiocentralMLMetric> parsedMetrics = {};
    final String defaultUncertaintyMethod = 'bootstrapping';
    final bootstrappingMap = Map<String, dynamic>.from(map[defaultUncertaintyMethod] ?? {});

    if (bootstrappingMap.isNotEmpty) {
      final bootstrappingResult = TestResult._parseBootstrapping(bootstrappingMap);
      parsedMetrics.addAll(bootstrappingResult);
    } else {
      final Map<String, dynamic> testSetMetrics = map['metrics'] ?? {};
      for (final (metricName, metricValue) in testSetMetrics.entriesRecord) {
        final mlMetric = BiocentralMLMetric.tryParse(metricName, metricValue.toString());
        if (mlMetric == null) {
          continue;
        }
        parsedMetrics.add(mlMetric);
      }
    }

    if (parsedMetrics.isEmpty) {
      return null;
    }

    final Set<String> sanityCheckWarnings = Set<String>.from(map['sanity_check_warnings'] ?? []);

    final Map<String, Set<BiocentralMLMetric>> parsedBaselineMetrics = {};

    final baselinesMap = Map<String, dynamic>.from(map['test_baselines'] ?? {});

    if (baselinesMap.isNotEmpty) {
      for (final (baselineName, baselineResultMap) in baselinesMap.entriesRecord) {
        final bootstrappingResult = TestResult._parseBootstrapping(Map<String, dynamic>.from(baselineResultMap ?? {}));
        if (bootstrappingResult.isNotEmpty) {
          parsedBaselineMetrics[baselineName] = bootstrappingResult;
        }
      }
    }

    return TestResult(
      metrics: parsedMetrics,
      sanityCheckWarnings: sanityCheckWarnings,
      baselineMetrics: parsedBaselineMetrics,
    );
  }

  static Map<String, dynamic> _convertToBootstrapping(Set<BiocentralMLMetric> metrics) {
    // TODO Simplify with uncertaintyEstimate toMap()
    final Map<String, dynamic> bootstrapping = {};
    final uncertaintyEstimate =
        metrics.firstWhereOrNull((metric) => metric.uncertaintyEstimate != null)?.uncertaintyEstimate;
    if (uncertaintyEstimate != null) {
      final bootstrappingParameters = {
        'iterations': uncertaintyEstimate.iterations,
        'sample_size': uncertaintyEstimate.sampleSize,
        'confidence_level': uncertaintyEstimate.confidenceLevel,
      };
      bootstrapping['results'] = Map<String, dynamic>.fromEntries(
        metrics.map(
          (metric) => MapEntry(metric.name, {
            'mean': metric.uncertaintyEstimate?.mean,
            'lower': metric.uncertaintyEstimate?.lower,
            'upper': metric.uncertaintyEstimate?.upper
          }),
        ),
      );
      bootstrapping.addAll(bootstrappingParameters);
    }
    return bootstrapping;
  }

  Map<String, dynamic> toMap() {
    return {
      'metrics': Map<String, dynamic>.fromEntries(metrics.map((metric) => MapEntry(metric.name, metric.value))),
      'bootstrapping': _convertToBootstrapping(metrics),
      'test_baselines': Map<String, dynamic>.from(baselineMetrics.map(
          (baselineName, baselineMetricSet) => MapEntry(baselineName, _convertToBootstrapping(baselineMetricSet)))),
      'sanity_check_warnings': sanityCheckWarnings.toList(),
    };
  }
}
