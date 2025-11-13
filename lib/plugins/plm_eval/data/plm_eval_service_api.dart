import 'dart:convert';

import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_leaderboard.dart';
import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_training_bloc.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:fpdart/fpdart.dart';


Either<BiocentralException, (PLMLeaderboard, Map<String, String>)> parseLeaderboardFromResponse(
    Either<BiocentralException, Map<dynamic, dynamic>> leaderboardResponse) {
  return leaderboardResponse.match((l) => left(l), (leaderboardMap) {
    final leaderboardEntries = leaderboardMap['leaderboard'];
    final recommendedMetrics = convertToStringMap(leaderboardMap['recommended_metrics'] ?? {});
    if (leaderboardEntries == null || leaderboardEntries is! List) {
      return left(
        BiocentralParsingException(
          message: 'Could not parse leaderboard from server response - '
              'Expected a list but got type ${leaderboardEntries?.runtimeType}!',
        ),
      );
    }

    final List<PLMEvalPersistentResult> plmPersistentResults = [];
    for (final entryMap in leaderboardEntries) {
      final persistentResult = PLMEvalPersistentResult.fromMap(jsonDecode(entryMap));
      if (persistentResult == null) {
        return left(
          BiocentralParsingException(
            message: 'Could not parse leaderboard from server response '
                '- Could not parse any valid persistent results!',
          ),
        );
      }
      plmPersistentResults.add(persistentResult);
    }
    return right((PLMLeaderboard.fromResults(plmPersistentResults, recommendedMetrics), recommendedMetrics));
  });
}

final class AutoEvalProgressWrapper {
  final AutoEvalProgress? progress;
  final String embedderName;
  final Map<String, PredictionModel?> results;
  final BiotrainerTrainingState? currentModelTrainingState;

  AutoEvalProgressWrapper({
    required this.progress,
    required this.embedderName,
    required this.results,
    required this.currentModelTrainingState,
  });

  AutoEvalProgressWrapper.initial(this.embedderName, List<PLMEvalTaskInformation> tasks)
      : progress = null,
        results = Map.fromEntries(tasks.map((task) => MapEntry(task.name, null))),
        currentModelTrainingState = null;

  int get totalTasks => progress?.totalTasks ?? 0;

  int get completedTasks => progress?.completedTasks ?? 0;

  String get currentFrameworkName => progress?.currentFrameworkName ?? '';

  String get currentTaskName => progress?.currentTaskName ?? '';

  bool get isFinished => completedTasks == totalTasks && results.values.all((v) => v != null);

  AutoEvalProgressWrapper updateFromDTO(TaskDTO dto) {
    final currentTask = dto.autoevalProgress?.currentTaskName ?? currentTaskName;

    final newResults = Map.of(results);
    if (dto.biotrainerUpdate != null) {
      PredictionModel? mergedResult = results[currentTask];
      final trainingConfig = dto.biotrainerUpdate?.config?.toMap() ?? {};
      mergedResult ??= PredictionModel.fromTrainingConfig(trainingConfig);
      mergedResult = mergedResult.updateFromDTO(dto);

      newResults[currentTask] = mergedResult;
    }
    final currentModel = newResults[currentTask];

    final currentModelFinished = currentModel?.trainingStatus?.isFinished() ?? false;
    BiotrainerTrainingState? newModelTrainingState;
    if (!currentModelFinished) {
      final currentModelEpoch = currentModel?.holdOutResult?.getLastEpoch();
      final commandProgress =
          currentModelEpoch != null ? BiocentralCommandProgress(current: currentModelEpoch, hint: 'Epoch') : null;
      newModelTrainingState = BiotrainerTrainingState.fromModel(trainingModel: currentModel)
          .setOperating(information: 'Training model..', commandProgress: commandProgress);
    }
    return AutoEvalProgressWrapper(
      progress: dto.autoevalProgress ?? progress,
      embedderName: embedderName,
      results: newResults,
      currentModelTrainingState: newModelTrainingState,
    );
  }

  BiocentralCommandProgress toCommandProgress() {
    return BiocentralCommandProgress(current: completedTasks, total: totalTasks);
  }

  PLMEvalPersistentResult convertResultsForPublishing() {
    return PLMEvalPersistentResult.fromAutoEvalProgressWrapper(this);
  }
}
