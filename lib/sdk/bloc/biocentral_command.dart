import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/bloc/biocentral_state.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/util/type_util.dart';
import 'package:fpdart/fpdart.dart';

abstract class BiocentralCommand<R> with TypeNameMixin {
  // Either is used to carry a state or result.
  // Yield result before last state in order to ensure correct logging.
  Stream<Either<T, R>> execute<T extends BiocentralCommandState<T>>(T state);

  /// Must contain one entry per config attribute
  Map<String, dynamic> getConfigMap();

  Stream<Either<T, R>> executeWithLogging<T extends BiocentralCommandState<T>>(
    BiocentralProjectRepository projectRepository,
    T state,
  ) async* {
    final DateTime startTime = DateTime.now();

    // Log operating command before starting
    projectRepository.logCommand(
      BiocentralCommandLog<R>.operating(commandName: typeName, commandConfig: getConfigMap(), startTime: startTime),
    );

    bool encounteredError = false;
    await for (final result in this.execute(state)) {
      result.match(
        (leftState) {
          // Ignore at the moment
          if (leftState.isErrored()) {
            encounteredError = true;
          }
        },
        (rightResult) {
          final DateTime endTime = DateTime.now();
          // Finished, log successful command
          // TODO Remove state information list, replace with other metadata
          projectRepository.logCommand(
            BiocentralCommandLog<R>.finished(
                commandName: typeName,
                commandConfig: getConfigMap(),
                startTime: startTime,
                endTime: endTime,
                result: rightResult),
          );
        },
      );
      yield result;
      if (encounteredError) {
        break;
      }
    }
  }
}

abstract class BiocentralResumableCommand<R> extends BiocentralCommand<R> {
  /// Resume execution from intermediate result received via taskID
  Stream<Either<T, R>> resumeExecution<T extends BiocentralCommandState<T>>(
    String taskId,
    T state,
  );
}

final class BiocentralCommandLog<R> {
  final String commandName;
  final Map<String, dynamic> commandConfig;
  final BiocentralCommandStatus commandStatus;
  final BiocentralCommandMetaData metaData;
  final BiocentralCommandResultData? resultData;

  BiocentralCommandLog.operating({
    required this.commandName,
    required this.commandConfig,
    required DateTime startTime,
  })  : commandStatus = BiocentralCommandStatus.operating,
        metaData = BiocentralCommandMetaData(startTime: startTime),
        resultData = null;

  BiocentralCommandLog.finished({
    required this.commandName,
    required this.commandConfig,
    required DateTime startTime,
    required DateTime endTime,
    required R result,
  })  : commandStatus = BiocentralCommandStatus.finished,
        metaData = BiocentralCommandMetaData(startTime: startTime, endTime: endTime),
        resultData = BiocentralCommandResultData.fromResult(result);

  BiocentralCommandLog._internal(
      this.commandName, this.commandConfig, this.commandStatus, this.metaData, this.resultData);

  factory BiocentralCommandLog.fromJsonMap(Map<String, dynamic> jsonMap) {
    final commandName = jsonMap['commandName'];
    final commandConfig = jsonMap['commandConfig'];
    // TODO Enum conversion not perfect here
    final commandStatus =
        enumFromString(jsonMap['commandStatus'], BiocentralCommandStatus.values) ?? BiocentralCommandStatus.errored;
    final metaData = jsonMap['metaData'];
    final resultData = jsonMap['resultData'] ?? {};

    final metaDataReconstructed = BiocentralCommandMetaData.fromJsonMap(metaData);

    final resultDataReconstructed = BiocentralCommandResultData.fromJsonMap(resultData);

    return BiocentralCommandLog._internal(
        commandName, commandConfig, commandStatus, metaDataReconstructed, resultDataReconstructed);
  }

  Map<String, dynamic> toMap() {
    return {
      'commandName': commandName,
      'commandConfig': commandConfig,
      'status': commandStatus.name,
      'metaData': metaData.toMap(),
      'resultData': resultData?.resultMap ?? {},
    };
  }
}

final class BiocentralCommandMetaData {
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? timeToExecute;

  BiocentralCommandMetaData({required this.startTime, this.endTime}) : timeToExecute = endTime?.difference(startTime);

  factory BiocentralCommandMetaData.fromJsonMap(Map<String, dynamic> jsonMap) {
    final startTime = jsonMap['startTime'];
    final endTime = jsonMap['endTime'] ?? '';
    return BiocentralCommandMetaData(startTime: DateTime.parse(startTime), endTime: DateTime.tryParse(endTime));
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> result = {
      'startTime': startTime.toString(),
    };
    if (endTime != null && timeToExecute != null) {
      result.addAll({
        'endTime': endTime.toString(),
        'timeToExecute': timeToExecute?.inSeconds,
      });
    }
    return result;
  }
}

final class BiocentralCommandResultData<R> {
  final Map<String, dynamic> resultMap;

  BiocentralCommandResultData._({required this.resultMap});

  factory BiocentralCommandResultData.fromResult(R result) {
    final Map<String, dynamic> resultMap = _getResultMapFromResult<R>(result);
    return BiocentralCommandResultData._(resultMap: resultMap);
  }

  factory BiocentralCommandResultData.fromJsonMap(Map<String, dynamic> resultMap) {
    return BiocentralCommandResultData._(resultMap: resultMap);
  }

  static Map<String, dynamic> _getResultMapFromResult<R>(R result) {
    final Map<String, dynamic> resultMap = {'type': result.runtimeType.toString()};
    switch (result) {
      case final Map r:
        return resultMap..addAll({'values': r.length});
      case final Set s:
        return resultMap..addAll({'values': s.length});
      case final List l:
        return resultMap..addAll({'values': l.length});
      case int _:
      case double _:
      case bool _:
        return resultMap..addAll({'result': result.toString()});
      case final ProjectionData umap:
        return resultMap
          ..addAll({
            'identifier': umap.identifier,
            'values': umap.coordinates.length,
            'maxX': umap.maxX(),
            'maxY': umap.maxY(),
          });
      default:
        return resultMap;
    }
  }
}
