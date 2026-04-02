import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/custom_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/custom_models/domain/prediction_model_repository.dart';
import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/plugins/custom_models/model/set_generator.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:biocentral/sdk/domain/biocentral_database_column.dart';
import 'package:biocentral/sdk/model/split_set.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:fpdart/fpdart.dart' show FpdartOnMap;

final class LoadModelDatabaseCommand extends BiocentralCommand<List<PredictionModel>> {
  final BiocentralProjectRepository _projectRepository;
  final CustomModelRepository _modelRepository;

  final XFile _modelDBFile;
  final DatabaseImportMode _importMode;

  LoadModelDatabaseCommand({
    required BiocentralProjectRepository projectRepository,
    required CustomModelRepository modelRepository,
    required XFile modelDBFile,
    required DatabaseImportMode importMode,
  })  : _projectRepository = projectRepository,
        _modelRepository = modelRepository,
        _modelDBFile = modelDBFile,
        _importMode = importMode;

  @override
  Stream<BiocentralCommandLog<List<PredictionModel>>> execute() async* {
    BiocentralCommandLog<List<PredictionModel>> log = initLog();
    yield log = log.logInfo(information: 'Loading models from database file..');

    final LoadedFileData? modelDBFileData =
        (await _projectRepository.handleLoad(xFile: _modelDBFile, ignoreIfNoFile: true)).getOrElse((l) => null);
    if (modelDBFileData == null || modelDBFileData.content.isEmpty) {
      yield log.errored(error: 'Could not read model database file!');
      return;
    }
    final modelJson = jsonDecode(modelDBFileData.content);
    final modelMaps = modelJson['models'] as List<dynamic>? ?? [];
    final predictionModels = modelMaps
        .map((modelMap) => PredictionModel.deserialize(modelMap as Map<String, dynamic>))
        .whereType<PredictionModel>()
        .toList();
    yield log.finish(
      result: BiocentralCommandResult(predictionModels, modelJson),
      finalProgress: BiocentralCommandProgress(
        information: 'Finished loading models!',
        current: predictionModels.length,
        total: predictionModels.length,
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is List<PredictionModel>) {
      _modelRepository.addModels(commandResult);
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'modelDBFile': _modelDBFile.name,
      'importMode': _importMode.name,
    };
  }

  @override
  String get typeName => 'LoadModelDatabaseCommand';
}

final class LoadModelCommand extends BiocentralCommand<PredictionModel> {
  final BiocentralProjectRepository _projectRepository;
  final CustomModelRepository _modelRepository;

  final XFile? _configFile;
  final XFile? _outputFile;
  final XFile? _loggingFile;
  final XFile? _checkpointFile; // TODO [Optimization] Support multiple checkpoints

  final DatabaseImportMode _importMode;

  LoadModelCommand({
    required BiocentralProjectRepository projectRepository,
    required CustomModelRepository modelRepository,
    required XFile? configFile,
    required XFile? outputFile,
    required XFile? loggingFile,
    required XFile? checkpointFile,
    required DatabaseImportMode importMode,
  })  : _projectRepository = projectRepository,
        _modelRepository = modelRepository,
        _configFile = configFile,
        _outputFile = outputFile,
        _loggingFile = loggingFile,
        _checkpointFile = checkpointFile,
        _importMode = importMode;

  @override
  Stream<BiocentralCommandLog<PredictionModel>> execute() async* {
    BiocentralCommandLog<PredictionModel> log = initLog();
    yield log = log.logInfo(information: 'Loading model from file(s)..');

    if (_configFile == null && _outputFile == null && _loggingFile == null) {
      yield log.errored(error: 'Did not receive any files to load!');
      return;
    }

    final LoadedFileData? configFileData =
        (await _projectRepository.handleLoad(xFile: _configFile, ignoreIfNoFile: true)).getOrElse((l) => null);
    final LoadedFileData? outputFileData =
        (await _projectRepository.handleLoad(xFile: _outputFile, ignoreIfNoFile: true)).getOrElse((l) => null);
    final LoadedFileData? loggingFileData =
        (await _projectRepository.handleLoad(xFile: _loggingFile, ignoreIfNoFile: true)).getOrElse((l) => null);

    final Uint8List? checkpointBytes = (await _projectRepository.handleBytesLoad(
      xFile: _checkpointFile,
      ignoreIfNoFile: true,
    ))
        .getOrElse((l) => null);
    final Map<String, Uint8List>? checkpoints =
        checkpointBytes != null ? {_checkpointFile!.name: checkpointBytes} : null;

    final PredictionModel? predictionModel = BiotrainerFileHandler.parsePredictionModelFromRawFiles(
      biotrainerConfig: configFileData?.content,
      biotrainerOutput: outputFileData?.content,
      biotrainerTrainingLog: loggingFileData?.content,
      biotrainerCheckpoints: checkpoints,
      //TODO Manual setting of failOnConflict?
      failOnConflict: true,
    );

    if (predictionModel == null) {
      yield log.errored(error: 'Could not load model from files!');
      return;
    }

    yield log.finish(
      result: BiocentralCommandResult(predictionModel, predictionModel.serialize()),
      finalProgress: const BiocentralCommandProgress(
        information: 'Finished loading model from files!',
        current: 1,
        total: 1,
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is PredictionModel) {
      _modelRepository.addModel(commandResult);
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'configFile': _configFile?.name,
      'outputFile': _outputFile?.name,
      'loggingFile': _loggingFile?.name,
      'importMode': _importMode.name,
    };
  }

  @override
  String get typeName => 'LoadModelCommand';
}

final class SplitDataCommand extends BiocentralCommand<BiocentralDatabaseUpdate<BioEntity>> {
  final BiocentralDatabase _database;
  final SplitSetGenerationMode _mode;
  final SplitSetGenerationMethod _method;
  final SplitRatio _splitRatio;

