import 'dart:convert';
import 'dart:typed_data';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:yaml/yaml.dart';

class BiotrainerFileHandler {
  static CustomAttributes _addOrUpdateCustomAttribute(CustomAttributes attributes, Map keyVals) {
    CustomAttributes result = attributes;
    for (var entry in keyVals.entries) {
      try {
        result = result.add(entry.key.toString(), entry.value.toString());
      } catch (Exception) {
        result = result.update(entry.key.toString(), entry.value.toString());
      }
    }
    return result;
  }

  static Future<(String, String, String)> getBiotrainerInputFiles(
    Type databaseType,
    Map<String, dynamic> entryMap,
    String targetColumn,
    String setColumn,
  ) async {
    String sequenceFile = '';
    // TODO Improve target setting
    switch (databaseType) {
      case Protein:
        {
          final handler = BioFileHandler<Protein>().create('fasta');
          sequenceFile = await handler.convertToString(
                entryMap.map(
                  (key, value) => MapEntry(
                    key,
                    (value as Protein).copyWith(
                      attributes: _addOrUpdateCustomAttribute(
                        value.attributes,
                        {'TARGET': value.toMap()[targetColumn] ?? '', 'SET': value.toMap()[setColumn] ?? ''},
                      ),
                    ),
                  ),
                ),
              ) ??
              '';
          break;
        }
      case ProteinProteinInteraction:
        {
          final handler = BioFileHandler<ProteinProteinInteraction>().create('fasta');
          sequenceFile = await handler.convertToString(
                entryMap.map(
                  (key, value) => MapEntry(
                    key,
                    (value as ProteinProteinInteraction).copyWith(
                      attributes: _addOrUpdateCustomAttribute(
                        value.attributes,
                        {'TARGET': value.toMap()[targetColumn] ?? '', 'SET': value.toMap()[setColumn] ?? ''},
                      ),
                    ),
                  ),
                ),
              ) ??
              '';
          break;
        }
    }
    // TODO residue_to_ protocols
    final String labelsFile = '';
    final String maskFile = '';
    return (sequenceFile, labelsFile, maskFile);
  }

  static String biotrainerConfigurationToConfigFile(Map<String, String> biotrainerConfiguration) {
    String result = '';
    for (String key in biotrainerConfiguration.keys) {
      if (biotrainerConfiguration[key] != '' && !key.contains('column')) {
        result += '$key:';
        result += '${biotrainerConfiguration[key]!}\n';
      }
    }
    return result;
  }

  static PredictionModel parsePredictionModelFromRawFiles({
    required bool failOnConflict,
    String? biotrainerConfig,
    String? biotrainerOutput,
    String? biotrainerTrainingLog,
    Map<String, dynamic>? biotrainerCheckpoints,
  }) {
    Map<String, dynamic>? parsedConfigFile;
    if (biotrainerConfig != null) {
      final YamlMap parsedConfigYaml = loadYaml(biotrainerConfig);
      parsedConfigFile = Map<String, dynamic>.from(parsedConfigYaml.value);
    }
    Map<String, dynamic>? parsedOutputFile;
    if (biotrainerOutput != null) {
      final YamlMap parsedOutputFileYaml = loadYaml(biotrainerOutput);
      parsedOutputFile = Map<String, dynamic>.from(parsedOutputFileYaml.value);
    }
    Map<String, Uint8List>? parsedBiotrainerCheckpoints;
    if (biotrainerCheckpoints != null) {
      parsedBiotrainerCheckpoints = {};
      for (MapEntry<String, dynamic> checkpoint in biotrainerCheckpoints.entries) {
        final Uint8List checkpointBytes = base64Decode(checkpoint.value.toString());
        parsedBiotrainerCheckpoints[checkpoint.key] = checkpointBytes;
      }
    }
    return parsePredictionModel(
      biotrainerConfig: parsedConfigFile,
      biotrainerOutputMap: parsedOutputFile,
      biotrainerTrainingLog: biotrainerTrainingLog,
      biotrainerCheckpoints: parsedBiotrainerCheckpoints,
      failOnConflict: failOnConflict,
    );
  }

  static PredictionModel parsePredictionModel({
    required bool failOnConflict,
    Map<String, dynamic>? biotrainerConfig,
    Map<String, dynamic>? biotrainerOutputMap,
    String? biotrainerTrainingLog,
    Map<String, dynamic>? biotrainerCheckpoints,
  }) {
    PredictionModel result = const PredictionModel.empty();
    // Output file should have the highest authority => Loaded first
    if (biotrainerOutputMap != null) {
      result = result.merge(_predictionModelFromResultFile(biotrainerOutputMap), failOnConflict: failOnConflict);
    }
    // Output file and config file should have no contradictions => failOnConflict always true
    if (biotrainerConfig != null) {
      result = result.merge(_predictionModelFromBiotrainerConfig(biotrainerConfig), failOnConflict: true);
    }
    // Training log
    if (biotrainerTrainingLog != null) {
      final logs = biotrainerTrainingLog.split('\n');
      result = result.copyWith(
        biotrainerTrainingResult: parseBiotrainerLog(trainingLog: biotrainerTrainingLog),
        biotrainerTrainingLog: logs,
      );
    }
    // Checkpoints
    if (biotrainerCheckpoints != null) {
      result = result.copyWith(biotrainerCheckpoints: biotrainerCheckpoints);
    }
    return result;
  }

  static Set<BiocentralMLMetric> _parseMLMetricsMap(Map<String, dynamic> metricsMap) {
    final Set<BiocentralMLMetric> result = {};
    for (MapEntry<String, dynamic> mapEntry in metricsMap.entries) {
      final BiocentralMLMetric? mlMetric = BiocentralMLMetric.tryParse(mapEntry.key, mapEntry.value.toString());
      if (mlMetric == null) {
        logger.e('MLMetric could not be parsed: $mapEntry');
      } else {
        result.add(mlMetric);
      }
    }
    return result;
  }

