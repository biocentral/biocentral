import 'package:biocentral/sdk/model/column_wizard_abstract.dart';
import 'package:biocentral/sdk/model/column_wizard_defaults.dart';
import 'package:flutter/material.dart';

class BiocentralColumnWizardRepository {
  final Map<Type, ColumnWizardFactory> _factories = {};
  final Map<Type, Widget Function(ColumnWizard)?> _customColumnWizardDisplayFunctions = {};
  final List<TypeDetector> _detectors = [];

  BiocentralColumnWizardRepository.withDefaultWizards() {
    registerFactories(
        {IntColumnWizardFactory(): null, DoubleColumnWizardFactory(): null, StringColumnWizardFactory(): null});
  }

  void registerFactories(Map<ColumnWizardFactory, Widget Function(ColumnWizard)?> factoriesToBuildFunctions) {
    for (final entry in factoriesToBuildFunctions.entries) {
      _registerFactory(entry);
    }
  }

  void _registerFactory(MapEntry<ColumnWizardFactory, Widget Function(ColumnWizard)?> entry) {
    final factory = entry.key;
    final buildFunction = entry.value;
    final TypeDetector detector = factory.getTypeDetector();
    _factories[detector.type] = factory;
    _customColumnWizardDisplayFunctions[detector.type] = buildFunction;
    _detectors.add(detector);
    _sortDetectors();
  }

  void _sortDetectors() {
    _detectors.sort((b, a) => a.priority.compareTo(b.priority));
  }

  Future<T> getColumnWizardForColumn<T extends ColumnWizard>({
    required String columnName,
    required Map<String, dynamic> valueMap,
    Type? columnType,
  }) async {
    columnType ??= await _detectColumnType(valueMap.values);
    if (_factories.containsKey(columnType)) {
      final columnWizard = _factories[columnType]!.create(columnName: columnName, valueMap: valueMap) as T;
      return columnWizard;
    }
    // TODO Exception handling
    throw Exception('No factory registered for column type: $columnType');
  }

  Widget Function(ColumnWizard)? getCustomBuildFunctionForColumnWizard(ColumnWizard columnWizard) {
    return _customColumnWizardDisplayFunctions[columnWizard.type];
  }

  Future<Type> _detectColumnType(Iterable<dynamic> values) async {
    final Set<dynamic> valuesSet = values.toSet();

    for (TypeDetector detector in _detectors) {
      bool isValidType = true;
      for (final value in valuesSet) {
        if (!detector.detectionFunction(value)) {
          isValidType = false;
          break;
        }
      }
      if (isValidType) {
        return detector.type;
      }
    }

    // If no type is detected, return String as the default
    return String;
  }
}
