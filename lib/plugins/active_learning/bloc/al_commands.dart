import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/domain/al_repository.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:cross_file/cross_file.dart';

final class LoadALDatabaseCommand extends BiocentralCommand<List<ALCampaign>> {
  final BiocentralProjectRepository _projectRepository;
  final ALRepository _alRepository;

  final XFile _alDBFile;
  final DatabaseImportMode _importMode;

  LoadALDatabaseCommand(
      {required BiocentralProjectRepository projectRepository,
      required ALRepository alRepository,
      required XFile alDBFile,
      required DatabaseImportMode importMode})
      : _projectRepository = projectRepository,
        _alRepository = alRepository,
        _alDBFile = alDBFile,
        _importMode = importMode;

  @override
  Stream<BiocentralCommandLog<List<ALCampaign>>> execute() async* {
    BiocentralCommandLog<List<ALCampaign>> log = initLog();
    yield log = log.logInfo(information: 'Loading active learning campaigns from database file..');

    final LoadedFileData? alDBFileData =
        (await _projectRepository.handleLoad(xFile: _alDBFile, ignoreIfNoFile: true)).getOrElse((l) => null);
    if (alDBFileData == null || alDBFileData.content.isEmpty) {
      yield log.errored(error: 'Could not read model database file!');
      return;
    }
    final campaignJson = jsonDecode(alDBFileData.content);
    final campaignMaps = campaignJson['campaigns'] as List<dynamic>? ?? [];
    final campaigns = campaignMaps
        .map((campaignMap) => ALCampaign.deserialize(campaignMap as Map<String, dynamic>))
        .whereType<ALCampaign>()
        .toList();
    yield log.finish(
      result: BiocentralCommandResult(campaigns, campaignJson),
      finalProgress: BiocentralCommandProgress(
        information: 'Finished loading models!',
        current: campaigns.length,
        total: campaigns.length,
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is List<ALCampaign>) {
      _alRepository.addNewCampaigns(commandResult);
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'alDBFile': _alDBFile.name,
      'importMode': _importMode.name,
    };
  }

  @override
  String get typeName => 'LoadALDatabaseCommand';
}

/// A command to transfer Active Learning training configuration and manage the training process.
class ALIterationCommand extends BiocentralCommand<ActiveLearningIterationResult> {
  final BiocentralDatabase _biocentralDatabase;
  final BiocentralAPIRepository _apiRepository;
  final ALRepository _alRepository;
  final ALCampaign _campaign;
  final ActiveLearningIterationConfig _iterationConfig;

  ALIterationCommand(
      {required BiocentralDatabase biocentralDatabase,
      required BiocentralAPIRepository apiRepository,
      required ALRepository alRepository,
      required ALCampaign campaign,
      required ActiveLearningIterationConfig iterationConfig})
      : _biocentralDatabase = biocentralDatabase,
        _apiRepository = apiRepository,
        _alRepository = alRepository,
        _campaign = campaign,
        _iterationConfig = iterationConfig;

  /// Executes the command to transfer training configuration and manage the training process.
  @override
  Stream<BiocentralCommandLog<ActiveLearningIterationResult>> execute() async* {
    BiocentralCommandLog<ActiveLearningIterationResult> log = initLog();
    yield log = log.logInfo(
      information: 'Running iteration ${_iterationConfig.iteration} '
          'for campaign ${_campaign.config.name}..',
    );

    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final biocentralTask = await biocentralAPI.activeLearningIteration(
      campaignConfig: _campaign.config,
      iterationConfig: _iterationConfig,
    );

    int embeddingCurrent = 0;
    int embeddingTotal = 0;
    await for (final (dto, iterationResult) in biocentralTask.run()) {
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
            yield log = log.logInfo(information: 'Running iteration..');
          }
        }
      } else if (iterationResult != null) {
        yield log.finish(
          // TODO
          result: BiocentralCommandResult(iterationResult, {'suggestions': iterationResult.suggestions.toList()}),
          finalProgress: BiocentralCommandProgress(
            information: 'Finished iteration!',
            current: _iterationConfig.iteration,
            total: _iterationConfig.iteration,
          ),
        );
        return;
      }
    }
    yield log.errored(error: 'Did not receive iteration result!');
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'databaseType': _biocentralDatabase.getEntityTypeName(),
      'campaignConfig': _campaign.config.toString(),
      'iterationConfig': _iterationConfig.toString(),
    };
  }

  @override
  String get typeName => 'ALIterationCommand';

  @override
  void acceptResult(BiocentralCommandLog<dynamic>? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is ActiveLearningIterationResult) {
      _alRepository.addNewResult(_campaign, _iterationConfig, commandResult);
    }
  }
}

final class ALAddExperimentalDataCommand extends BiocentralCommand<BiocentralDatabaseUpdate<BioEntity>> {
  final BiocentralDatabase _database;
  final String _columnName;
  final Map<String, String> _addedData;

  ALAddExperimentalDataCommand(
      {required BiocentralDatabase database, required String columnName, required Map<String, String> addedData})
      : _database = database,
        _columnName = columnName,
        _addedData = addedData;

  @override
  Stream<BiocentralCommandLog<BiocentralDatabaseUpdate<BioEntity>>> execute() async* {
    BiocentralCommandLog<BiocentralDatabaseUpdate<BioEntity>> log = initLog();
    yield log = log.logInfo(information: 'Adding ${_addedData.length} new experimental data points..');

    // TODO Double check that this works as intended
    final databaseUpdate = await _database.addCustomAttributes(
      _columnName,
      _addedData,
    );
    yield log.finish(
      result: BiocentralCommandResult(databaseUpdate, databaseUpdate.serialize()),
      finalProgress: BiocentralCommandProgress(
        information: 'Finished adding data!',
        current: _addedData.length,
        total: _addedData.length,
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
      'columnName': _columnName,
      'addedData': _addedData.toString(),
    };
  }

  @override
  String get typeName => 'ALAddExperimentalDataCommand';
}

final class ALExportCampaignCommand extends BiocentralCommand<String> {
  final BiocentralProjectRepository _projectRepository;
  final ALCampaign _campaign;
  final String _filePath;

  ALExportCampaignCommand({
    required BiocentralProjectRepository projectRepository,
    required ALCampaign campaign,
    required String filePath,
  })  : _projectRepository = projectRepository, _campaign = campaign, _filePath = filePath;

  @override
  Stream<BiocentralCommandLog<String>> execute() async* {
    BiocentralCommandLog<String> log = initLog();
    yield log = log.logInfo(information: 'Exporting campaign "${_campaign.config.name}"...');

    final xFile = XFile(_filePath);
    final fileName = xFile.name;
    final dirPath = _filePath.substring(0, _filePath.length - fileName.length - 1);

    final saveEither = await _projectRepository.handleExternalSave(
      fileName: fileName,
      contentFunction: () async => jsonEncode({'campaigns': [_campaign.serialize()]}),
      dirPath: dirPath,
    );
    yield saveEither.match(
      (l) => log.errored(error: l.message),
      (r) => log.finish(
        result: BiocentralCommandResult(r ?? '', {'filePath': r ?? ''}),
        finalProgress: BiocentralCommandProgress(
          information: 'Campaign "${_campaign.config.name}" exported to $r!',
          current: 1,
          total: 1,
        ),
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    // Export has no side effects on the repository
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'campaignName': _campaign.config.name,
      'filePath': _filePath,
    };
  }

  @override
  String get typeName => 'ALExportCampaignCommand';
}
