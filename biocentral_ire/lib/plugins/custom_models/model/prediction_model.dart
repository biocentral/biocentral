import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class PredictionModel extends Equatable {
  final Map<String, dynamic>? _config;
  final BiotrainerModelResult? modelResult;
  final String? databaseType;

  final List<String> trainingLogs;
  final Map<String, Uint8List> checkpoints;

  final BiocentralTaskStatus? trainingStatus;

  const PredictionModel({
    required this.modelResult,
    required this.databaseType,
    required this.trainingLogs,
    required this.checkpoints,
    required this.trainingStatus,
    Map<String, dynamic>? config,
  }) : _config = config;

  static PredictionModel fromTrainingConfig(Map<String, dynamic> trainingConfig) {
    return PredictionModel(
      config: trainingConfig,
      databaseType: null,
      modelResult: null,
      trainingLogs: const [],
      checkpoints: const {},
      trainingStatus: null,
    );
  }

  const PredictionModel.empty()
      : _config = null,
        modelResult = null,
        databaseType = null,
        trainingLogs = const [],
        checkpoints = const {},
        trainingStatus = null;

  PredictionModel copyWith({
    config,
    databaseType,
    modelResult,
    testResults,
    trainingLogs,
    checkpoints,
    trainingStatus,
  }) {
    return PredictionModel(
      config: config ?? _config,
      databaseType: databaseType ?? this.databaseType,
      modelResult: modelResult ?? this.modelResult,
      trainingLogs: trainingLogs ?? this.trainingLogs,
      checkpoints: checkpoints ?? this.checkpoints,
      trainingStatus: trainingStatus ?? this.trainingStatus,
    );
  }

  static PredictionModel? deserialize(Map<String, dynamic> map) {
    final config = map['config'];
    final databaseType = map['database_type'] ?? 'Protein';

    final modelResult = BiotrainerModelResultSerial.deserialize(map['model_result']);

    final trainingLogs = map['training_logs'] as List? ?? <String>[];
    final trainingStatus = BiocentralTaskStatus.finished;
    return PredictionModel(
      config: config != null ? Map<String, dynamic>.from(config) : null,
      databaseType: databaseType,
      modelResult: modelResult,
      trainingLogs: trainingLogs.map((l) => l.toString()).toList(),
      checkpoints: {},
      trainingStatus: trainingStatus,
    );
  }


  PredictionModel addLogs(List<String> logs) {
    return copyWith(trainingLogs: Set<String>.from(List.of(trainingLogs)..addAll(logs)).toList());
  }

  PredictionModel addCheckpoints(Map<String, Uint8List> checkpoints) {
    return copyWith(
      checkpoints: Map<String, Uint8List>.from(this.checkpoints)..addAll(checkpoints),
    );
  }

  PredictionModel updateFromDTO(TaskDTO taskDTO) {
    final biotrainerUpdate = taskDTO.biotrainerUpdate;
    if (biotrainerUpdate == null) {
      return this;
    }

    final updatedModel = this;
    return updatedModel.copyWith(modelResult: biotrainerUpdate.currentModelResult);
  }

  PredictionModel finishFromResult(BiotrainerModelResult? biotrainerResult) {
    if (biotrainerResult == null) {
      return this;
    }

    return PredictionModel(
        config: biotrainerResult.configMap() ?? _config,
        modelResult: biotrainerResult,
        databaseType: databaseType,
        trainingLogs: trainingLogs,
        checkpoints: checkpoints,
        trainingStatus: trainingStatus);
  }

  // Getters for commonly used values
  Map<String, dynamic>? get config => _config ?? modelResult?.configMap();

  String? get embedderName => config?['embedder_name'];

  String? get modelChoice => config?['model_choice'];

  String? get modelHash => modelResult?.derivedValues?.modelHash;

  TrainingResult? get holdOutResult => modelResult?.trainingResults?['hold_out'];

  TestResult? get defaultTestResult => modelResult?.testResults?['test'];

  Protocol? get protocol => enumFromString<Protocol>(
      _config?['protocol'].toString().replaceAll('_', '').toLowerCase(), Protocol.values.toList());

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

  Map<String, dynamic> serialize() {
    // Checkpoints are not included at the moment
    return {
      'config': _config,
      'database_type': databaseType,
      'model_result': modelResult?.serialize(),
      'training_logs': trainingLogs,
      'training_status': trainingStatus?.name,
    };
  }

  @override
  List<Object?> get props => [_config, databaseType, modelResult, trainingLogs, trainingStatus];
}
