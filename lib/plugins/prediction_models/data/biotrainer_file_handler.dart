import 'dart:convert';
import 'dart:typed_data';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_log_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:yaml/yaml.dart';

class BiotrainerFileHandler {
  static CustomAttributes _addOrUpdateCustomAttribute(
      CustomAttributes attributes, Map keyVals) {
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
                        {
                          'TARGET': value.toMap()[targetColumn] ?? '',
                          'SET': value.toMap()[setColumn] ?? ''
                        },
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
          final handler =
              BioFileHandler<ProteinProteinInteraction>().create('fasta');
          sequenceFile = await handler.convertToString(
                entryMap.map(
                  (key, value) => MapEntry(
                    key,
                    (value as ProteinProteinInteraction).copyWith(
                      attributes: _addOrUpdateCustomAttribute(
                        value.attributes,
                        {
                          'TARGET': value.toMap()[targetColumn] ?? '',
                          'SET': value.toMap()[setColumn] ?? ''
                        },
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

  static String biotrainerConfigurationToConfigFile(
      Map<String, String?> biotrainerConfiguration) {
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
      for (MapEntry<String, dynamic> checkpoint
          in biotrainerCheckpoints.entries) {
        final Uint8List checkpointBytes =
            base64Decode(checkpoint.value.toString());
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
      result = result.merge(_predictionModelFromResultFile(biotrainerOutputMap),
          failOnConflict: failOnConflict);
    }
    // Output file and config file should have no contradictions => failOnConflict always true
    if (biotrainerConfig != null) {
      result = result.merge(
          _predictionModelFromBiotrainerConfig(biotrainerConfig),
          failOnConflict: true);
    }
    // Training log
    if (biotrainerTrainingLog != null) {
      final logs = biotrainerTrainingLog.split('\n');
      result = result.copyWith(
        biotrainerTrainingResult: BiotrainerLogFileHandler.parseBiotrainerLog(
            trainingLog: biotrainerTrainingLog),
        biotrainerTrainingLog: logs,
      );
    }
    // Checkpoints
    if (biotrainerCheckpoints != null) {
      result = result.copyWith(biotrainerCheckpoints: biotrainerCheckpoints);
    }
    return result;
  }

  static PredictionModel? predictionModelFromBiotrainerLog(
      Map<String, dynamic> configMap, String trainingLog) {
    return PredictionModel.fromMap(configMap)?.copyWith(
        biotrainerTrainingResult: BiotrainerLogFileHandler.parseBiotrainerLog(
            trainingLog: trainingLog),
        biotrainerTrainingLog: trainingLog);
  }

  static PredictionModel? _predictionModelFromBiotrainerConfig(
      Map<String, dynamic> configMap) {
    return PredictionModel.fromMap(configMap)
        ?.copyWith(biotrainerTrainingConfig: configMap);
  }

  static PredictionModel? _predictionModelFromResultFile(
      Map<String, dynamic> parsedResultFile) {
    return PredictionModel.fromMap({
      'embedder_name': parsedResultFile['embedder_name'] ?? '',
      'model_choice': parsedResultFile['model_choice'] ?? '',
      'interaction': parsedResultFile['interaction'] ?? '',
      'protocol': parsedResultFile['protocol'] ?? '',
    });
  }
}
