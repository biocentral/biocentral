import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/bloc/biocentral_state.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:fpdart/fpdart.dart';

abstract class BiocentralCommand<R> {
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
            BiocentralCommandLog<R>(command: this, startTime: startTime, endTime: endTime, result: rightResult),
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

final class BiocentralReconstructedCommand extends BiocentralCommand {
  final String _originalCommandType;
  final Map<String, dynamic> _originalConfigMap;

  BiocentralReconstructedCommand(this._originalCommandType, this._originalConfigMap);

  @override
  Stream<Either<T, dynamic>> execute<T extends BiocentralCommandState<T>>(T state) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> getConfigMap() => _originalConfigMap;
}

final class BiocentralCommandLog<R> {
  final BiocentralCommand command;
  final BiocentralCommandMetaData metaData;
  final BiocentralCommandResultData resultData;

  BiocentralCommandLog({
    required this.command,
    required DateTime startTime,
    required DateTime endTime,
    required R result,
  })  : metaData = BiocentralCommandMetaData(startTime: startTime, endTime: endTime),
        resultData = BiocentralCommandResultData.fromResult(result);

  BiocentralCommandLog._internal(this.command, this.metaData, this.resultData);

  factory BiocentralCommandLog.fromJsonMap(Map<String, dynamic> jsonMap) {
    final commandType = jsonMap['commandType'];
    final commandConfig = jsonMap['commandConfig'];
    final metaData = jsonMap['metaData'];
    final resultData = jsonMap['resultData'];

    final commandReconstructed = BiocentralReconstructedCommand(commandType, commandConfig);
    final metaDataReconstructed = BiocentralCommandMetaData.fromJsonMap(metaData);
    final resultDataReconstructed = BiocentralCommandResultData.fromJsonMap(resultData);

    return BiocentralCommandLog._internal(commandReconstructed, metaDataReconstructed, resultDataReconstructed);
  }

  Map<String, dynamic> toMap() {
    String commandType = command.runtimeType.toString();
    if (command is BiocentralReconstructedCommand) {
      commandType = (command as BiocentralReconstructedCommand)._originalCommandType;
    }
    return {
      'commandType': commandType,
      'commandConfig': command.getConfigMap(),
      'metaData': metaData.toMap(),
      'resultData': resultData.resultMap,
    };
  }
}

final class BiocentralCommandMetaData {
  final DateTime startTime;
  final DateTime endTime;
  final Duration timeToExecute;

  BiocentralCommandMetaData({required this.startTime, required this.endTime})
      : timeToExecute = endTime.difference(startTime);

  factory BiocentralCommandMetaData.fromJsonMap(Map<String, dynamic> jsonMap) {
    final startTime = jsonMap['startTime'];
    final endTime = jsonMap['endTime'];
    return BiocentralCommandMetaData(startTime: DateTime.parse(startTime), endTime: DateTime.parse(endTime));
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'timeToExecute': timeToExecute.inSeconds,
    };
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
