import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:biocentral/sdk/util/logging.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class BiocentralCommandState<T extends BiocentralCommandState<T>> extends Equatable {
  final BiocentralCommandStateInformation stateInformation;
  final BiocentralCommandStatus status;

  const BiocentralCommandState(this.stateInformation, this.status);

  T newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status);

  const BiocentralCommandState.idle()
      : stateInformation = const BiocentralCommandStateInformation.empty(),
        status = BiocentralCommandStatus.idle;

  bool isIdle() {
    return status == BiocentralCommandStatus.idle;
  }

  bool isOperating() {
    return status == BiocentralCommandStatus.operating;
  }

  bool isFinished() {
    return status == BiocentralCommandStatus.finished;
  }

  bool isErrored() {
    return status == BiocentralCommandStatus.errored;
  }

  T setTaskID(String taskID) {
    return newState(
        BiocentralCommandStateInformation(information: stateInformation.information, serverTaskID: taskID), status);
  }

  T setIdle({String? information}) {
    return newState(BiocentralCommandStateInformation(information: information ?? ''), BiocentralCommandStatus.idle);
  }

  T setOperating({required String information, BiocentralCommandProgress? commandProgress}) {
    return newState(
      BiocentralCommandStateInformation(information: information, commandProgress: commandProgress),
      BiocentralCommandStatus.operating,
    );
  }

  T updateOperating({required BiocentralCommandProgress commandProgress}) {
    return newState(
      BiocentralCommandStateInformation(information: stateInformation.information, commandProgress: commandProgress),
      BiocentralCommandStatus.operating,
    );
  }

  T setFinished({required String information, BiocentralCommandProgress? commandProgress}) {
    return newState(
      BiocentralCommandStateInformation(information: information, commandProgress: commandProgress),
      BiocentralCommandStatus.finished,
    );
  }

  T setErrored({required String information}) {
    return newState(BiocentralCommandStateInformation(information: information), BiocentralCommandStatus.errored);
  }

  T copyWith({required Map<String, dynamic> copyMap}) {
    return newState(this.stateInformation, this.status);
  }
}

@immutable
class BiocentralCommandProgress {
  final int current;
  final int? total;

  final double? progress;
  final String? hint;

  final bool isByteProgress; // For downloads

  const BiocentralCommandProgress({required this.current, this.total, this.hint, this.isByteProgress = false})
      : progress = total != null ? current / total : null;

  BiocentralCommandProgress.fromDownloadProgress(DownloadProgress downloadProgress)
      : current = downloadProgress.bytesReceived,
        total = downloadProgress.totalBytes,
        progress = downloadProgress.progress,
        hint = null,
        isByteProgress = true;
}

@immutable
class BiocentralCommandStateInformation {
  final String information;
  final String? serverTaskID;
  final BiocentralCommandProgress? commandProgress;

  const BiocentralCommandStateInformation({required this.information, this.serverTaskID, this.commandProgress});

  const BiocentralCommandStateInformation.empty()
      : information = '',
        serverTaskID = null,
        commandProgress = null;
}

enum BiocentralCommandStatus { idle, operating, finished, errored }

abstract class BiocentralSimpleUIUpdateEvent {
  final Map<String, dynamic> updates;

  BiocentralSimpleUIUpdateEvent(this.updates);
}

@immutable
abstract class BiocentralSimpleUIState<T extends BiocentralSimpleUIState<T>> extends Equatable {
  const BiocentralSimpleUIState();

  T updateFromUIEvent(BiocentralSimpleUIUpdateEvent event);
}

abstract class BiocentralSimpleMultiTypeUIUpdateEvent {
  final Set<dynamic> updates;

  BiocentralSimpleMultiTypeUIUpdateEvent(this.updates) {
    checkForDuplicateTypes();
  }

  void checkForDuplicateTypes() {
    final types = updates.map((u) => u.runtimeType).toSet();
    if (types.length != updates.length) {
      const String errorMessage = 'Duplicate types found in multi type update event!';
      logger.e(errorMessage);
      throw Exception(errorMessage);
    }
  }
}

@immutable
abstract class BiocentralSimpleMultiTypeUIState<T extends BiocentralSimpleMultiTypeUIState<T>> extends Equatable {
  const BiocentralSimpleMultiTypeUIState();

  T updateFromUIEvent(BiocentralSimpleMultiTypeUIUpdateEvent event);

  V? getValueFromEvent<V>(V? stateValue, BiocentralSimpleMultiTypeUIUpdateEvent event) {
    for (dynamic value in event.updates) {
      if (value.runtimeType == V) {
        return value;
      }
    }
    return stateValue;
  }
}
