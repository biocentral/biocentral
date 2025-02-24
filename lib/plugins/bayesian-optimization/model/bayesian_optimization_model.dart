import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';

@immutable
class BayesianOptimizationModel extends Equatable {
  final Map<String, dynamic>? boTrainingConfig;
  final BayesianOptimizationTrainingResult? boTrainingResult;

  final Map<String, Uint8List>? boCheckpoints;

  const BayesianOptimizationModel({
    required this.boTrainingConfig,
    required this.boTrainingResult,
    required this.boCheckpoints,
  });

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
