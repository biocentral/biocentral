import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class BayesianOptimizationModel extends Equatable {
  final Map<String, dynamic>? boTrainingConfig;
  final BayesianOptimizationTrainingResult? boTrainingResult;

  // final Map<String, Uint8List>? boCheckpoints;

  const BayesianOptimizationModel({
    required this.boTrainingConfig,
    required this.boTrainingResult,
    // required this.boCheckpoints,
  });

  // BayesianOptimizationModel updateFromDTO(BiocentralDTO dto) {
  //   final trainingStatus = dto.taskStatus;
  //
  //   // final newLogs = (biotrainerTrainingResult?.trainingLogs ?? []).join('\n') + (trainingLog ?? '');
  //   final newResult = BiotrainerLogFileHandler.parseBiotrainerLog(
  //     trainingLog: newLogs,
  //     trainingStatus: trainingStatus,
  //   );
  //   return copyWith(biotrainerTrainingResult: newResult);
  // }

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