  final BiocentralDatabaseColumn? _selectedSetColumn;
  final SplitSet? _subsplitSource;
  final SplitSet? _subsplitTarget;

  SplitDataCommand({
    required BiocentralDatabase database,
    required SplitSetGenerationMode mode,
    required SplitSetGenerationMethod method,
    required SplitRatio splitRatio,
    BiocentralDatabaseColumn? selectedSetColumn,
    SplitSet? subsplitSource,
    SplitSet? subsplitTarget,
  })  : _database = database,
        _mode = mode,
        _method = method,
        _splitRatio = splitRatio,
        _selectedSetColumn = selectedSetColumn,
        _subsplitSource = subsplitSource,
        _subsplitTarget = subsplitTarget;

  @override
  Stream<BiocentralCommandLog<BiocentralDatabaseUpdate<BioEntity>>> execute() async* {
    BiocentralCommandLog<BiocentralDatabaseUpdate<BioEntity>> log = initLog();
    yield log = log.logInfo(information: 'Calculating splits with method $_method..');

    SplitResult? splitResult;
    if (_mode == SplitSetGenerationMode.generateNew) {
      final Map<String, SplitSet> ids = SetGenerator(splitRatio: _splitRatio).splitByMethod(
        method: _method,
        ids: _database.databaseToMap().keys.toList(),
      );
      final newColumnName = 'SET_${_method.name.toUpperCase()}';
      splitResult = SplitResult(ids, newColumnName);
    } else {
      // Subsplit mode
      if (_selectedSetColumn == null || _subsplitSource == null || _subsplitTarget == null) {
        yield log.errored(error: 'Missing configuration for subsplit!');
        return;
      }
      yield log = log.logInfo(information: 'Creating subsplit..');

      final String sourceColumnName = _selectedSetColumn.name;
      final SplitSet subsplitSource = _subsplitSource;
      final SplitSet subsplitTarget = _subsplitTarget;
      final SplitRatio splitRatio = _splitRatio;

      final existingIds = _selectedSetColumn.ids;
      final Map<String, SplitSet> subsplitResult = SetGenerator(splitRatio: splitRatio).splitByMethod(
        method: _method,
        ids: existingIds,
        subsplitSource: subsplitSource,
        subsplitTarget: subsplitTarget,
      );

      // TODO This adds the remaining sets values to the subsplit
      subsplitResult.addAll(
        Map.fromEntries(
          _selectedSetColumn.values.entries
              .where(
                (entry) =>
                    entry.value.toString() != subsplitSource.name && entry.value.toString() != subsplitTarget.name,
              )
              .map(
                (entry) => MapEntry(
                  entry.key,
                  SplitSet.values.firstWhere((splitVal) => splitVal.name == entry.value.toString()),
                ),
              ),
        ),
      );

      final newColumnName = '${sourceColumnName}_SUBSPLIT';
      splitResult = SplitResult(subsplitResult, newColumnName);
    }
    final databaseUpdate = await _database.addCustomAttributes(
      splitResult.newColumnName,
      splitResult.splits.map((key, value) => MapEntry(key, value.name)),
    );
    yield log.finish(
      result: BiocentralCommandResult(databaseUpdate, databaseUpdate.serialize()),
      finalProgress: BiocentralCommandProgress(
        information: 'Finished calculating splits!',
        current: splitResult.splits.length,
        total: splitResult.splits.length,
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is BiocentralDatabaseUpdate<BioEntity>) {
      _database.acceptDatabaseUpdate(commandResult);
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'databaseType': _database.getType(),
      'mode': _mode.name,
      'method': _method.name,
      'splitRatio': _splitRatio.toString(),
      'selectedSetColumn': _selectedSetColumn?.name,
      'subsplitSource': _subsplitSource?.name,
      'subsplitTarget': _subsplitTarget?.name,
    };
  }

  @override
  String get typeName => 'SplitDataCommand';
}

final class TrainModelCommand extends BiocentralCommand<PredictionModel> {
  final BiocentralAPIRepository _apiRepository;
  final BiocentralDatabase _biocentralDatabase;
  final CustomModelRepository _modelRepository;

