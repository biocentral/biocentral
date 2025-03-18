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
  final double? utility;
  final double? prediction;
  final double? uncertainty;

  const BayesianOptimizationTrainingResultData({
    required this.proteinId,
    required this.utility,
    required this.prediction,
    required this.uncertainty,
  });

  @override
  List<Object?> get props => [proteinId, utility, prediction, uncertainty];
}
