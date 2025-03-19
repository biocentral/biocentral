import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/domain/plm_eval_repository.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/sdk/bloc/biocentral_command.dart';
import 'package:biocentral/sdk/bloc/biocentral_state.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

class AutoEvalPLMCommand extends BiocentralResumableCommand<AutoEvalProgress> {
  final PLMEvalClient _plmEvalClient;
  final PLMEvalRepository _plmEvalRepository;

  final String _modelID;
  final bool _recommendedOnly;
  final List<BenchmarkDataset> _benchmarkDatasets;

  AutoEvalPLMCommand(
      {required PLMEvalClient plmEvalClient,
      required PLMEvalRepository plmEvalRepository,
      required String modelID,
      required bool recommendedOnly,
      required List<BenchmarkDataset> benchmarkDatasets})
      : _plmEvalClient = plmEvalClient,
        _plmEvalRepository = plmEvalRepository,
        _modelID = modelID,
        _recommendedOnly = recommendedOnly,
        _benchmarkDatasets = benchmarkDatasets;

  @override
  Stream<Either<T, AutoEvalProgress>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    final AutoEvalProgress initialProgress = AutoEvalProgress.fromDatasets(_modelID, _benchmarkDatasets);

    final startAutoEvalEither = await _plmEvalClient.startAutoEval(_modelID, _recommendedOnly);

    yield* startAutoEvalEither.match((l) async* {
      yield left(
        state.setErrored(
          information: 'Start of autoeval workflow failed! Error: ${l.error}',
        ),
      );
    }, (taskID) async* {
      yield left(state.setTaskID(taskID));
      yield* doEvaluation(taskID, state, initialProgress);
    });
  }

  Stream<Either<T, AutoEvalProgress>> doEvaluation<T extends BiocentralCommandState<T>>(
      String taskID, T state, AutoEvalProgress initialProgress) async* {
    state = state
        .setOperating(information: 'Running evaluation of $_modelID..')
        .copyWith(copyMap: {'modelID': _modelID, 'autoEvalProgress': initialProgress});
    yield left(state);

    AutoEvalProgress? progress;
    await for (AutoEvalProgress? currentProgress in _plmEvalClient.autoEvalProgressStream(taskID, initialProgress)) {
      if (currentProgress == null) {
        continue;
      }
      progress = currentProgress;
      state = state
          .setOperating(information: 'Running evaluation of $_modelID..', commandProgress: progress.toCommandProgress())
          .copyWith(copyMap: {'autoEvalProgress': progress});
      yield left(state);
    }

    if (progress != null && progress.status == BiocentralTaskStatus.finished) {
      final _ = await _plmEvalRepository.addSessionResult(progress);

      yield left(
        state.setFinished(
          information: 'Finished evaluation of $_modelID!',
          commandProgress: progress.toCommandProgress(),
        ),
      );
      yield right(progress);
      return;
    }
    yield left(state.setErrored(information: 'Encountered error during evaluation of $_modelID!'));
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'modelID': _modelID,
      'recommendedOnly': _recommendedOnly,
      'benchmarkDatasets': BenchmarkDataset.benchmarkDatasetsByDatasetName(_benchmarkDatasets),
    };
  }

  @override
  Stream<Either<T, AutoEvalProgress>> resumeExecution<T extends BiocentralCommandState<T>>(
      String taskID, T state) async* {
    yield left(state.setOperating(information: 'Trying to resume evaluation..'));

    final initialProgress = AutoEvalProgress.fromDatasets(_modelID, _benchmarkDatasets);
    final resumedProgressEither = await _plmEvalClient.resumeAutoEval(taskID, initialProgress);
    yield* resumedProgressEither.match((error) async* {
      yield left(state.setErrored(information: 'Evaluation could not be resumed! Error: ${error.message}'));
      return;
    }, (resumedProgress) async* {
      yield* doEvaluation(taskID, state, resumedProgress);
    });
  }

  @override
  String get typeName => 'AutoEvalPLMCommand';
}
