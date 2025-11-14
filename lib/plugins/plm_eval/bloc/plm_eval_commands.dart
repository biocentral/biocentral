import 'dart:convert';
import 'dart:typed_data';

import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/domain/plm_eval_repository.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:fpdart/fpdart.dart';

class AutoevalPLMCommand extends BiocentralResumableCommand<AutoEvalProgressWrapper> {
  final BiocentralProjectRepository _projectRepository;
  final BiocentralAPIRepository _apiRepository;

  final PLMEvalRepository _plmEvalRepository;

  final String _modelID;
  final XFile? _onnxFile;
  final Map<String, dynamic>? _tokenizerConfig;
  final List<PLMEvalTaskInformation> _tasks;

  AutoevalPLMCommand(
      {required BiocentralProjectRepository projectRepository,
      required BiocentralAPIRepository apiRepository,
      required PLMEvalRepository plmEvalRepository,
      required String modelID,
      required XFile? onnxFile,
      required Map<String, dynamic>? tokenizerConfig,
      required List<PLMEvalTaskInformation> tasks,})
      : _projectRepository = projectRepository,
        _apiRepository = apiRepository,
        _plmEvalRepository = plmEvalRepository,
        _modelID = modelID,
        _onnxFile = onnxFile,
        _tokenizerConfig = tokenizerConfig,
        _tasks = tasks;

  @override
  Stream<Either<T, AutoEvalProgressWrapper>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    final AutoEvalProgressWrapper initialProgress = AutoEvalProgressWrapper.initial(_modelID, _tasks);

    Uint8List? onnxBytes;
    if (_onnxFile != null) {
      final loadEither = await _projectRepository.handleBytesLoad(xFile: _onnxFile);
      if (loadEither.isLeft()) {
        yield left(state.setErrored(information: 'Could not load provided onnx file!'));
        return;
      }
      onnxBytes = loadEither.getRight().getOrElse(() => null);
    }

    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final biocentralTask = await biocentralAPI.autoeval(
      modelID: _modelID,
      onnxFile: onnxBytes != null ? base64Encode(onnxBytes) : null,
      tokenizerConfig: jsonEncode(_tokenizerConfig),
    );
    yield* doEvaluation(biocentralTask, state, initialProgress);
  }

  Stream<Either<T, AutoEvalProgressWrapper>> doEvaluation<T extends BiocentralCommandState<T>>(
      BiocentralServerTask<Map<String, dynamic>?> task, T state, AutoEvalProgressWrapper initialProgress,) async* {
    state = state
        .setOperating(information: 'Running evaluation of $_modelID..')
        .copyWith(copyMap: {'modelID': _modelID, 'autoEvalProgress': initialProgress});
    yield left(state);

    AutoEvalProgressWrapper progress = initialProgress;
    int embeddingCurrent = 0;
    int embeddingTotal = 0;
    await for (final (dto, finalReport) in task.run()) {
      if (dto != null) {
        if (dto.status == TaskStatus.RUNNING) {
          if (dto.embeddingTotal != null || dto.embeddingCurrent != null) {
            // Check embedding progress
            embeddingCurrent = dto.embeddingCurrent ?? embeddingCurrent;
            embeddingTotal = dto.embeddingTotal ?? embeddingTotal;
            yield left(
              state.setOperating(
                information: 'Embedding..',
                commandProgress: BiocentralCommandProgress(current: embeddingCurrent, total: embeddingTotal),
              ),
            );
          } else if(dto.autoevalProgress != null){
            progress = progress.updateFromDTO(dto);
            state = state
                .setOperating(information: 'Running evaluation of $_modelID..', commandProgress: progress.toCommandProgress())
                .copyWith(copyMap: {'autoEvalProgress': progress});
            yield left(state);
          }
        }
      }
    }

    if (progress.isFinished) {
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
      'tasks': _tasks,
    };
  }

  @override
  Stream<Either<T, AutoEvalProgressWrapper>> resumeExecution<T extends BiocentralCommandState<T>>(
      String taskID, T state,) async* {
    // TODO Refactoring Resume
    //yield left(state.setOperating(information: 'Trying to resume evaluation..'));
//
    //final initialProgress = AutoEvalProgress.fromDatasets(_modelID, _tasks);
    //final resumedProgressEither = await _plmEvalClient.resumeAutoEval(taskID, initialProgress);
    //yield* resumedProgressEither.match((error) async* {
    //  yield left(state.setErrored(information: 'Evaluation could not be resumed! Error: ${error.message}'));
    //  return;
    //}, (resumedProgress) async* {
    //  yield* doEvaluation(taskID, state, resumedProgress);
    //});
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
      required XFile persistentResultFile,})
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
      final updatedPersistentResults =
          await _plmEvalRepository.addPersistentResultsFromFile(persistentFileContent?.content ?? '');
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
