import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:biocentral/sdk/model/biocentral_config_option.dart';
import 'package:collection/collection.dart';

class PredictionModelsServiceEndpoints {
  static const String protocols = '/prediction_models_service/protocols';
  static const String configOptions = '/prediction_models_service/config_options/';
  static const String verifyConfig = '/prediction_models_service/verify_config/';
  static const String startTraining = '/prediction_models_service/start_training';
  static const String startInference = '/prediction_models_service/start_inference';
  static const String trainingStatus = '/prediction_models_service/training_status';
  static const String modelFiles = '/prediction_models_service/model_files';
}

List<BiocentralConfigOption> filterBiotrainerOptionsForBiocentral(List<BiocentralConfigOption> options) {
  const Set<String> ignoreCategories = {'input_files'};
  const Set<String> ignoreNames = {
    'device',
    'embeddings_file',
    'ignore_file_inconsistencies',
    'pretrained_model',
    'auto_resume',
    'embedder_name', // Handled separately
    'model_choice', // Handled separately
  };
  return options
      .where((option) => !ignoreCategories.contains(option.category) && !ignoreNames.contains(option.name))
      .toList();
}

Set<String> getAvailableModelsFromBiotrainerConfig(List<BiocentralConfigOption> config) {
  return config
          .firstWhere((biocentralOption) => biocentralOption.name == 'model_choice')
          .constraints
          ?.allowedValues
          ?.map((allowed) => allowed.toString())
          .toSet() ??
      {};
}

class BiotrainerTrainingResult implements Comparable<BiotrainerTrainingResult> {
  final Map<int, double> trainingLoss;
  final Map<int, double> validationLoss;
  final Set<BiocentralMLMetric> testSetMetrics;
  final Set<String> sanityCheckWarnings;
  final Map<String, Set<BiocentralMLMetric>> baselineMetrics;
  final List<String> trainingLogs;
  final BiocentralTaskStatus trainingStatus;

  BiotrainerTrainingResult({
    required this.trainingLoss,
    required this.validationLoss,
    required this.testSetMetrics,
    required this.sanityCheckWarnings,
    required this.baselineMetrics,
    required this.trainingLogs,
    required this.trainingStatus,
  });

  BiotrainerTrainingResult.empty()
      : trainingLoss = const {},
        validationLoss = const {},
        testSetMetrics = const {},
        sanityCheckWarnings = const {},
        baselineMetrics = const {},
        trainingLogs = const [],
        trainingStatus = BiocentralTaskStatus.running;

  static BiotrainerTrainingResult? fromMap(Map<String, dynamic> map) {
    final Map<int, double> trainingLoss = Map<int, double>.from(
      (map['trainingLoss'] ?? map['training_loss'] ?? {}).map((k, v) => MapEntry(int.parse(k), v)),
    );
    final Map<int, double> validationLoss = Map<int, double>.from(
      (map['validationLoss'] ?? map['validation_loss'] ?? {}).map((k, v) => MapEntry(int.parse(k), v)),
    );
    final List<dynamic> testSetMetrics = map['testSetMetrics'] ?? map['test_set_metrics'] ?? [];
    final Set<String> sanityCheckWarnings = Set<String>.from(map['sanityCheckWarnings'] ?? []);
    final Map<String, dynamic> baselineMetrics = map['baselineMetrics'] ?? map['baseline_metrics'] ?? {};
    final List<String> trainingLogs = List<String>.from(map['trainingLogs'] ?? map['training_logs'] ?? []);
    final trainingStatus = enumFromString(map['trainingStatus'] ?? map['training_status'], BiocentralTaskStatus.values);

    if (trainingStatus == null) {
      return null;
    }

    final convertedTestSetMetrics =
        testSetMetrics.map((element) => BiocentralMLMetric.fromMap(element)).whereType<BiocentralMLMetric>().toSet();
    final Map<String, Set<BiocentralMLMetric>> convertedBaselineMetrics = baselineMetrics.map(
      (k, v) =>
          MapEntry(k, v.map((element) => BiocentralMLMetric.fromMap(element)).whereType<BiocentralMLMetric>().toSet()),
    );
    return BiotrainerTrainingResult(
      trainingLoss: trainingLoss,
      validationLoss: validationLoss,
      testSetMetrics: convertedTestSetMetrics,
      sanityCheckWarnings: sanityCheckWarnings,
      baselineMetrics: convertedBaselineMetrics,
      trainingLogs: trainingLogs,
      trainingStatus: trainingStatus,
    );
  }

  BiotrainerTrainingResult copyWith({
    Map<int, double>? trainingLoss,
    Map<int, double>? validationLoss,
    Set<BiocentralMLMetric>? testSetMetrics,
    Set<String>? sanityCheckWarnings,
    Map<String, Set<BiocentralMLMetric>>? sanityCheckBaselineMetrics,
    List<String>? trainingLogs,
    BiocentralTaskStatus? trainingStatus,
  }) {
    return BiotrainerTrainingResult(
      trainingLoss: trainingLoss ?? Map.from(this.trainingLoss),
      validationLoss: validationLoss ?? Map.from(this.validationLoss),
      testSetMetrics: testSetMetrics ?? Set.from(this.testSetMetrics),
      sanityCheckWarnings: sanityCheckWarnings ?? Set.from(this.sanityCheckWarnings),
      baselineMetrics: sanityCheckBaselineMetrics ??
          Map.fromEntries(
            this.baselineMetrics.entries.map((entry) => MapEntry(entry.key, Set.from(entry.value))),
          ),
      trainingLogs: trainingLogs ?? List.from(this.trainingLogs),
      trainingStatus: trainingStatus ?? this.trainingStatus,
    );
  }

  int? getLastEpoch() {
    return trainingLoss.keys.maxOrNull;
  }

  Map<String, dynamic> toMap({bool includeTrainingLogs = true}) {
    final result = {
      'trainingLoss': trainingLoss.map((k, v) => MapEntry(k.toString(), v)),
      'validationLoss': validationLoss.map((k, v) => MapEntry(k.toString(), v)),
      'testSetMetrics': testSetMetrics.map((metric) => metric.toMap()).toList(),
      'sanityCheckWarnings': sanityCheckWarnings.toList(),
      'baselineMetrics': baselineMetrics.map((k, v) => MapEntry(k, v.map((metric) => metric.toMap()).toList())),
      'trainingStatus': trainingStatus.name,
    };
    if (includeTrainingLogs) {
      result.addAll({'trainingLogs': trainingLogs});
    }
    return result;
  }

  @override
  int compareTo(BiotrainerTrainingResult other) {
    return this == other ? 0 : -1;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiotrainerTrainingResult &&
          runtimeType == other.runtimeType &&
          trainingLoss == other.trainingLoss &&
          validationLoss == other.validationLoss &&
          testSetMetrics == other.testSetMetrics &&
          sanityCheckWarnings == other.sanityCheckWarnings &&
          baselineMetrics == other.baselineMetrics;

  @override
  int get hashCode => testSetMetrics.hashCode ^ sanityCheckWarnings.hashCode ^ baselineMetrics.hashCode;
}
