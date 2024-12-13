import 'package:biocentral/plugins/plm_eval/data/plm_eval_dto.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_training_bloc.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

class PLMEvalServiceEndpoints {
  static const String validateModelID = '/plm_eval_service/validate';
  static const String getBenchmarkDatasets = '/plm_eval_service/get_benchmark_datasets';
  static const String getRecommendedBenchmarkDatasets = '/plm_eval_service/get_recommended_benchmark_datasets';
  static const String autoeval = '/plm_eval_service/autoeval';
  static const String taskStatus = '/plm_eval_service/task_status';
}

Either<BiocentralParsingException, List<BenchmarkDataset>> parseBenchmarkDatasetsFromMap(
  Map<dynamic, dynamic> response,
) {
  final List<BenchmarkDataset> result = [];
  for (final entry in response.entries) {
    final datasetName = entry.key.toString();
    if (entry.value is! Map) {
      return left(BiocentralParsingException(message: 'Could not parse benchmark datasets from response map!'));
    }
    final splits = entry.value['splits'] ?? [];
    for (final splitName in splits) {
      result.add(
        BenchmarkDataset(
            datasetName: datasetName,
            splitName: splitName.toString(),
            ),
      );
    }
  }
  print(result);
  return right(result);
}

final class AutoEvalProgress {
  final int completedTasks;
  final int totalTasks;
  final BenchmarkDataset? currentTask;
  final Map<BenchmarkDataset, PredictionModel?> results;
  final BiotrainerTrainingState? currentModelTrainingState;
  final BiocentralTaskStatus status;

  AutoEvalProgress({
    required this.completedTasks,
    required this.totalTasks,
    required this.currentTask,
    required this.results,
    required this.currentModelTrainingState,
    required this.status,
  });

  AutoEvalProgress.fromDatasets(List<BenchmarkDataset> datasets)
      : completedTasks = 0,
        totalTasks = datasets.length,
        currentTask = null,
        results = Map.fromEntries(datasets.map((dataset) => MapEntry(dataset, null))),
        currentModelTrainingState = null,
        status = BiocentralTaskStatus.running;

  AutoEvalProgress.failed()
      : completedTasks = 0,
        totalTasks = 0,
        currentTask = null,
        results = const {},
        currentModelTrainingState = null,
        status = BiocentralTaskStatus.failed;

  AutoEvalProgress updateFromDTO(BiocentralDTO dto) {
    if (dto.totalTasks == null || dto.completedTasks == null || dto.taskStatus == null) {
      return this; // Not a valid update
    }
    final int newCompletedTasks = dto.completedTasks ?? completedTasks;
    final int newTotalTasks = dto.totalTasks ?? totalTasks;
    final BiocentralTaskStatus newStatus = dto.taskStatus ?? status;

    final String? currentProcessString = dto.currentTask;
    final currentTask = BenchmarkDataset.fromServerString(currentProcessString);

    final newResults = Map.of(results);
    if (currentTask != null) {
      final PredictionModel newParsedModel = dto.parseCurrentTaskModel();
      final PredictionModel? existingModel = results[currentTask];
      PredictionModel mergedResult = newParsedModel;
      if (existingModel != null) {
        mergedResult = existingModel.updateTrainingResult(newParsedModel.biotrainerTrainingResult);
      }
      newResults[currentTask] = mergedResult;
    }
    final currentModel = newResults[currentTask];

    final currentModelEpoch = currentModel?.biotrainerTrainingResult?.getLastEpoch();
    final commandProgress =
        currentModelEpoch != null ? BiocentralCommandProgress(current: currentModelEpoch, hint: 'Epoch') : null;
    final BiotrainerTrainingState currentModelTrainingState =
        BiotrainerTrainingState.fromModel(trainingModel: currentModel)
            .setOperating(information: 'Training model..', commandProgress: commandProgress);
    return AutoEvalProgress(
      completedTasks: newCompletedTasks,
      totalTasks: newTotalTasks,
      currentTask: currentTask,
      results: newResults,
      currentModelTrainingState: currentModelTrainingState,
      status: newStatus,
    );
  }
}