  final BiocentralDatabaseColumn _targetColumn;
  final BiocentralDatabaseColumn _setColumn;
  final Map<String, String> _trainingConfiguration;

  TrainModelCommand({
    required BiocentralAPIRepository apiRepository,
    required BiocentralDatabase biocentralDatabase,
    required CustomModelRepository modelRepository,
    required BiocentralDatabaseColumn targetColumn,
    required BiocentralDatabaseColumn setColumn,
    required Map<String, String> trainingConfiguration,
  })  : _apiRepository = apiRepository,
        _biocentralDatabase = biocentralDatabase,
        _modelRepository = modelRepository,
        _targetColumn = targetColumn,
        _setColumn = setColumn,
        _trainingConfiguration = trainingConfiguration;

  @override
  Stream<BiocentralCommandLog<PredictionModel>> execute() async* {
    BiocentralCommandLog<PredictionModel> log = initLog();
    yield log = log.logInfo(information: 'Training new model..');

    // TODO Should be handled more gracefully in the UI directly
    final configVerificationError =
        await _apiRepository.getBiocentralAPI().verifyTrainingConfig(config: _trainingConfiguration);
    if (configVerificationError != null) {
      yield log.errored(error: configVerificationError);
      return;
    }

    // TODO [Feature] Mask Column
    final trainingData = _biocentralDatabase.getTrainingData(targetColumn: _targetColumn, setColumn: _setColumn);

    _trainingConfiguration.remove('target_column');
    _trainingConfiguration.remove('set_column');

    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final biocentralTask = await biocentralAPI.train(config: _trainingConfiguration, trainingData: trainingData);
    final initialModel = _getInitialModel();

    yield* doTraining(biocentralTask, log, initialModel);
  }

  Stream<BiocentralCommandLog<PredictionModel>> doTraining(
    BiocentralServerTask<Map<String, dynamic>?> task,
    BiocentralCommandLog<PredictionModel> log,
    PredictionModel initialModel,
  ) async* {
    yield log = log.logInfo(information: 'Starting training..').logIntermediateResult(
          intermediateResult: BiocentralCommandResult(initialModel, initialModel.getModelInformationMap()),
        );

    PredictionModel currentModel = initialModel;
    int embeddingCurrent = 0;
    int embeddingTotal = 0;
    await for (final (dto, biotrainerResult) in task.run()) {
      if (dto != null) {
        if (dto.status == TaskStatus.RUNNING) {
          if (dto.biotrainerUpdate == null) {
            // Check embedding progress
            embeddingCurrent = dto.embeddingProgress?.current ?? embeddingCurrent;
            embeddingTotal = dto.embeddingProgress?.total ?? embeddingTotal;
            yield log = log.logProgress(
              progress: BiocentralCommandProgress(
                information: 'Embedding..',
                current: embeddingCurrent,
                total: embeddingTotal,
              ),
            );
          } else {
            currentModel = currentModel.updateFromDTO(dto);
            // TODO Support Cross Validation properly
            final int? currentEpoch = currentModel.holdOutResult?.getLastEpoch();
            final commandProgress = currentEpoch != null
                ? BiocentralCommandProgress(
                    information: 'Training model..',
                    current: currentEpoch,
                    hint: 'Epoch',
                  )
                : null;
            if (commandProgress != null) {
              yield log = log.logProgress(progress: commandProgress);
            }
            yield log = log.logIntermediateResult(
              intermediateResult: BiocentralCommandResult(currentModel, currentModel.getModelInformationMap()),
            );
          }
        }
      } else if (biotrainerResult != null) {
        currentModel = PredictionModel.deserialize(biotrainerResult) ?? currentModel;
        yield log.finish(
          result: BiocentralCommandResult(currentModel, currentModel.getModelInformationMap()),
          // TODO Epochs instead of 1 1
          finalProgress: const BiocentralCommandProgress(information: 'Finished training model!', current: 1, total: 1),
        );
        return;
      }
    }
  }

