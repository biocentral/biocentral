import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_protocol.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
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
    return PredictionModel(
      config: config,
      databaseType: databaseType,
      derivedValues: derivedValues,
      trainingResults: trainingResults,
      testResults: testResults,
      trainingLogs: Set<String>.from((trainingLogs)..addAll(logs)).toList(),
      checkpoints: checkpoints,
      trainingStatus: trainingStatus,
    );
  }

  PredictionModel addCheckpoints(Map<String, Uint8List> checkpoints) {
    return PredictionModel(
      config: config,
      databaseType: databaseType,
      derivedValues: derivedValues,
      trainingResults: trainingResults,
      testResults: testResults,
      trainingLogs: trainingLogs,
      checkpoints: (this.checkpoints ?? {})..addAll(checkpoints),
      trainingStatus: trainingStatus,
    );
  }

  PredictionModel updateStatus(BiocentralTaskStatus status) {
    return PredictionModel(
      config: config,
      databaseType: databaseType,
      derivedValues: derivedValues,
      trainingResults: trainingResults,
      testResults: testResults,
      trainingLogs: trainingLogs,
      checkpoints: checkpoints,
      trainingStatus: status,
    );
  }

  PredictionModel merge(PredictionModel? other, {required bool failOnConflict}) {
    if (other == null) {
      return this;
    }

    final String? databaseTypeMerged = nullableMerge(
      databaseType,
      other.databaseType,
      'Could not merge prediction models due to a conflict in their database types!',
      failOnConflict,
    );

    final String? configStringMerged = nullableMerge(
      config != null ? jsonEncode(config) : null,
      other.config != null ? jsonEncode(other.config) : null,
      'Could not merge prediction models due to a conflict in their training configs!',
      failOnConflict,
    );

    final Map<String, dynamic>? configMerged = configStringMerged != null ? jsonDecode(configStringMerged) : null;

    // TODO Check for conflicts
    final derivedValuesMerged = derivedValues ?? other.derivedValues;
    final trainingResultsMerged = trainingResults ?? other.trainingResults;
    final testResultsMerged = testResults ?? other.testResults;
    final trainingStatusMerged = trainingStatus ?? other.trainingStatus;

    final trainingLogsMerged = Set<String>.from(trainingLogs..addAll(other.trainingLogs)).toList();
    final Map<String, Uint8List> checkpointsMerged = checkpoints..addAll(other.checkpoints);

    return PredictionModel(
      config: configMerged,
      databaseType: databaseTypeMerged,
      derivedValues: derivedValuesMerged,
      trainingResults: trainingResultsMerged,
      testResults: testResultsMerged,
      trainingLogs: trainingLogsMerged,
      checkpoints: checkpointsMerged,
      trainingStatus: trainingStatusMerged,
    );
  }

  PredictionModel updateFromDTO(BiocentralDTO dto) {
    return this; // TODO
  }

  // Getters for commonly used values
  String? get embedderName => config?['embedder_name'];

  String? get modelChoice => config?['model_choice'];

  String? get modelHash => derivedValues?['model_hash'];

  TrainingResult? get holdOutResult => trainingResults?['hold_out'];

  TestResult? get defaultTestResult => testResults?['test'];

  PredictionProtocol? get protocol =>
      enumFromString<PredictionProtocol>(config?['protocol'], PredictionProtocol.values);

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
    };
  }

  Map<String, dynamic> toMap({bool includeTrainingLogs = true}) {
    // Checkpoints are not included at the moment
    // TODO Make this to parse to biotrainer format exactly
    return {
      'config': config,
      'database_type': databaseType,
      'derived_values': derivedValues,
      'training_results': trainingResults.toString(),  // TODO Convert to map properly
      'test_results': testResults.toString(), // TODO Convert to map properly
      if (includeTrainingLogs) 'training_logs': trainingLogs,
      'training_status': trainingStatus?.name,
    };
  }

  @override
  List<Object?> get props =>
      [config, databaseType, derivedValues, trainingResults, testResults, trainingLogs, trainingStatus];
}