  static BiotrainerTrainingResult parseBiotrainerLog(
      {required String trainingLog, BiocentralTaskStatus? trainingStatus}) {
    const String testSetMetricsIdentifier = 'INFO Test set metrics: ';
    const String sanityChecksStartIdentifier = 'INFO Running sanity checks on test results..';
    const String sanityChecksEndIdentifier = 'INFO Sanity check on test results finished!';
    const String warningStringSeparator = ' WARNING ';
    const String infoStringSeparator = ' INFO ';
    const String epochIdentifier = 'INFO Epoch ';
    const String trainingResultsIdentifier = 'INFO Training results';
    const String validationResultsIdentifier = 'INFO Validation results';
    const String lossIdentifier = '\tloss: ';

    Set<BiocentralMLMetric> parsedTestSetMetrics = {};
    final Set<String> parsedSanityCheckWarnings = {};
    final Map<String, Set<BiocentralMLMetric>> parsedSanityCheckBaselineMetrics = {};

    final Map<int, double> trainingLoss = {};
    final Map<int, double> validationLoss = {};

    bool inSanityCheckArea = false;
    bool inTrainingResults = false;
    bool inValidationResults = false;
    int currentEpoch = -1;

    // TODO [Optimization] Improve performance
    final bool parseResultMetrics =
        trainingStatus == BiocentralTaskStatus.finished || trainingLog.contains(testSetMetricsIdentifier);

    final logs = trainingLog.split('\n');
    for (String line in logs) {
      if (line.contains(epochIdentifier)) {
        currentEpoch = int.parse(line.split(epochIdentifier).last.trim());
        inTrainingResults = false;
        inValidationResults = false;
        continue;
      }
      if (line.contains(trainingResultsIdentifier)) {
        inTrainingResults = true;
        inValidationResults = false;
        continue;
      }
      if (line.contains(validationResultsIdentifier)) {
        inTrainingResults = false;
        inValidationResults = true;
        continue;
      }
      if (line.contains(lossIdentifier)) {
        final double? loss = double.tryParse(line.split(lossIdentifier).last.trim());
        if (inTrainingResults && loss != null) {
          trainingLoss[currentEpoch] = loss;
        } else if (inValidationResults && loss != null) {
          validationLoss[currentEpoch] = loss;
        }
        continue;
      }

      if (parseResultMetrics) {
        // Only parse result metrics after training is done
        if (line.contains(testSetMetricsIdentifier)) {
          final String metrics = line.split(testSetMetricsIdentifier).last;
          final Map<String, dynamic> metricsMap = jsonDecode(metrics.replaceAll("'", '"'));
          parsedTestSetMetrics = _parseMLMetricsMap(metricsMap);
          continue;
        }
        if (line.contains(sanityChecksStartIdentifier)) {
          inSanityCheckArea = true;
          continue;
        }
        if (line.contains(sanityChecksEndIdentifier)) {
          inSanityCheckArea = false;
          continue;
        }
        if (inSanityCheckArea) {
          if (line.contains(warningStringSeparator)) {
            final String sanityCheckWarning = line.split(warningStringSeparator).last;
            parsedSanityCheckWarnings.add(sanityCheckWarning);
          } else if (line.contains(infoStringSeparator)) {
            final List<String> baselineNameAndMetrics = line.split(infoStringSeparator).last.split(": {'");
            if (baselineNameAndMetrics.length != 2) {
              logger.e('Invalid sanity check line: $line');
              continue;
            }
            final String baselineName = baselineNameAndMetrics.first;
            final Map<String, dynamic> baselineMetricsMap =
                jsonDecode("{\"${baselineNameAndMetrics.last.replaceAll("'", "\"")}");
            final Set<BiocentralMLMetric> baselineMLMetrics = _parseMLMetricsMap(baselineMetricsMap);
            parsedSanityCheckBaselineMetrics[baselineName] = baselineMLMetrics;
          } else {
            logger.e('Invalid sanity check line: $line');
          }
        }
      }
    }
    final status = trainingStatus ??
        (parsedTestSetMetrics.isEmpty ? BiocentralTaskStatus.running : BiocentralTaskStatus.finished);

    final BiotrainerTrainingResult trainingResult = BiotrainerTrainingResult(
      trainingLoss: trainingLoss,
      validationLoss: validationLoss,
      testSetMetrics: parsedTestSetMetrics,
      sanityCheckWarnings: parsedSanityCheckWarnings,
      sanityCheckBaselineMetrics: parsedSanityCheckBaselineMetrics,
      trainingLogs: logs,
      trainingStatus: status,
    );

    return trainingResult;
  }

  static PredictionModel? predictionModelFromBiotrainerLog(Map<String, dynamic> configMap, String trainingLog) {
    return PredictionModel.fromMap(configMap)?.copyWith(
        biotrainerTrainingResult: parseBiotrainerLog(trainingLog: trainingLog), biotrainerTrainingLog: trainingLog);
  }

  static PredictionModel? _predictionModelFromBiotrainerConfig(Map<String, dynamic> configMap) {
    return PredictionModel.fromMap(configMap)?.copyWith(biotrainerTrainingConfig: configMap);
  }

  static PredictionModel? _predictionModelFromResultFile(Map<String, dynamic> parsedResultFile) {
    return PredictionModel.fromMap({
      'embedder_name': parsedResultFile['embedder_name'] ?? '',
      'model_choice': parsedResultFile['model_choice'] ?? '',
      'interaction': parsedResultFile['interaction'] ?? '',
      'protocol': parsedResultFile['protocol'] ?? '',
    });
  }
}
