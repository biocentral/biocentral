import 'dart:math';

import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_database_column.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';

extension on List<dynamic> {
  Map<String, dynamic> asStringMap() {
    return Map.fromEntries(asMap()
        .entries
        .map((entry) => MapEntry(entry.key.toString(), entry.value)));
  }
}

void main() {
  //group('Column Wizard', () {
  //  final String columnName = 'test';
  //  test('Column Wizard detects column type correctly', () async {
  //    final BiocentralColumnWizardRepository wizardRepo =
  //        BiocentralColumnWizardRepository.withDefaultWizards();
//
  //    var column = BiocentralDatabaseColumn(
  //      name: 'test',
  //      values: {'1': 'Hallo', '2': 'Test', '3': '123'},
  //    );
  //    ColumnWizard columnWizard =
  //        await wizardRepo.getColumnWizardForColumn(column: column);
  //    expect(columnWizard is StringColumnWizard, equals(true));
//
  //    final List<int> ints = [1234, 555, -31904, 0];
  //    column = BiocentralDatabaseColumn(
  //        name: columnName, values: ints.asStringMap());
  //    columnWizard = await wizardRepo.getColumnWizardForColumn(column: column);
  //    expect(columnWizard is IntColumnWizard, equals(true));
//
  //    final List<double> doubles = [125.0, -313.1232, -950.1];
  //    column = BiocentralDatabaseColumn(
  //        name: columnName, values: doubles.asStringMap());
  //    columnWizard = await wizardRepo.getColumnWizardForColumn(column: column);
  //    expect(columnWizard is DoubleColumnWizard, equals(true));
//
  //    final List<dynamic> mixed = ['Hallo', 1234, 901.23];
  //    column = BiocentralDatabaseColumn(
  //        name: columnName, values: mixed.asStringMap());
  //    columnWizard = await wizardRepo.getColumnWizardForColumn(column: column);
  //    expect(columnWizard is StringColumnWizard, equals(true));
  //  });
  //  test('Column Wizard calculates metrics correctly', () async {
  //    final BiocentralColumnWizardRepository wizardRepo =
  //        BiocentralColumnWizardRepository.withDefaultWizards();
//
  //    final List<int> ints = [5, 0, 3, -2];
  //    var column = BiocentralDatabaseColumn(
  //        name: columnName, values: ints.asStringMap());
  //    ColumnWizard columnWizard =
  //        await wizardRepo.getColumnWizardForColumn(column: column);
  //    if (columnWizard is NumericStats) {
  //      expect(nearEqual(await columnWizard.mean(), 1.5, 0.01), equals(true));
  //    } else {
  //      fail('Wrong column wizard type created!');
  //    }
  //    final List<double> doubles = [1.1, 2.2, 3.3];
  //    column = BiocentralDatabaseColumn(
  //        name: columnName, values: doubles.asStringMap());
  //    columnWizard = await wizardRepo.getColumnWizardForColumn(column: column);
  //    expect(nearEqual(await columnWizard.mean(), 2.2, 0.01), equals(true));
  //  });
  //  test('Column Wizard converts continuous values to bins correctly',
  //      () async {
  //    final BiocentralColumnWizardRepository wizardRepo =
  //        BiocentralColumnWizardRepository.withDefaultWizards();
//
  //    List<int> ints = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
  //    var column = BiocentralDatabaseColumn(
  //        name: columnName, values: ints.asStringMap());
  //    ColumnWizard columnWizard =
  //        await wizardRepo.getColumnWizardForColumn(column: column);
  //    if (columnWizard is NumericStats) {
  //      final List<List<double>> bins = await columnWizard.toBins();
  //      expect(bins.length, equals(10));
  //      expect(bins[0][0], equals(0.0));
  //    } else {
  //      fail('Wrong column wizard type created!');
  //    }
  //    ints = [45, 45, 1, 1, 1, 100, 1, 1, 1, 1, 1];
  //    column = BiocentralDatabaseColumn(
  //        name: columnName, values: ints.asStringMap());
  //    columnWizard = await wizardRepo.getColumnWizardForColumn(column: column);
  //    final List<List<double>> bins = await columnWizard.toBins(numberBins: 3);
  //    expect(bins.length, equals(3));
  //    expect(
  //      bins,
  //      equals([
  //        [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
  //        [45.0, 45.0],
  //        [100.0],
  //      ]),
  //    );
  //    int n = 20;
  //    List<double> doubles = List.generate(n, (index) => Random().nextDouble());
  //    column = BiocentralDatabaseColumn(
  //        name: columnName, values: doubles.asStringMap());
  //    columnWizard = await wizardRepo.getColumnWizardForColumn(column: column);
  //    final List<List<double>> bins2 = await columnWizard.toBins();
  //    expect(bins2.length, equals(10));
  //    n = 500;
  //    doubles = List.generate(n, (index) => Random().nextDouble());
  //    column = BiocentralDatabaseColumn(
  //        name: columnName, values: doubles.asStringMap());
  //    columnWizard = await wizardRepo.getColumnWizardForColumn(column: column);
  //    final List<List<double>> bins3 = await columnWizard.toBins(numberBins: 5);
  //    expect(bins3.length, equals(5));
  //  });
  //});
}
