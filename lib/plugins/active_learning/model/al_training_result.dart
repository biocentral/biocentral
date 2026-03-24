import 'package:biocentral/plugins/active_learning/model/al_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class ALTrainingResult extends Equatable {
  final List<ALTrainingResultData> results;
  final Map<String, dynamic> experimentalData;
  final ALConfig trainingConfig;
  final String taskID;

  const ALTrainingResult({
    required this.results,
    required this.trainingConfig,
    required this.taskID,
    Map<String, dynamic>? experimentalData,
  }) : experimentalData = experimentalData ?? const {};

  ALTrainingResult copyWith({
    List<ALTrainingResultData>? results,
    Map<String, dynamic>? experimentalData,
    ALConfig? trainingConfig,
    String? taskID,
  }) {
    return ALTrainingResult(
      results: results ?? this.results,
      experimentalData: experimentalData ?? this.experimentalData,
      trainingConfig: trainingConfig ?? this.trainingConfig,
      taskID: taskID ?? this.taskID,
    );
  }

  /// Creates a [ALTrainingResult] from a JSON map
  factory ALTrainingResult.fromMap(Map<String, dynamic> map) {
    return ALTrainingResult(
      results: (map['results'] as List<dynamic>?)
              ?.map((data) => ALTrainingResultData.fromMap(data))
              .toList() ??
          [], // TODO [Error Handling] No results should throw an error
      trainingConfig: ALConfig.fromMap(map['trainingConfig'] ?? {}),
      taskID: map['taskID'] as String,
      experimentalData: map['experimentalData'],
    );
  }

  double? getAveragePredictionError() {
    // TODO Add accuracy for binary predictions, maybe include in BiocentralMLMetric
    if(experimentalData.isEmpty) {
      return null;
    }
    final predictionErrors = <double>[];
    for(final result in results) {
      final experimentalValue = double.tryParse(experimentalData[result.id].toString());
      if(experimentalValue != null) {
        final prediction = result.prediction;
        final predictionError = (experimentalValue.abs() - prediction.abs()).abs();
        predictionErrors.add(predictionError);
      }
    }
    final predictionErrorSum = predictionErrors.reduce((e1, e2) => e1 + e2);
    return predictionErrorSum / predictionErrors.length;
  }

  /// Converts this object to a JSON map
  Map<String, dynamic> toMap() {
    return {
      'results': results.map((data) => data.toMap()).toList(),
      'experimentalData': experimentalData,
      'trainingConfig': trainingConfig.toMap(),
      'taskID': taskID,
    };
  }

  @override
  List<Object?> get props => [results, experimentalData, trainingConfig, taskID];
}

class ALTrainingResultData extends Equatable {
  final String id;
  final double score;
  final double uncertainty;
  final double prediction;

  const ALTrainingResultData({
    required this.id,
    required this.score,
    required this.uncertainty,
    required this.prediction,
  });

  /// Creates a [ALTrainingResultData] from a JSON map
  factory ALTrainingResultData.fromMap(Map<String, dynamic> map) {
    // TODO [Error Handling] Handle parsing errors
    return ALTrainingResultData(
      id: map['id'],
      score: map['score'] is double ? map['score'] : double.tryParse(map['score'].toString()),
      uncertainty: map['uncertainty'] is double ? map['uncertainty'] : double.tryParse(map['uncertainty'].toString()),
      prediction: map['prediction'] is double ? map['prediction'] : double.tryParse(map['mean'].toString()),
    );
  }

  /// Converts this object to a JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'uncertainty': uncertainty,
      'prediction': prediction,
    };
  }

  @override
  List<Object?> get props => [id, score, uncertainty, prediction];
}
