import 'package:biocentral/plugins/bay_opt/model/bay_opt_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class BayOptTrainingResult extends Equatable {
  final List<BayOptTrainingResultData> results;
  final Map<String, dynamic> experimentalData;
  final BayOptConfig trainingConfig;
  final String taskID;

  const BayOptTrainingResult({
    required this.results,
    required this.trainingConfig,
    required this.taskID,
    Map<String, dynamic>? experimentalData,
  }) : experimentalData = experimentalData ?? const {};

  BayOptTrainingResult copyWith({
    List<BayOptTrainingResultData>? results,
    Map<String, dynamic>? experimentalData,
    BayOptConfig? trainingConfig,
    String? taskID,
  }) {
    return BayOptTrainingResult(
      results: results ?? this.results,
      experimentalData: experimentalData ?? this.experimentalData,
      trainingConfig: trainingConfig ?? this.trainingConfig,
      taskID: taskID ?? this.taskID,
    );
  }

  /// Creates a [BayOptTrainingResult] from a JSON map
  factory BayOptTrainingResult.fromMap(Map<String, dynamic> map) {
    return BayOptTrainingResult(
      results: (map['results'] as List<dynamic>?)
              ?.map((data) => BayOptTrainingResultData.fromMap(data))
              .toList() ??
          [], // TODO [Error Handling] No results should throw an error
      trainingConfig: BayOptConfig.fromMap(map['trainingConfig'] ?? {}),
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

class BayOptTrainingResultData extends Equatable {
  final String id;
  final double score;
  final double uncertainty;
  final double prediction;

  const BayOptTrainingResultData({
    required this.id,
    required this.score,
    required this.uncertainty,
    required this.prediction,
  });

  /// Creates a [BayOptTrainingResultData] from a JSON map
  factory BayOptTrainingResultData.fromMap(Map<String, dynamic> map) {
    // TODO [Error Handling] Handle parsing errors
    return BayOptTrainingResultData(
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
