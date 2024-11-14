import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_protocol.dart';

@immutable
class PredictionModel extends Equatable {
  final String? embedderName;
  final String? architecture;
  final String? databaseType;
  final PredictionProtocol? predictionProtocol;

  final Map<String, dynamic>? biotrainerTrainingConfig;
  final BiotrainerTrainingResult? biotrainerTrainingResult;
  final List<String>? biotrainerTrainingLog;

  final Map<String, Uint8List>? biotrainerCheckpoints;

  const PredictionModel(
      {required this.embedderName,
      required this.architecture,
      required this.databaseType,
      required this.predictionProtocol,
      required this.biotrainerTrainingConfig,
      required this.biotrainerTrainingResult,
      required this.biotrainerTrainingLog,
      required this.biotrainerCheckpoints,});

  const PredictionModel.empty()
      : embedderName = null,
        architecture = null,
        databaseType = null,
        predictionProtocol = null,
        biotrainerTrainingConfig = null,
        biotrainerTrainingResult = null,
        biotrainerTrainingLog = null,
        biotrainerCheckpoints = null;

  static PredictionModel? fromMap(Map<String, dynamic> map) {
    final String? embedderName = map['embedder_name'];
    final String? architecture = map['model_choice'];
    final String databaseType = map['interaction'] != null && map['interaction'] != '' ? const ProteinProteinInteraction.empty().typeName : const Protein.empty().typeName;
    final PredictionProtocol? predictionProtocol =
        enumFromString<PredictionProtocol>(map['protocol'], PredictionProtocol.values);

    // No information contained - return null
    if (databaseType is! ProteinProteinInteraction &&
        (architecture?.isEmpty ?? true) &&
        (embedderName?.isEmpty ?? true) &&
        predictionProtocol == null) {
      return null;
    }

    return const PredictionModel.empty().copyWith(
        embedderName: embedderName,
        architecture: architecture,
        databaseType: databaseType,
        predictionProtocol: predictionProtocol,);
  }

  PredictionModel copyWith(
      {embedderName,
      architecture,
      databaseType,
      predictionProtocol,
      biotrainerTrainingConfig,
      biotrainerTrainingResult,
      biotrainerTrainingLog,
      biotrainerCheckpoints,}) {
    return PredictionModel(
        embedderName: embedderName ?? this.embedderName,
        architecture: architecture ?? this.architecture,
        databaseType: databaseType ?? this.databaseType,
        predictionProtocol: predictionProtocol ?? this.predictionProtocol,
        biotrainerTrainingConfig: biotrainerTrainingConfig ?? this.biotrainerTrainingConfig,
        biotrainerTrainingResult: biotrainerTrainingResult ?? this.biotrainerTrainingResult,
        biotrainerTrainingLog: biotrainerTrainingLog ?? this.biotrainerTrainingLog,
        biotrainerCheckpoints: biotrainerCheckpoints ?? this.biotrainerCheckpoints,);
  }

  PredictionModel merge(PredictionModel? other, {required bool failOnConflict}) {
    if (other == null) {
      return this;
    }

    final String? embedderNameMerged = nullableMerge(embedderName, other.embedderName,
        'Could not merge prediction models due to a conflict in their embedderNames!', failOnConflict,);
    final String? architectureMerged = nullableMerge(architecture, other.architecture,
        'Could not merge prediction models due to a conflict in their architecture!', failOnConflict,);
    final String? databaseTypeMerged = nullableMerge(databaseType, other.databaseType,
        'Could not merge prediction models due to a conflict in their database types!', failOnConflict,);
    final PredictionProtocol? predictionProtocolMerged = nullableMerge(predictionProtocol, other.predictionProtocol,
        'Could not merge prediction models due to a conflict in their prediction protocols!', failOnConflict,);

    final String? configStringMerged = nullableMerge(
        biotrainerTrainingConfig != null ? jsonEncode(biotrainerTrainingConfig) : null,
        other.biotrainerTrainingConfig != null ? jsonEncode(other.biotrainerTrainingConfig) : null,
        'Could not merge prediction models due to a conflict in their training configs!',
        failOnConflict,);

    final Map<String, dynamic>? biotrainerTrainingConfigMerged =
        configStringMerged != null ? jsonDecode(configStringMerged) : null;

    final BiotrainerTrainingResult? biotrainerTrainingResultMerged = nullableMerge(
        biotrainerTrainingResult,
        other.biotrainerTrainingResult,
        'Could not merge prediction models due to a conflict in their training results!',
        failOnConflict,);
    final Set<String> biotrainerTrainingLogMerged = biotrainerTrainingLog?.toSet() ?? {};
    biotrainerTrainingLogMerged.addAll(other.biotrainerTrainingLog?.toSet() ?? {});

    final Map<String, Uint8List> biotrainerCheckpointsMerged = biotrainerCheckpoints ?? {};
    biotrainerCheckpointsMerged.addAll(other.biotrainerCheckpoints ?? {});
    return PredictionModel(
        embedderName: embedderNameMerged,
        architecture: architectureMerged,
        databaseType: databaseTypeMerged,
        predictionProtocol: predictionProtocolMerged,
        biotrainerTrainingConfig: biotrainerTrainingConfigMerged,
        biotrainerTrainingResult: biotrainerTrainingResultMerged,
        biotrainerTrainingLog: biotrainerTrainingLogMerged.toList(),
        biotrainerCheckpoints: biotrainerCheckpointsMerged.isNotEmpty ? biotrainerCheckpointsMerged : null,);
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
        biotrainerTrainingLog,
        biotrainerCheckpoints,
      ];
}
