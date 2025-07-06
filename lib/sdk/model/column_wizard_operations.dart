import 'dart:math';

import 'package:biocentral/sdk/model/column_wizard_abstract.dart';
import 'package:flutter/material.dart';

abstract class ColumnWizardOperation {
  ColumnWizardOperation();

  Future<ColumnWizardOperationResult> operate(ColumnWizard columnWizard);
}

final class ColumnWizardOperationResult {
  final Map<String, dynamic> newColumnValues;

  ColumnWizardOperationResult(this.newColumnValues);
}

class ColumnWizardShuffleOperation extends ColumnWizardOperation {
  static const int defaultSeed = 42;

  final int seed;

  ColumnWizardShuffleOperation(this.seed);

  @override
  Future<ColumnWizardOperationResult> operate(ColumnWizard columnWizard) async {
    final Map<String, String> result = {};
    for (final entry in columnWizard.valueMap.entries) {
      final List<String> shuffled = entry.value.toString().characters.toList()..shuffle(Random(seed));
      result[entry.key] = shuffled.join();
    }
    return ColumnWizardOperationResult(result);
  }
}

class ColumnWizardToBinaryOperation extends ColumnWizardOperation {
  static const String defaultValueTrue = 'true';
  static const String defaultValueFalse = 'false';

  final String compareToValue;
  final String valueTrue;
  final String valueFalse;

  ColumnWizardToBinaryOperation(this.compareToValue, this.valueTrue, this.valueFalse);

  @override
  Future<ColumnWizardOperationResult> operate(ColumnWizard columnWizard) async {
    final Map<String, String> result = {};

    for (final entry in columnWizard.valueMap.entries) {
      result[entry.key] = entry.value.toString() == compareToValue ? valueTrue : valueFalse;
    }
    return ColumnWizardOperationResult(result);
  }
}

class ColumnWizardRemoveMissingOperation extends ColumnWizardOperation {
  ColumnWizardRemoveMissingOperation();

  @override
  Future<ColumnWizardOperationResult> operate(ColumnWizard columnWizard) async {
    final Set<String> keysWithMissingValues = await columnWizard.getMissingValues();
    final filteredEntries = Map<String, dynamic>.fromEntries(
        columnWizard.valueMap.entries.where((entry) => !keysWithMissingValues.contains(entry.key)));
    return ColumnWizardOperationResult(filteredEntries);
  }
}

enum ColumnWizardOutlierRemovalMethod {
  byStandardDeviation,
}

class ColumnWizardRemoveOutliersOperation extends ColumnWizardOperation {
  final ColumnWizardOutlierRemovalMethod method;

  ColumnWizardRemoveOutliersOperation(this.method);

  @override
  Future<ColumnWizardOperationResult> operate(ColumnWizard columnWizard) async {
    switch (method) {
      case ColumnWizardOutlierRemovalMethod.byStandardDeviation:
        {
          // TODO Make this more generic
          if (columnWizard is NumericStats) {
            final mean = await columnWizard.mean();
            final stdDev = await columnWizard.stdDev();
            final lowerBound = mean - 2 * stdDev;
            final upperBound = mean + 2 * stdDev;
            final Map<String, dynamic> filteredValues = Map<String, dynamic>.fromEntries(
                columnWizard.valueMap.entries.where((entry) => entry.value > lowerBound && entry.value < upperBound));
            return ColumnWizardOperationResult(filteredValues);
          }
        }
    }
    // TODO This should not be reachable
    return ColumnWizardOperationResult({});
  }
}

class ColumnWizardClampOperation extends ColumnWizardOperation {
  final double? low;
  final double? high;

  ColumnWizardClampOperation(this.low, this.high);

  bool _isInRange(num value) {
    bool inRange = true;
    if (low != null) {
      inRange = value > low!;
    }
    if (high != null) {
      inRange = inRange && value < high!;
    }
    return inRange;
  }

  @override
  Future<ColumnWizardOperationResult> operate(ColumnWizard columnWizard) async {
    if (columnWizard is NumericStats) {
      final filteredEntries = Map<String, dynamic>.fromEntries(columnWizard.valueMap.entries
          .where((entry) => _isInRange(entry.value)));
      return ColumnWizardOperationResult(filteredEntries);
    }
    return ColumnWizardOperationResult({});
  }
}

class ColumnWizardCalculateLengthOperation extends ColumnWizardOperation {
  ColumnWizardCalculateLengthOperation();

  @override
  Future<ColumnWizardOperationResult> operate(ColumnWizard columnWizard) async {
    final Map<String, int> result = Map.fromEntries(
        columnWizard.valueMap.entries.map((entry) => MapEntry(entry.key, entry.value.toString().length)));

    return ColumnWizardOperationResult(result);
  }
}

// TODO Replace enum with types to allow extensibility of operations in plugins
enum ColumnOperationType { toBinary, removeMissing, removeOutliers, calculateLength, shuffle, clamp }