  PredictionModel _getInitialModel() {
    return PredictionModel.fromTrainingConfig(_trainingConfiguration)
        .copyWith(trainingStatus: BiocentralTaskStatus.running);
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'databaseType': _biocentralDatabase.getEntityTypeName(),
      'targetColumn': _targetColumn.name,
      'setColumn': _setColumn.name,
      'trainingConfiguration': _trainingConfiguration,
    };
  }

  @override
  String get typeName => 'TrainModelCommand';

  @override
  void acceptResult(BiocentralCommandLog<dynamic>? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is PredictionModel) {
      _modelRepository.addModel(commandResult);
    }
  }
}

final class InferenceCommand extends BiocentralCommand<BiocentralDatabaseUpdate<BioEntity>> {
  final BiocentralDatabase _biocentralDatabase;
  final BiocentralAPIRepository _apiRepository;

  final String _predictionColumnName;
  final PredictionModel _predictionModel;
  final Set<String> _selectedEntityIDs;

  InferenceCommand(
      {required BiocentralDatabase biocentralDatabase,
      required BiocentralAPIRepository apiRepository,
      required String predictionColumnName,
      required PredictionModel predictionModel,
      required Set<String> selectedEntityIDs})
      : _biocentralDatabase = biocentralDatabase,
        _apiRepository = apiRepository,
        _predictionColumnName = predictionColumnName,
        _predictionModel = predictionModel,
        _selectedEntityIDs = selectedEntityIDs;

  @override
  Stream<BiocentralCommandLog<BiocentralDatabaseUpdate<BioEntity>>> execute() async* {
    BiocentralCommandLog<BiocentralDatabaseUpdate<BioEntity>> log = initLog();
    yield log = log.logInfo(information: 'Inference from trained model..');

    final Map<String, String> sequenceData = _biocentralDatabase.getSequences()?.filterWithKey(
              (k, v) => _selectedEntityIDs.contains(k),
            ) ??
        {};

    if (sequenceData.isEmpty) {
      yield log.errored(error: 'Could not find any entities for inference!');
      return;
    }

    if (_predictionModel.modelHash == null) {
      yield log.errored(error: 'Could not find model hash for inference!');
      return;
    }

    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final biocentralTask =
        await biocentralAPI.inference(modelHash: _predictionModel.modelHash!, sequenceData: sequenceData);

    int embeddingCurrent = 0;
    int embeddingTotal = 0;
    await for (final (dto, predictions) in biocentralTask.run()) {
      if (dto != null) {
        if (dto.status == TaskStatus.RUNNING) {
          if (dto.embeddingProgress != null) {
            // Check embedding progress
            embeddingCurrent = dto.embeddingProgress?.current ?? embeddingCurrent;
            embeddingTotal = dto.embeddingProgress?.total ?? embeddingTotal;
            yield log = log.logProgress(
              progress: BiocentralCommandProgress(
                information: 'Embedding..',
                current: embeddingCurrent,
                total: embeddingTotal,
              ),
            );
          } else {
            // TODO Handle prediction progress
          }
        }
      } else if (predictions != null) {
        // TODO Can be simplified
        final allPredictions = predictions.map((k, v) => MapEntry(k, v.firstOrNull?.value?.toString() ?? 'N/A'));
        yield log = log.logProgress(
          progress: BiocentralCommandProgress(
            information: 'Finished inference, updating database..',
            current: 0,
            total: allPredictions.length,
          ),
        );
        final databaseUpdate = await _biocentralDatabase.addCustomAttributes(_predictionColumnName, allPredictions);
        yield log.finish(
          result: BiocentralCommandResult(databaseUpdate, databaseUpdate.info()),
          finalProgress: BiocentralCommandProgress(
            information: 'Finished inference!',
            current: allPredictions.length,
            total: allPredictions.length,
          ),
        );
        return;
      }
    }
    yield log.errored(error: 'Did not receive predictions!');
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'databaseType': _biocentralDatabase.getEntityTypeName(),
      'predictionModel': _predictionModel.getReadableModelID(),
      'predictionColumnName': _predictionColumnName,
      'selectedEntityIDs': _selectedEntityIDs.toList(),
    };
  }

  @override
  String get typeName => 'InferenceCommand';

  @override
  void acceptResult(BiocentralCommandLog<dynamic>? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is BiocentralDatabaseUpdate) {
      _biocentralDatabase.acceptDatabaseUpdate(commandResult as BiocentralDatabaseUpdate<BioEntity>);
    }
  }
}