/*
@immutable
class PredictionModel extends Equatable {
  final String? embedderName;
  final String? architecture;
  final String? databaseType;
  final PredictionProtocol? predictionProtocol;

  final Map<String, dynamic>? biotrainerTrainingConfig;
  final BiotrainerTrainingResult? biotrainerTrainingResult;

  final Map<String, Uint8List>? biotrainerCheckpoints;

  const PredictionModel({
    required this.embedderName,
    required this.architecture,
    required this.databaseType,
    required this.predictionProtocol,
    required this.biotrainerTrainingConfig,
    required this.biotrainerTrainingResult,
    required this.biotrainerCheckpoints,
  });

  const PredictionModel.empty()
      : embedderName = null,
        architecture = null,
        databaseType = null,
        predictionProtocol = null,
        biotrainerTrainingConfig = null,
        biotrainerTrainingResult = null,
        biotrainerCheckpoints = null;

  static PredictionModel? fromMap(Map<String, dynamic> map) {
    final String? embedderName = map['embedder_name'] ?? map['embedderName'];
    final String databaseType = map['databaseType'] ?? map ['database_type'] ??
        (map['interaction'] != null && map['interaction'] != ''
            ? const ProteinProteinInteraction.empty().typeName
            : const Protein.empty().typeName);
    final PredictionProtocol? predictionProtocol =
        enumFromString<PredictionProtocol>(map['protocol'], PredictionProtocol.values);

    final Map<String, dynamic>? trainingConfig = map['trainingConfig'] ?? map['training_config'];
    final String? architecture = map['model_choice'] ?? map['modelChoice'] ?? trainingConfig?['model_choice'];

    final trainingResult = BiotrainerTrainingResult.fromMap(map['trainingResult'] ?? map['training_result'] ?? {});

    return PredictionModel(
      embedderName: embedderName,
      architecture: architecture,
      databaseType: databaseType,
      predictionProtocol: predictionProtocol,
      biotrainerTrainingConfig: trainingConfig,
      biotrainerTrainingResult: trainingResult,
      biotrainerCheckpoints: null,
    );
  }

  PredictionModel updateFromDTO(BiocentralDTO dto) {
    final trainingLog = dto.logFile;
    final trainingStatus = dto.taskStatus;

    final newLogs = (biotrainerTrainingResult?.trainingLogs ?? []).join('\n') + (trainingLog ?? '');
    final newResult = BiotrainerLogFileHandler.parseBiotrainerLog(
      trainingLog: newLogs,
      trainingStatus: trainingStatus,
    );
    return copyWith(biotrainerTrainingResult: newResult);
  }

  PredictionModel copyWith({
    embedderName,
    architecture,
    databaseType,
    predictionProtocol,
    biotrainerTrainingConfig,
    biotrainerTrainingResult,
    biotrainerTrainingLog,
    biotrainerCheckpoints,
  }) {
    return PredictionModel(
      embedderName: embedderName ?? this.embedderName,
      architecture: architecture ?? this.architecture,
      databaseType: databaseType ?? this.databaseType,
      predictionProtocol: predictionProtocol ?? this.predictionProtocol,
      biotrainerTrainingConfig: biotrainerTrainingConfig ?? this.biotrainerTrainingConfig,
      biotrainerTrainingResult: biotrainerTrainingResult ?? this.biotrainerTrainingResult,
      biotrainerCheckpoints: biotrainerCheckpoints ?? this.biotrainerCheckpoints,
    );
  }

  PredictionModel merge(PredictionModel? other, {required bool failOnConflict}) {
    if (other == null) {
      return this;
    }

    final String? embedderNameMerged = nullableMerge(
      embedderName,
      other.embedderName,
      'Could not merge prediction models due to a conflict in their embedderNames!',
      failOnConflict,
    );
    final String? architectureMerged = nullableMerge(
      architecture,
      other.architecture,
      'Could not merge prediction models due to a conflict in their architecture!',
      failOnConflict,
    );
    final String? databaseTypeMerged = nullableMerge(
      databaseType,
      other.databaseType,
      'Could not merge prediction models due to a conflict in their database types!',
      failOnConflict,
    );
    final PredictionProtocol? predictionProtocolMerged = nullableMerge(
      predictionProtocol,
      other.predictionProtocol,
      'Could not merge prediction models due to a conflict in their prediction protocols!',
      failOnConflict,
    );

    final String? configStringMerged = nullableMerge(
      biotrainerTrainingConfig != null ? jsonEncode(biotrainerTrainingConfig) : null,
      other.biotrainerTrainingConfig != null ? jsonEncode(other.biotrainerTrainingConfig) : null,
      'Could not merge prediction models due to a conflict in their training configs!',
      failOnConflict,
    );

    final Map<String, dynamic>? biotrainerTrainingConfigMerged =
        configStringMerged != null ? jsonDecode(configStringMerged) : null;

    final BiotrainerTrainingResult? biotrainerTrainingResultMerged = nullableMerge(
      biotrainerTrainingResult,
      other.biotrainerTrainingResult,
      'Could not merge prediction models due to a conflict in their training results!',
      failOnConflict,
    );

    final Map<String, Uint8List> biotrainerCheckpointsMerged = biotrainerCheckpoints ?? {};
    biotrainerCheckpointsMerged.addAll(other.biotrainerCheckpoints ?? {});
    return PredictionModel(
      embedderName: embedderNameMerged,
      architecture: architectureMerged,
      databaseType: databaseTypeMerged,
      predictionProtocol: predictionProtocolMerged,
      biotrainerTrainingConfig: biotrainerTrainingConfigMerged,
      biotrainerTrainingResult: biotrainerTrainingResultMerged,
      biotrainerCheckpoints: biotrainerCheckpointsMerged.isNotEmpty ? biotrainerCheckpointsMerged : null,
    );
  }

  PredictionModel setTraining() {
    final trainingResult = biotrainerTrainingResult ?? BiotrainerTrainingResult.empty();
    return copyWith(biotrainerTrainingResult: trainingResult.copyWith(trainingStatus: BiocentralTaskStatus.running));
  }

  bool isEmpty() {
    return !isNotEmpty();
  }

  bool isNotEmpty() {
    return props.any((element) => element != null);
  }

  Map<String, dynamic> toMap({bool includeTrainingLogs = true}) {
    // Checkpoints are not included at the moment
    return {
      'embedder_name': embedderName,
      'architecture': architecture,
      'database_type': databaseType,
      'protocol': predictionProtocol?.name,
      'training_config': biotrainerTrainingConfig,
      'training_result': biotrainerTrainingResult?.toMap(includeTrainingLogs: includeTrainingLogs),
    };
  }

  Map<String, String> getModelInformationMap() {
    return {
      'Embedder Name': embedderName ?? 'Unknown',
      'Architecture': architecture ?? 'Unknown',
      'Type': databaseType?.toString() ?? 'Unknown',
      'Training Protocol': predictionProtocol?.name ?? 'Unknown',
    };
  }

  @override
  List<Object?> get props => [
        embedderName,
        architecture,
        databaseType,
        predictionProtocol,
        biotrainerTrainingConfig,
        biotrainerTrainingResult,
        biotrainerCheckpoints,
      ];
}
*/

