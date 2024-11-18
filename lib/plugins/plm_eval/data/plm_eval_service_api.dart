import 'package:biocentral/plugins/plm_eval/data/plm_eval_dto.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_training_bloc.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_dto.dart';
import 'package:fpdart/fpdart.dart';

class PLMEvalServiceEndpoints {
  static const String validateModelID = '/plm_eval_service/validate';
  static const String getBenchmarkDatasets = '/plm_eval_service/get_benchmark_datasets';
  static const String getRecommendedBenchmarkDatasets = '/plm_eval_service/get_recommended_benchmark_datasets';
  static const String autoeval = '/plm_eval_service/autoeval';
  static const String taskStatus = '/plm_eval_service/task_status';
}

Either<BiocentralParsingException, List<BenchmarkDataset>> parseBenchmarkDatasetsFromMap(
    Map<dynamic, dynamic> response,) {
  final List<BenchmarkDataset> result = [];
  for (final entry in response.entries) {
    final datasetName = entry.key.toString();
    if (entry.value is! List) {
      return left(BiocentralParsingException(message: 'Could not parse benchmark datasets from response map!'));
    }
    for (final splitName in entry.value) {
      result.add(BenchmarkDataset(datasetName: datasetName, splitName: splitName.toString()));
    }
  }
  return right(result);
}

enum AutoEvalStatus {
  running,
  finished,
  failed;
}

final class AutoEvalProgress {
  final int completedTasks;
  final int totalTasks;
  final BenchmarkDataset? currentProcess;
  final Map<BenchmarkDataset, PredictionModel?> results;
  final BiotrainerTrainingState? currentModelTrainingState;
  final AutoEvalStatus status;

  AutoEvalProgress({
    required this.completedTasks,
    required this.totalTasks,
    required this.currentProcess,
    required this.results,
    required this.currentModelTrainingState,
    required this.status,
  });

  AutoEvalProgress.fromDatasets(List<BenchmarkDataset> datasets)
      : completedTasks = 0,
        totalTasks = datasets.length,
        currentProcess = null,
        results = Map.fromEntries(datasets.map((dataset) => MapEntry(dataset, null))),
        currentModelTrainingState = null,
        status = AutoEvalStatus.running;

  AutoEvalProgress.failed()
      : completedTasks = 0,
        totalTasks = 0,
        currentProcess = null,
        results = const {},
        currentModelTrainingState = null,
        status = AutoEvalStatus.failed;

  static Either<BiocentralParsingException, AutoEvalProgress> fromDTO(BiocentralDTO dto) {
    final int? completedTasks = dto.completedTasks;
    final int? totalTasks = dto.totalTasks;
    final AutoEvalStatus? autoEvalStatus = dto.autoEvalStatus;
    if (completedTasks == null || totalTasks == null || autoEvalStatus == null) {
      return left(BiocentralParsingException(message: 'Could not parse autoeval update progress!'));
    }
    final String? currentProcessString = dto.currentProcess;
    final currentProcess = BenchmarkDataset.fromServerString(currentProcessString);
    final Map<BenchmarkDataset, PredictionModel?> autoEvalResults = dto.parseResults();

    final currentModel = autoEvalResults[currentProcess];
    final currentModelEpoch = currentModel?.biotrainerTrainingResult?.getLastEpoch();
    final commandProgress =
    currentModelEpoch != null ? BiocentralCommandProgress(current: currentModelEpoch, hint: 'Epoch') : null;
    final BiotrainerTrainingState currentModelTrainingState = BiotrainerTrainingState.fromModel(
        trainingModel: currentModel)
        .setOperating(information: 'Training model..', commandProgress: commandProgress);

    return right(
      AutoEvalProgress(
        completedTasks: completedTasks,
        totalTasks: totalTasks,
        currentProcess: currentProcess,
        results: autoEvalResults,
        currentModelTrainingState: currentModelTrainingState,
        status: autoEvalStatus,
      ),
    );
  }

  AutoEvalProgress update(AutoEvalProgress newProgress) {
    if (totalTasks != newProgress.totalTasks) {
      logger.w('Inconsistency in updating autoeval progress: $totalTasks != ${newProgress.totalTasks} !');
    }
    final Map<BenchmarkDataset, PredictionModel?> updatedResults = Map.from(results);
    for (MapEntry<BenchmarkDataset, PredictionModel?> entry in newProgress.results.entries) {
      if (entry.value != null) {
        final existingResult = updatedResults[entry.key];

        if (existingResult != null) {
          final mergedResult = entry.value?.merge(existingResult, failOnConflict: false);
          updatedResults[entry.key] = mergedResult;
        } else {
          updatedResults[entry.key] = entry.value;
        }
      }
    }
    return AutoEvalProgress(
      completedTasks: newProgress.completedTasks,
      totalTasks: newProgress.totalTasks,
      currentProcess: newProgress.currentProcess,
      results: updatedResults,
      currentModelTrainingState: newProgress.currentModelTrainingState,
      status: newProgress.status,
    );
  }
}
