import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:biocentral/sdk/util/logging.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
