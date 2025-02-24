import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class BayesianOptimizationTrainingResult extends Equatable {
  final String? databaseType;

  const BayesianOptimizationTrainingResult({
    required this.databaseType,
  });

  @override
// TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
