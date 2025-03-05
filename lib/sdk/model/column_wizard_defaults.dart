
import 'package:ml_linalg/vector.dart';

import 'package:biocentral/sdk/model/column_wizard_abstract.dart';
import 'package:biocentral/sdk/model/column_wizard_operations.dart';

abstract class NumColumnWizard extends ColumnWizard {
  NumColumnWizard(super.columnName);

  @override
  Set<ColumnOperationType> getAvailableOperations() {
    return super.getAvailableOperations()..addAll([ColumnOperationType.removeOutliers, ColumnOperationType.clamp]);
  }
}

class IntColumnWizardFactory extends ColumnWizardFactory {
  @override
  ColumnWizard create({required String columnName, required Map<String, dynamic> valueMap}) {
    return IntColumnWizard(
        columnName,
        Map.fromEntries(valueMap.entries.map(
            (entry) => MapEntry(entry.key, entry.value is int ? entry.value : int.parse(entry.value.toString())),),),);
  }

  @override
  TypeDetector getTypeDetector() {
    return TypeDetector(int, (value) => value is int || int.tryParse(value.toString()) != null);
  }
}

class IntColumnWizard extends NumColumnWizard with NumericStats, CounterStats {
  @override
  final Map<String, int> valueMap;

  IntColumnWizard(super.columnName, this.valueMap);

  @override
  Vector get numericValues => Vector.fromList(valueMap.values.map((e) => e.toDouble()).toList());
}

class DoubleColumnWizardFactory extends ColumnWizardFactory {
  @override
  ColumnWizard create({required String columnName, required Map<String, dynamic> valueMap}) {
    return DoubleColumnWizard(
        columnName,
        Map.fromEntries(valueMap.entries.map((entry) =>
            MapEntry(entry.key, entry.value is double ? entry.value : double.parse(entry.value.toString())),),),);
  }

  @override
  TypeDetector getTypeDetector() {
    return TypeDetector(double, (value) => value is double || double.tryParse(value.toString()) != null);
  }
}

class DoubleColumnWizard extends NumColumnWizard with NumericStats, CounterStats {
  @override
  final Map<String, double> valueMap;

  DoubleColumnWizard(super.columnName, this.valueMap);

  @override
  Vector get numericValues => Vector.fromList(valueMap.values.toList());
}

class StringColumnWizardFactory extends ColumnWizardFactory {
  @override
  ColumnWizard create({required String columnName, required Map<String, dynamic> valueMap}) {
    return StringColumnWizard(
        columnName, Map.fromEntries(valueMap.entries.map((entry) => MapEntry(entry.key, entry.value.toString()))),);
  }

  @override
  TypeDetector getTypeDetector() {
    // Every value can be transformed to a string, so detection is always true
    return TypeDetector(String, (value) => true);
  }
}

class StringColumnWizard extends ColumnWizard with CounterStats {
  @override
  final Map<String, String> valueMap;

  StringColumnWizard(super.columnName, this.valueMap);

  @override
  Set<ColumnOperationType> getAvailableOperations() {
    return super.getAvailableOperations()..add(ColumnOperationType.shuffle);
  }

  @override
  Future<bool> handleAsDiscrete() async {
    return true;
  }
}
