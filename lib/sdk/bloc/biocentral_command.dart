import 'package:bio_flutter/bio_flutter.dart';
import 'package:fpdart/fpdart.dart';

import '../domain/biocentral_project_repository.dart';
import 'biocentral_state.dart';

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

    await for (final result in this.execute(state)) {
      result.match(
        (leftState) {
          // Ignore at the moment
        },
        (rightResult) {
          final DateTime endTime = DateTime.now();
          // Finished, log successful command
          // TODO Remove state information list, replace with other metadata
          projectRepository.logCommand(
              BiocentralCommandLog<R>(command: this, startTime: startTime, endTime: endTime, result: rightResult));
        },
      );
      yield result;
    }
  }
}

final class BiocentralCommandLog<R> {
  final BiocentralCommand command;
  final BiocentralCommandMetaData metaData;
  final BiocentralCommandResultData resultData;

  BiocentralCommandLog(
      {required this.command, required DateTime startTime, required DateTime endTime, required R result})
      : metaData = BiocentralCommandMetaData(startTime: startTime, endTime: endTime),
        resultData = BiocentralCommandResultData.fromResult(result);
}

final class BiocentralCommandMetaData {
  final DateTime startTime;
  final DateTime endTime;
  final Duration timeToExecute;

  BiocentralCommandMetaData({required this.startTime, required this.endTime})
      : timeToExecute = endTime.difference(startTime);

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'timeToExecute': timeToExecute,
    };
  }
}

final class BiocentralCommandResultData<R> {
  final Map<String, dynamic> resultMap;

  BiocentralCommandResultData._({required this.resultMap});

  factory BiocentralCommandResultData.fromResult(R result) {
    Map<String, dynamic> resultMap = _getResultMapFromResult<R>(result);
    return BiocentralCommandResultData._(resultMap: resultMap);
  }

  static Map<String, dynamic> _getResultMapFromResult<R>(R result) {
    final Map<String, dynamic> resultMap = {"type": result.runtimeType};
    switch (result) {
      case Map r:
        return resultMap..addAll({"values": r.length});
      case Set s:
        return resultMap..addAll({"values": s.length});
      case List l:
        return resultMap..addAll({"values": l.length});
      case int _:
      case double _:
      case bool _:
        return resultMap..addAll({"result": result.toString()});
      case UMAPData umap:
        return resultMap
          ..addAll({
            "identifier": umap.identifier,
            "values": umap.coordinates.length,
            "maxX": umap.maxX(),
            "maxY": umap.maxY()
          });
      default:
        return resultMap;
    }
  }
}
