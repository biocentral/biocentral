import 'dart:convert';
import 'dart:typed_data';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:yaml/yaml.dart';

import '../model/prediction_model.dart';
import 'prediction_models_service_api.dart';

class BiotrainerFileHandler {
  static Future<(String, String, String)> getBiotrainerInputFiles(
      Type databaseType, Map<String, dynamic> entryMap, String targetColumn, String setColumn) async {
    String sequenceFile = "";
    // TODO Improve target setting
    switch (databaseType) {
      case Protein:
        {
          var handler = BioFileHandler<Protein>().create("fasta");
          sequenceFile = await handler.convertToString(entryMap.map((key, value) => MapEntry(
                  key,
                  (value as Protein).copyWith(
                      attributes: value.attributes
                          .add("TARGET", value.toMap()[targetColumn] ?? "")
                          .add("SET", value.toMap()[setColumn] ?? ""))))) ??
              "";
          break;
        }
      case ProteinProteinInteraction:
        {
          var handler = BioFileHandler<ProteinProteinInteraction>().create("fasta");
          sequenceFile = await handler.convertToString(entryMap.map((key, value) => MapEntry(
                  key,
                  (value as ProteinProteinInteraction).copyWith(
                      attributes: value.attributes
                          .add("TARGET", value.toMap()[targetColumn] ?? "")
                          .update("SET", value.toMap()[setColumn] ?? ""))))) ??
              "";
          break;
        }
    }
    // TODO residue_to_ protocols
    String labelsFile = "";
    String maskFile = "";
    return (sequenceFile, labelsFile, maskFile);
  }

  static String biotrainerConfigurationToConfigFile(Map<String, String> biotrainerConfiguration) {
    String result = "";
    for (String key in biotrainerConfiguration.keys) {
      if (biotrainerConfiguration[key] != "" && !key.contains("column")) {
        result += "$key:";
        result += "${biotrainerConfiguration[key]!}\n";
      }
    }
    return result;
  }

  static PredictionModel parsePredictionModelFromRawFiles(
      {String? biotrainerConfig,
      String? biotrainerOutput,
      String? biotrainerTrainingLog,
      Map<String, dynamic>? biotrainerCheckpoints,
      required bool failOnConflict}) {
    Map<String, dynamic>? parsedConfigFile;
    if (biotrainerConfig != null) {
      YamlMap parsedConfigYaml = loadYaml(biotrainerConfig);
      parsedConfigFile = Map<String, dynamic>.from(parsedConfigYaml.value);
    }
    Map<String, dynamic>? parsedOutputFile;
    if (biotrainerOutput != null) {
      YamlMap parsedOutputFileYaml = loadYaml(biotrainerOutput);
      parsedOutputFile = Map<String, dynamic>.from(parsedOutputFileYaml.value);
    }
    List<String>? parsedLoggingFile;
    if (biotrainerTrainingLog != null) {
      parsedLoggingFile = biotrainerTrainingLog.split("\n");
    }
    Map<String, Uint8List>? parsedBiotrainerCheckpoints;
    if (biotrainerCheckpoints != null) {
      parsedBiotrainerCheckpoints = {};
      for (MapEntry<String, dynamic> checkpoint in biotrainerCheckpoints.entries) {
        Uint8List checkpointBytes = base64Decode(checkpoint.value.toString());
        parsedBiotrainerCheckpoints[checkpoint.key] = checkpointBytes;
      }
    }
    return parsePredictionModel(
        biotrainerConfig: parsedConfigFile,
        biotrainerOutputMap: parsedOutputFile,
        biotrainerTrainingLog: parsedLoggingFile,
        biotrainerCheckpoints: parsedBiotrainerCheckpoints,
        failOnConflict: failOnConflict);
  }

  static PredictionModel parsePredictionModel(
      {Map<String, dynamic>? biotrainerConfig,
      Map<String, dynamic>? biotrainerOutputMap,
      List<String>? biotrainerTrainingLog,
      Map<String, dynamic>? biotrainerCheckpoints,
      required bool failOnConflict}) {
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
      result = result.copyWith(
          biotrainerTrainingResult: _parseTrainingResultFromTrainingLog(biotrainerTrainingLog),
          biotrainerTrainingLog: biotrainerTrainingLog);
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
      BiocentralMLMetric? mlMetric = BiocentralMLMetric.tryParse(mapEntry.key, mapEntry.value.toString());
      if (mlMetric == null) {
        logger.e("MLMetric could not be parsed: $mapEntry");
      } else {
        result.add(mlMetric);
      }
    }
    return result;
  }

  static BiotrainerTrainingResult _parseTrainingResultFromTrainingLog(List<String> trainingLog) {
    const String testSetMetricsIdentifier = "INFO Test set metrics: ";
    const String sanityChecksStartIdentifier = "INFO Running sanity checks on test results..";
    const String sanityChecksEndIdentifier = "INFO Sanity check on test results finished!";
    const String warningStringSeparator = " WARNING ";
    const String infoStringSeparator = " INFO ";

    Set<BiocentralMLMetric> parsedTestSetMetrics = {};
    Set<String> parsedSanityCheckWarnings = {};
    Map<String, Set<BiocentralMLMetric>> parsedSanityCheckBaselineMetrics = {};

    bool inSanityCheckArea = false;
    for (String line in trainingLog) {
      // 1. Get test set metrics
      if (line.contains(testSetMetricsIdentifier)) {
        String metrics = line.split(testSetMetricsIdentifier).last;
        Map<String, dynamic> metricsMap = jsonDecode(metrics.replaceAll("'", "\""));
        parsedTestSetMetrics = _parseMLMetricsMap(metricsMap);
        continue;
      }
      // 2. Get sanity check results
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
          String sanityCheckWarning = line.split(warningStringSeparator).last;
          parsedSanityCheckWarnings.add(sanityCheckWarning);
        } else if (line.contains(infoStringSeparator)) {
          List<String> baselineNameAndMetrics = line.split(infoStringSeparator).last.split(": {'");
          if (baselineNameAndMetrics.length != 2) {
            logger.e("Invalid sanity check line: $line");
            continue;
          }
          String baselineName = baselineNameAndMetrics.first;
          Map<String, dynamic> baselineMetricsMap =
              jsonDecode("{\"${baselineNameAndMetrics.last.replaceAll("'", "\"")}");
          Set<BiocentralMLMetric> baselineMLMetrics = _parseMLMetricsMap(baselineMetricsMap);
          parsedSanityCheckBaselineMetrics[baselineName] = baselineMLMetrics;
        } else {
          logger.e("Invalid sanity check line: $line");
          continue;
        }
      }
    }
    return BiotrainerTrainingResult(
        testSetMetrics: parsedTestSetMetrics,
        sanityCheckWarnings: parsedSanityCheckWarnings,
        sanityCheckBaselineMetrics: parsedSanityCheckBaselineMetrics);
  }

  static PredictionModel? _predictionModelFromBiotrainerConfig(Map<String, dynamic> configMap) {
    return PredictionModel.fromMap(configMap)?.copyWith(biotrainerTrainingConfig: configMap);
  }

  static PredictionModel? _predictionModelFromResultFile(Map<String, dynamic> parsedResultFile) {
    return PredictionModel.fromMap({
      "embedder_name": parsedResultFile["embedder_name"] ?? "",
      "model_choice": parsedResultFile["model_choice"] ?? "",
      "interaction": parsedResultFile["interaction"] ?? "",
      "protocol": parsedResultFile["protocol"] ?? ""
    });
  }
}
