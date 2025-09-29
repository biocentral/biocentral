import 'package:biocentral/plugins/plm_eval/data/plm_eval_dto.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_training_bloc.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_dto.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

class PLMEvalServiceEndpoints {
  static const String validateModelID = '/plm_eval_service/validate';
  static const String getBenchmarkDatasets = '/plm_eval_service/get_benchmark_datasets';
  static const String autoeval = '/plm_eval_service/autoeval';
}

Either<BiocentralParsingException, List<BenchmarkDataset>> parseBenchmarkDatasetsFromMap(
  Map<dynamic, dynamic> response,
) {
  final List<BenchmarkDataset> result = [];
  for (final entry in response.entries) {
    final datasetName = entry.key.toString();
    final splits = entry.value ?? [];
    if (splits is! List) {
      return left(BiocentralParsingException(message: 'Could not parse benchmark datasets from response map!'));
    }
    for (final splitName in splits) {
      result.add(
        BenchmarkDataset(
          taskName: 'FLIP-$datasetName-' + splitName,
        ),
      );
    }
  }
  return right(result);
}

final class AutoEvalProgress {
  final String embedderName;
  final int completedTasks;
  final int totalTasks;
  final BenchmarkDataset? currentTask;
  final Map<BenchmarkDataset, PredictionModel?> results;
  final BiotrainerTrainingState? currentModelTrainingState;
  final BiocentralTaskStatus status;

  AutoEvalProgress({
    required this.embedderName,
    required this.completedTasks,
    required this.totalTasks,
    required this.currentTask,
    required this.results,
    required this.currentModelTrainingState,
    required this.status,
  });

  AutoEvalProgress.fromDatasets(this.embedderName, List<BenchmarkDataset> datasets)
      : completedTasks = 0,
        totalTasks = datasets.length,
        currentTask = null,
        results = Map.fromEntries(datasets.map((dataset) => MapEntry(dataset, null))),
        currentModelTrainingState = null,
        status = BiocentralTaskStatus.running;

  AutoEvalProgress.failed()
      : embedderName = '',
        completedTasks = 0,
        totalTasks = 0,
        currentTask = null,
        results = const {},
        currentModelTrainingState = null,
        status = BiocentralTaskStatus.failed;

  AutoEvalProgress updateFromDTO(BiocentralDTO dto) {
    // TODO [Error handling] embedderName should never change!
    final String embedderName = dto.embedderName ?? this.embedderName;
    final int newCompletedTasks = dto.completedTasks ?? completedTasks;
    final int newTotalTasks = dto.totalTasks ?? totalTasks;
    final BiocentralTaskStatus newStatus = dto.taskStatus ?? status;

    final String? currentTaskName = dto.currentTaskName;
    final currentTask = BenchmarkDataset.fromCombinedString(currentTaskName) ?? this.currentTask;

    final newResults = Map.of(results);
    if (currentTask != null && dto.modelDTO.responseMap.isNotEmpty) {
      PredictionModel? mergedResult = results[currentTask];
      mergedResult ??= PredictionModel.fromTrainingConfig(dto.modelDTO.config ?? {});
      mergedResult = mergedResult.updateFromDTO(dto.modelDTO);

      newResults[currentTask] = mergedResult;
    }
    final currentModel = newResults[currentTask];

    final currentModelFinished = currentModel?.trainingStatus?.isFinished() ?? false;
    BiotrainerTrainingState? newCurrentModelTrainingState;
    if (!currentModelFinished) {
      final currentModelEpoch = currentModel?.holdOutResult?.getLastEpoch();
      final commandProgress =
          currentModelEpoch != null ? BiocentralCommandProgress(current: currentModelEpoch, hint: 'Epoch') : null;
      newCurrentModelTrainingState = BiotrainerTrainingState.fromModel(trainingModel: currentModel)
          .setOperating(information: 'Training model..', commandProgress: commandProgress);
    }
    return AutoEvalProgress(
      embedderName: embedderName,
      completedTasks: newCompletedTasks,
      totalTasks: newTotalTasks,
      currentTask: currentTask,
      results: newResults,
      currentModelTrainingState: newCurrentModelTrainingState,
      status: newStatus,
    );
  }

  BiocentralCommandProgress toCommandProgress() {
    return BiocentralCommandProgress(current: completedTasks, total: totalTasks);
  }

  PLMEvalPersistentResult convertResultsForPublishing() {
    return PLMEvalPersistentResult.fromAutoEvalProgress(this);
  }
}
