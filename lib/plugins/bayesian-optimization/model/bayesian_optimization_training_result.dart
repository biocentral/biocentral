import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class BayesianOptimizationTrainingResult extends Equatable {
  final List<BayesianOptimizationTrainingResultData>? results;
  final List<double>? actualValues;
  final Map<String, dynamic>? trainingConfig;
  final String? taskID;

  const BayesianOptimizationTrainingResult({
    required this.results,
    this.actualValues,
    this.trainingConfig,
    this.taskID,
  });

  BayesianOptimizationTrainingResult copyWith({
    List<BayesianOptimizationTrainingResultData>? results,
    List<double>? actualValues,
    Map<String, dynamic>? trainingConfig,
    String? taskID,
  }) {
    return BayesianOptimizationTrainingResult(
      results: results ?? this.results,
      actualValues: actualValues ?? this.actualValues,
      trainingConfig: trainingConfig ?? this.trainingConfig,
      taskID: taskID ?? this.taskID,
    );
  }

  /// Creates a [BayesianOptimizationTrainingResult] from a JSON map
  factory BayesianOptimizationTrainingResult.fromJson(Map<String, dynamic> json) {
    return BayesianOptimizationTrainingResult(
      results: (json['results'] as List<dynamic>?)
          ?.map((data) => BayesianOptimizationTrainingResultData.fromJson(data))
          .toList(),
      trainingConfig: json['trainingConfig'] as Map<String, dynamic>?,
      taskID: json['taskID'] as String,
      actualValues: (json['actualValues'] as List<dynamic>?)?.map((value) {
        if (value is double) return value;
        return double.tryParse(value.toString()) ?? 0.0;
      }).toList(),
    );
  }

  /// Converts this object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'results': results?.map((data) => data.toJson()).toList() ?? [],
      'actualValues': actualValues,
      'trainingConfig': trainingConfig,
      'taskID': taskID,
    };
  }

  @override
  List<Object?> get props => [results, actualValues, trainingConfig, taskID];
}

class BayesianOptimizationTrainingResultData extends Equatable {
  final String? proteinId;
  final String? sequence;
  final double? score;
  final double? uncertainty;
  final double? mean;

  const BayesianOptimizationTrainingResultData({
    required this.proteinId,
    required this.sequence,
    required this.score,
    required this.uncertainty,
    required this.mean,
  });

  /// Creates a [BayesianOptimizationTrainingResultData] from a JSON map
  factory BayesianOptimizationTrainingResultData.fromJson(Map<String, dynamic> json) {
    return BayesianOptimizationTrainingResultData(
      proteinId: json['proteinId'] as String?,
      sequence: json['sequence'] as String?,
      score: json['score'] is double ? json['score'] as double? : double.tryParse(json['score'].toString()),
      uncertainty: json['uncertainty'] is double
          ? json['uncertainty'] as double?
          : double.tryParse(json['uncertainty'].toString()),
      mean: json['mean'] is double ? json['mean'] as double? : double.tryParse(json['mean'].toString()),
    );
  }

  /// Converts this object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'proteinId': proteinId,
      'sequence': sequence,
      'score': score,
      'uncertainty': uncertainty,
      'mean': mean,
    };
  }

  static BayesianOptimizationTrainingResultData fromMap(Map<String, dynamic> map) {
    return BayesianOptimizationTrainingResultData(
      proteinId: map['id'],
      sequence: map['sequence'],
      score: map['score'] is double ? map['score'] : double.tryParse(map['score'].toString()),
      uncertainty: map['uncertainty'] is double ? map['uncertainty'] : double.tryParse(map['uncertainty'].toString()),
      mean: map['mean'] is double ? map['mean'] : double.tryParse(map['mean'].toString()),
    );
  }

  @override
  List<Object?> get props => [proteinId, sequence, score, uncertainty, mean];
}
