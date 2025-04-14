import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class BayesianOptimizationTrainingResult extends Equatable {
  final List<BayesianOptimizationTrainingResultData>? results;

  const BayesianOptimizationTrainingResult({
    required this.results,
  });

  @override
  List<Object?> get props => [results];
}

class BayesianOptimizationTrainingResultData extends Equatable {
  final String? proteinId;
  final String? sequence;
  final double? score;

  const BayesianOptimizationTrainingResultData({
    required this.proteinId,
    required this.sequence,
    required this.score,
  });

  static BayesianOptimizationTrainingResultData fromMap(Map<String, dynamic> map) {
    return BayesianOptimizationTrainingResultData(
      proteinId: map['id'],
      sequence: map['sequence'],
      score: map['score'] is double ? map['score'] : double.tryParse(map['score'].toString()),
    );
  }

  @override
  List<Object?> get props => [proteinId, sequence, score];
}
