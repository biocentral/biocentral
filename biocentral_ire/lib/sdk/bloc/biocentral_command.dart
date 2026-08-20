import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:biocentral/sdk/domain/biocentral_database.dart';
import 'package:biocentral/sdk/util/type_util.dart';
import 'package:flutter/material.dart';

abstract class BiocentralCommand<R> with TypeNameMixin {
  Stream<BiocentralCommandLog<R>> execute();

  /// Must contain one entry per config attribute
  Map<String, dynamic> getConfigMap();

  /// Accept Result after execution
  void acceptResult(BiocentralCommandLog? resultLog);

  BiocentralCommandLog<R> initLog() {
    return BiocentralCommandLog<R>.initialize(
      commandName: typeName,
      commandConfig: getConfigMap(),
      startTime: DateTime.now(),
    );
  }
}

abstract class BiocentralResumableCommand<R> extends BiocentralCommand<R> {
  /// Resume execution from intermediate result received via taskID
  Stream<BiocentralCommandLog<R>> resumeExecution(
    String taskID,
  );
}

final class BiocentralCommandResult<R> {
  final R? result;
  final Map<String, dynamic> resultMap; // Result Map that can be used to reconstruct the result after serializing

  BiocentralCommandResult(this.result, this.resultMap);

  factory BiocentralCommandResult.deserialize(Map<String, dynamic> jsonMap) {
    return BiocentralCommandResult(null, jsonMap);
  }

  Map<String, dynamic> info() {
    final Map<String, dynamic> infoMap = {'type': result.runtimeType.toString()};
    switch (result) {
      case final Map r:
        return infoMap..addAll({'values': r.length});
      case final Set s:
        return infoMap..addAll({'values': s.length});
      case final List l:
        return infoMap..addAll({'values': l.length});
      case int _:
      case double _:
      case bool _:
        return infoMap..addAll({'result': result.toString()});
      case final BiocentralDatabaseUpdate update:
        return infoMap..addAll(update.info());
      case final ProjectionData umap:
        return infoMap
          ..addAll({
            'identifier': umap.identifier,
            'values': umap.coordinates.length,
            'maxX': umap.maxX(),
            'maxY': umap.maxY(),
          });
      default:
        return infoMap..addAll(resultMap);
    }
  }
}

@immutable
class BiocentralCommandProgress {
  final String information;
  final int current;
  final int? total;

  final String? hint; // Type of progress (e.g. percent, epoch, ...)

  final bool isByteProgress; // For downloads

  const BiocentralCommandProgress(
      {required this.information, required this.current, this.total, this.hint, this.isByteProgress = false});

  const BiocentralCommandProgress.initial()
      : information = 'Command initialized',
        current = 0,
        total = null,
        hint = null,
        isByteProgress = false;

  BiocentralCommandProgress.fromDownloadProgress(DownloadProgress downloadProgress)
      : information = downloadProgress.isDone() ? 'Download finished!' : 'Downloading..',
        current = downloadProgress.bytesReceived,
        total = downloadProgress.totalBytes,
        hint = null,
        isByteProgress = true;

  factory BiocentralCommandProgress.deserialize(Map<String, dynamic> jsonMap) {
    return BiocentralCommandProgress(
      information: jsonMap['information'] as String,
      current: jsonMap['current'] as int,
      total: jsonMap['total'] as int?,
      hint: jsonMap['hint'] as String?,
      isByteProgress: jsonMap['isByteProgress'] as bool? ?? false,
    );
  }

  BiocentralCommandProgress info(String information) {
    return BiocentralCommandProgress(
        information: information, current: current, total: total, hint: hint, isByteProgress: isByteProgress);
  }

  double? progress() {
    // Returns progress in percent
    if (total != null) {
      if (current == total) {
        return 1.0; // Avoid division by 0
      }
      if (total == 0) {
        return null;
      }
      return (current / total!);
    }
    ;
    return null;
  }

  bool isDone() => total != null ? current == total : false;

  Map<String, dynamic> serialize() {
    return {
      'information': information,
      'current': current,
      'total': total,
      'hint': hint,
      'isByteProgress': isByteProgress,
    };
  }
}

final class BiocentralCommandMetaData {
  final List<BiocentralCommandProgress> progressLog;

  final String? error;
  final String? serverTaskID;
  final DateTime startTime;
  final DateTime? endTime;

  BiocentralCommandMetaData._internal(
      {required this.progressLog, required this.startTime, this.error, this.serverTaskID, this.endTime});

  BiocentralCommandMetaData.initialize()
      : progressLog = [const BiocentralCommandProgress.initial()],
        error = null,
        serverTaskID = null,
        startTime = DateTime.now(),
        endTime = null;

  BiocentralCommandMetaData logInfo(String information) {
    return BiocentralCommandMetaData._internal(
      progressLog: progressLog..add(progressLog.last.info(information)),
      startTime: startTime,
      error: error,
      serverTaskID: serverTaskID,
      endTime: endTime,
    );
  }

  BiocentralCommandMetaData logProgress(BiocentralCommandProgress progress) {
    return BiocentralCommandMetaData._internal(
      progressLog: progressLog..add(progress),
      startTime: startTime,
      error: error,
      serverTaskID: serverTaskID,
      endTime: endTime,
    );
  }

  BiocentralCommandMetaData logError(String error) {
    return BiocentralCommandMetaData._internal(
      progressLog: progressLog,
      startTime: startTime,
      error: error,
      serverTaskID: serverTaskID,
      endTime: endTime, // TODO Use current time?
    );
  }

  BiocentralCommandMetaData finish(BiocentralCommandProgress finalProgress) {
    return BiocentralCommandMetaData._internal(
      progressLog: progressLog..add(finalProgress),
      startTime: startTime,
      error: error,
      // TODO Check that error is null
      serverTaskID: serverTaskID,
      endTime: DateTime.now(),
    );
  }

