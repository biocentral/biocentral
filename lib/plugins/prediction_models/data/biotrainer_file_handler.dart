import 'dart:convert';
import 'dart:typed_data';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:yaml/yaml.dart';

class BiotrainerFileHandler {

  static Future<String> getBiotrainerInputFile(
    Type databaseType,
    Map<String, dynamic> entryMap,
    String targetColumn,
    String setColumn,
  ) async {
    String inputFile = '';
    // TODO [Refactoring] Ad MASKS/per-residue TARGETS
    switch (databaseType) {
      case Protein:
        {
          final handler = BioFileHandler<Protein>().create('fasta');
          inputFile = await handler.convertToString(
                entryMap.map(
                  (key, value) => MapEntry(
                    key,
                    (value as Protein).copyWith(
                      attributes: CustomAttributes(
                        {'TARGET': value.toMap()[targetColumn] ?? 'None', 'SET': value.toMap()[setColumn] ?? 'None'},
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
          inputFile = await handler.convertToString(
                entryMap.map(
                  (key, value) => MapEntry(
                    key,
                    (value as ProteinProteinInteraction).copyWith(
                      attributes: CustomAttributes(
                        {'TARGET': value.toMap()[targetColumn] ?? 'None', 'SET': value.toMap()[setColumn] ?? 'None'},
                      ),
                    ),
                  ),
                ),
              ) ??
              '';
          break;
        }
    }
    return inputFile;
  }

  /// Convert [biotrainerConfiguration] to YAML file
  static String biotrainerConfigurationToConfigFile(Map<String, dynamic> biotrainerConfiguration) {
    String result = '';
    for (String key in biotrainerConfiguration.keys) {
      if (biotrainerConfiguration[key] != '' && !key.contains('column')) {
        result += '$key:';
        result += '${biotrainerConfiguration[key]!}\n';
      }
    }
    return result;
  }

  static PredictionModel? parsePredictionModelFromRawFiles({
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
      biotrainerOutput: parsedOutputFile,
      biotrainerTrainingLog: biotrainerTrainingLog,
      biotrainerCheckpoints: parsedBiotrainerCheckpoints,
      failOnConflict: failOnConflict,
    );
  }

  static PredictionModel? parsePredictionModel({
    required bool failOnConflict,
    Map<String, dynamic>? biotrainerConfig,
    Map<String, dynamic>? biotrainerOutput,
    String? biotrainerTrainingLog,
    Map<String, Uint8List>? biotrainerCheckpoints,
  }) {
    PredictionModel? result = const PredictionModel.empty();
    // Output file should have the highest authority => Loaded first
    if (biotrainerOutput != null) {
      result = PredictionModel.fromMap(biotrainerOutput);
    }
    // Output file and config file should have no contradictions => failOnConflict always true
    if (biotrainerConfig != null) {
      result = result?.copyWith(config: biotrainerConfig.merge<String, dynamic>(result.config ?? {}));
    }
    // Training log
    if (biotrainerTrainingLog != null) {
      final logs = biotrainerTrainingLog.split('\n');
      result = result?.addLogs(logs);
    }
    // Checkpoints
    if (biotrainerCheckpoints != null) {
      result = result?.addCheckpoints(biotrainerCheckpoints);
    }
    return result;
  }
}
