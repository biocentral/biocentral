import 'dart:math';

import 'package:biocentral/sdk/model/column_wizard_abstract.dart';
import 'package:flutter/material.dart';

abstract class ColumnWizardOperation<T extends ColumnWizardOperationResult> {
  final String newColumnName;

  ColumnWizardOperation(this.newColumnName);

  Future<T> operate(ColumnWizard columnWizard);
}

abstract class ColumnWizardOperationResult {}

class ColumnWizardAddOperationResult extends ColumnWizardOperationResult {
  final String newColumnName;
  final Map<String, dynamic> newColumnValues;

  ColumnWizardAddOperationResult(this.newColumnName, this.newColumnValues);
}

class ColumnWizardRemoveOperationResult extends ColumnWizardOperationResult {
  final List<int> indicesToRemove;

  ColumnWizardRemoveOperationResult(this.indicesToRemove);
}

class ColumnWizardShuffleOperation extends ColumnWizardOperation<ColumnWizardAddOperationResult> {
  static const int defaultSeed = 42;

  final int seed;

  ColumnWizardShuffleOperation(super.newColumnName, this.seed);

  @override
  Future<ColumnWizardAddOperationResult> operate(ColumnWizard columnWizard) async {
    final Map<String, String> result = {};
    for (final entry in columnWizard.valueMap.entries) {
      final List<String> shuffled = entry.value.toString().characters.toList()..shuffle(Random(seed));
      result[entry.key] = shuffled.join();
    }
    return ColumnWizardAddOperationResult(newColumnName, result);
  }
}

class ColumnWizardToBinaryOperation extends ColumnWizardOperation<ColumnWizardAddOperationResult> {
  static const String defaultValueTrue = 'true';
  static const String defaultValueFalse = 'false';

  final String compareToValue;
  final String valueTrue;
  final String valueFalse;

  ColumnWizardToBinaryOperation(super.newColumnName, this.compareToValue, this.valueTrue, this.valueFalse);

  @override
  Future<ColumnWizardAddOperationResult> operate(ColumnWizard columnWizard) async {
    final Map<String, String> result = {};

    for (final entry in columnWizard.valueMap.entries) {
      result[entry.key] = entry.value.toString() == compareToValue ? valueTrue : valueFalse;
    }
    return ColumnWizardAddOperationResult(newColumnName, result);
  }
}

class ColumnWizardRemoveMissingOperation extends ColumnWizardOperation<ColumnWizardRemoveOperationResult> {
  ColumnWizardRemoveMissingOperation(super.newColumnName);

  @override
  Future<ColumnWizardRemoveOperationResult> operate(ColumnWizard columnWizard) async {
    final List<int> missingIndices = await columnWizard.getMissingIndices();
    return ColumnWizardRemoveOperationResult(missingIndices);
  }
}

enum ColumnWizardOutlierRemovalMethod {
  byStandardDeviation,
}

class ColumnWizardRemoveOutliersOperation extends ColumnWizardOperation<ColumnWizardRemoveOperationResult> {
  final ColumnWizardOutlierRemovalMethod method;

  ColumnWizardRemoveOutliersOperation(super.newColumnName, this.method);

  @override
  Future<ColumnWizardRemoveOperationResult> operate(ColumnWizard columnWizard) async {
    switch(method) {
      case ColumnWizardOutlierRemovalMethod.byStandardDeviation: {
        // TODO Make this more generic
        if(columnWizard is NumericStats) {
          final mean = await columnWizard.mean();
          final stdDev = await columnWizard.stdDev();
          final lowerBound = mean - 2 * stdDev;
          final upperBound = mean + 2 * stdDev;
          final List<int> indicesToRemove = columnWizard.numericValues
              .indexed
              .where((element) => element.$2 < lowerBound || element.$2 > upperBound)
              .map((element) => element.$1)
              .toList();
          return ColumnWizardRemoveOperationResult(indicesToRemove);
        }
      }
    }
    return ColumnWizardRemoveOperationResult([]);
  }
}

class ColumnWizardCalculateLengthOperation extends ColumnWizardOperation<ColumnWizardAddOperationResult> {
  ColumnWizardCalculateLengthOperation(super.newColumnName);

  @override
  Future<ColumnWizardAddOperationResult> operate(ColumnWizard columnWizard) async {
    final Map<String, int> result = Map.fromEntries(
        columnWizard.valueMap.entries.map((entry) => MapEntry(entry.key, entry.value.toString().length)));

    return ColumnWizardAddOperationResult(newColumnName, result);
  }
}

// TODO Replace enum with types to allow extensibility of operations in plugins
enum ColumnOperationType { toBinary, removeMissing, removeOutliers, calculateLength, shuffle }