class TrainingResult {
  final Map<int, double> trainingLoss;
  final Map<int, double> validationLoss;

  final int bestEpoch;
  final Map<String, Set<BiocentralMLMetric>> bestEpochMetrics; // Training + Validation

  final Map<String, dynamic> metadata;

  TrainingResult({
    required this.trainingLoss,
    required this.validationLoss,
    required this.bestEpoch,
    required this.bestEpochMetrics,
    required this.metadata,
  });

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

  int getLastEpoch() {
    return trainingLoss.keys.max;
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
    final iterations = bootstrappingMap['iterations'];
    final sampleSize = bootstrappingMap['sample_size'];
    final confidenceLevel = bootstrappingMap['confidence_level'];
    if (iterations != null && sampleSize != null && confidenceLevel != null) {
      final resultMap = Map<String, dynamic>.from(bootstrappingMap['results'] ?? {});
      for (final (metricName, metricMap) in resultMap.entriesRecord) {
        final meanValue = metricMap?['mean'];
        final error = metricMap?['error'];
        if (meanValue == null || error == null) {
          continue;
        }
        final mlMetric = BiocentralMLMetric(
          name: metricName,
          value: meanValue,
          uncertaintyEstimate: UncertaintyEstimate(
            method: 'bootstrapping',
            mean: meanValue,
            error: error,
            iterations: iterations,
            sampleSize: sampleSize,
            confidenceLevel: confidenceLevel,
          ),
        );
        result.add(mlMetric);
      }
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
        final mlMetric = BiocentralMLMetric.tryParse(metricName, metricValue);
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
}