  factory BiocentralCommandMetaData.deserialize(Map<String, dynamic> jsonMap) {
    final progressLog = jsonMap['progressLog'] as List? ?? [];
    final List<BiocentralCommandProgress> progressLogDeserialized =
        progressLog.map((dynamic item) => BiocentralCommandProgress.deserialize(item as Map<String, dynamic>)).toList();
    final startTime = jsonMap['startTime'];
    final endTime = jsonMap['endTime'] ?? '';
    final serverTaskID = jsonMap['serverTaskID'];
    return BiocentralCommandMetaData._internal(
      progressLog: progressLogDeserialized,
      startTime: DateTime.parse(startTime),
      endTime: DateTime.tryParse(endTime),
      serverTaskID: serverTaskID,
    );
  }

  BiocentralCommandMetaData addTaskID(String taskID) {
    // TODO Check that there is no serverTaskID already
    return BiocentralCommandMetaData._internal(
      progressLog: progressLog,
      startTime: startTime,
      error: error,
      serverTaskID: taskID,
      endTime: endTime,
    );
  }

  Duration? timeToExecute() {
    return endTime?.difference(startTime);
  }

  Map<String, dynamic> serialize() {
    final Map<String, dynamic> result = {
      'startTime': startTime.toString(),
    };
    if (endTime != null) {
      result.addAll({
        'endTime': endTime.toString(),
        'timeToExecute': timeToExecute()?.inSeconds,
      });
    }
    if (serverTaskID != null) {
      result.addAll({'serverTaskID': serverTaskID});
    }
    result.addAll({'progressLog': progressLog.map((pLog) => pLog.serialize()).toList()});
    return result;
  }

  BiocentralCommandProgress latestProgress() => progressLog.last;
}

final class BiocentralCommandLog<R> {
  final String commandName;
  final Map<String, dynamic> commandConfig;
  final BiocentralCommandStatus commandStatus;
  final BiocentralCommandMetaData metaData;
  final BiocentralCommandResult<R>? intermediateResult;
  final BiocentralCommandResult<R>? result;

  BiocentralCommandLog.initialize({
    required this.commandName,
    required this.commandConfig,
    required DateTime startTime,
  })  : commandStatus = BiocentralCommandStatus.operating,
        metaData = BiocentralCommandMetaData.initialize(),
        intermediateResult = null,
        result = null;

  BiocentralCommandLog._internal(
    this.commandName,
    this.commandConfig,
    this.commandStatus,
    this.metaData,
    this.intermediateResult,
    this.result,
  );

  BiocentralCommandLog<R> logInfo({required String information}) {
    return BiocentralCommandLog<R>._internal(
      commandName,
      commandConfig,
      commandStatus,
      metaData.logInfo(information),
      intermediateResult,
      result,
    );
  }

  BiocentralCommandLog<R> logProgress({required BiocentralCommandProgress progress}) {
    return BiocentralCommandLog<R>._internal(
      commandName,
      commandConfig,
      commandStatus,
      metaData.logProgress(progress),
      intermediateResult,
      result,
    );
  }

  BiocentralCommandLog<R> logIntermediateResult({required BiocentralCommandResult<R> intermediateResult}) {
    return BiocentralCommandLog<R>._internal(
      commandName,
      commandConfig,
      commandStatus,
      metaData,
      intermediateResult,
      result,
    );
  }

  BiocentralCommandLog<R> finish(
      {required BiocentralCommandResult<R> result, required BiocentralCommandProgress finalProgress}) {
    return BiocentralCommandLog<R>._internal(
      commandName,
      commandConfig,
      BiocentralCommandStatus.finished,
      metaData.finish(finalProgress),
      null,
      result,
    );
  }

  BiocentralCommandLog<R> errored({required String error}) {
    return BiocentralCommandLog<R>._internal(
      commandName,
      commandConfig,
      BiocentralCommandStatus.errored,
      metaData.logError(error),
      intermediateResult,
      result,
    );
  }

  factory BiocentralCommandLog.deserialize(Map<String, dynamic> jsonMap) {
    final commandName = jsonMap['commandName'];
    final commandConfig = jsonMap['commandConfig'];
    // TODO Enum conversion not perfect here
    final commandStatus =
        enumFromString(jsonMap['status'], BiocentralCommandStatus.values) ?? BiocentralCommandStatus.errored;
    final metaData = jsonMap['metaData'];

    final metaDataReconstructed = BiocentralCommandMetaData.deserialize(metaData);

    final intermediateResult =
        BiocentralCommandResult.deserialize(jsonMap['intermediateResult']) as BiocentralCommandResult<R>;

    final result = BiocentralCommandResult.deserialize(jsonMap['result']) as BiocentralCommandResult<R>;

    return BiocentralCommandLog._internal(
      commandName,
      commandConfig,
      commandStatus,
      metaDataReconstructed,
      intermediateResult,
      result,
    );
  }

  BiocentralCommandLog addTaskID(String taskID) {
    final updatedMetaData = metaData.addTaskID(taskID);
    return BiocentralCommandLog._internal(
      commandName,
      commandConfig,
      commandStatus,
      updatedMetaData,
      intermediateResult,
      result,
    );
  }

  Map<String, dynamic> serialize() {
    return {
      'commandName': commandName,
      'commandConfig': commandConfig,
      'status': commandStatus.name,
      'metaData': metaData.serialize(),
      'intermediateResult': intermediateResult?.info() ?? {},
      'result': result?.info() ?? {},
    };
  }
}

enum BiocentralCommandStatus { idle, operating, finished, errored }
