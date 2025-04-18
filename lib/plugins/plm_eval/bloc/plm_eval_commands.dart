import 'dart:typed_data';

import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/domain/plm_eval_repository.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:cross_file/cross_file.dart';
import 'package:fpdart/fpdart.dart';

class AutoEvalPLMCommand extends BiocentralResumableCommand<AutoEvalProgress> {
  final BiocentralProjectRepository _projectRepository;

  final PLMEvalClient _plmEvalClient;
  final PLMEvalRepository _plmEvalRepository;

  final String _modelID;
  final XFile? _onnxFile;
  final Map<String, dynamic>? _tokenizerConfig;
  final bool _recommendedOnly;
  final List<BenchmarkDataset> _benchmarkDatasets;

  AutoEvalPLMCommand({
    required BiocentralProjectRepository projectRepository,
    required PLMEvalClient plmEvalClient,
    required PLMEvalRepository plmEvalRepository,
    required String modelID,
    required bool recommendedOnly,
    required List<BenchmarkDataset> benchmarkDatasets,
    XFile? onnxFile,
    Map<String, dynamic>? tokenizerConfig,
  })  : _projectRepository = projectRepository,
        _plmEvalClient = plmEvalClient,
        _plmEvalRepository = plmEvalRepository,
        _modelID = modelID,
        _onnxFile = onnxFile,
        _tokenizerConfig = tokenizerConfig,
        _recommendedOnly = recommendedOnly,
        _benchmarkDatasets = benchmarkDatasets;

  @override
  Stream<Either<T, AutoEvalProgress>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    final AutoEvalProgress initialProgress = AutoEvalProgress.fromDatasets(_modelID, _benchmarkDatasets);

    Uint8List? onnxBytes;
    if (_onnxFile != null) {
      final loadEither = await _projectRepository.handleBytesLoad(xFile: _onnxFile);
      if (loadEither.isLeft()) {
        yield left(state.setErrored(information: 'Could not load provided onnx file!'));
        return;
      }
      onnxBytes = loadEither.getRight().getOrElse(() => null);
    }

    final startAutoEvalEither =
        await _plmEvalClient.startAutoEval(_modelID, onnxBytes, _tokenizerConfig, _recommendedOnly);

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
      if (_onnxFile != null) 'onnxFile': _onnxFile.path,
      if (_tokenizerConfig != null) 'tokenizerConfig': _tokenizerConfig,
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

class PLMEvalLoadPersistentResultCommand extends BiocentralCommand<PLMEvalPersistentResult> {
  final BiocentralProjectRepository _projectRepository;
  final PLMEvalRepository _plmEvalRepository;
  final XFile _persistentResultFile;

  PLMEvalLoadPersistentResultCommand(
      {required BiocentralProjectRepository projectRepository,
      required PLMEvalRepository plmEvalRepository,
      required XFile persistentResultFile})
      : _projectRepository = projectRepository,
        _plmEvalRepository = plmEvalRepository,
        _persistentResultFile = persistentResultFile;

  @override
  Stream<Either<T, PLMEvalPersistentResult>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Loading plm evaluation result from file..'));
    final contentEither = await _projectRepository.handleLoad(xFile: _persistentResultFile);

    // TODO [Error handling] Improve loading file error, file is null, file is empty, file contains no results
    yield* contentEither.match((error) async* {
      yield left(state.setErrored(information: 'Encountered error during loading of plm eval file: $error'));
    }, (persistentFileContent) async* {
      final updatedPersistentResults = await
          _plmEvalRepository.addPersistentResultsFromFile(persistentFileContent?.content ?? '');
      yield left(
        state
            .setFinished(information: 'Finished loading plm evaluation result from file!')
            .copyWith(copyMap: {'persistentResults': updatedPersistentResults}),
      );
      yield right(updatedPersistentResults.last);
    });
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {'fileName': _persistentResultFile.name, 'fileExtension': _persistentResultFile.extension};
  }

  @override
  String get typeName => 'PLMEvalLoadPersistentResultCommand';
}
