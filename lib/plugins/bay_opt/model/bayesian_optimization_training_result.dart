import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class BayesianOptimizationTrainingResult extends Equatable {
  final List<BayesianOptimizationTrainingResultData> results;
  final Map<String, dynamic> experimentalData;
  final BayesianOptimizationConfig trainingConfig;
  final String taskID;

  const BayesianOptimizationTrainingResult({
    required this.results,
    required this.trainingConfig,
    required this.taskID,
    Map<String, dynamic>? experimentalData,
  }) : experimentalData = experimentalData ?? const {};

  BayesianOptimizationTrainingResult copyWith({
    List<BayesianOptimizationTrainingResultData>? results,
    Map<String, dynamic>? experimentalData,
    BayesianOptimizationConfig? trainingConfig,
    String? taskID,
  }) {
    return BayesianOptimizationTrainingResult(
      results: results ?? this.results,
      experimentalData: experimentalData ?? this.experimentalData,
      trainingConfig: trainingConfig ?? this.trainingConfig,
      taskID: taskID ?? this.taskID,
    );
  }

  /// Creates a [BayesianOptimizationTrainingResult] from a JSON map
  factory BayesianOptimizationTrainingResult.fromMap(Map<String, dynamic> map) {
    return BayesianOptimizationTrainingResult(
      results: (map['results'] as List<dynamic>?)
              ?.map((data) => BayesianOptimizationTrainingResultData.fromMap(data))
              .toList() ??
          [], // TODO [Error Handling] No results should throw an error
      trainingConfig: BayesianOptimizationConfig.fromMap(map['trainingConfig'] ?? {}),
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

class BayesianOptimizationTrainingResultData extends Equatable {
  final String id;
  final double score;
  final double uncertainty;
  final double prediction;

  const BayesianOptimizationTrainingResultData({
    required this.id,
    required this.score,
    required this.uncertainty,
    required this.prediction,
  });

  /// Creates a [BayesianOptimizationTrainingResultData] from a JSON map
  factory BayesianOptimizationTrainingResultData.fromMap(Map<String, dynamic> map) {
    // TODO [Error Handling] Handle parsing errors
    return BayesianOptimizationTrainingResultData(
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
