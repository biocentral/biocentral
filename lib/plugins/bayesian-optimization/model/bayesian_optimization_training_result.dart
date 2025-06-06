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
  factory BayesianOptimizationTrainingResult.fromMap(Map<String, dynamic> map) {
    return BayesianOptimizationTrainingResult(
      results: (map['results'] as List<dynamic>?)
          ?.map((data) => BayesianOptimizationTrainingResultData.fromMap(data))
          .toList(),
      trainingConfig: map['trainingConfig'] as Map<String, dynamic>?,
      taskID: map['taskID'] as String,
      actualValues: (map['actualValues'] as List<dynamic>?)?.map((value) {
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
  final String? id;
  final String? sequence;  // TODO Delete
  final double? score;
  final double? uncertainty;
  final double? mean; // TODO Rename to prediction

  const BayesianOptimizationTrainingResultData({
    required this.id,
    required this.sequence,
    required this.score,
    required this.uncertainty,
    required this.mean,
  });

  /// Creates a [BayesianOptimizationTrainingResultData] from a JSON map
  factory BayesianOptimizationTrainingResultData.fromMap(Map<String, dynamic> map) {
    return BayesianOptimizationTrainingResultData(
      id: map['id'],
      sequence: map['sequence'],
      score: map['score'] is double ? map['score'] : double.tryParse(map['score'].toString()),
      uncertainty: map['uncertainty'] is double ? map['uncertainty'] : double.tryParse(map['uncertainty'].toString()),
      mean: map['mean'] is double ? map['mean'] : double.tryParse(map['mean'].toString()),
    );
  }

  /// Converts this object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sequence': sequence,
      'score': score,
      'uncertainty': uncertainty,
      'mean': mean,
    };
  }

  @override
  List<Object?> get props => [id, sequence, score, uncertainty, mean];
}
