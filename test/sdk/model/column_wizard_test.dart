import 'dart:math';

import 'package:biocentral/sdk/biocentral_sdk.dart';

import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';

extension on List<dynamic> {
  Map<String, dynamic> asStringMap() {
    return Map.fromEntries(asMap().entries.map((entry) => MapEntry(entry.key.toString(), entry.value)));
  }
}

void main() {
  group('Column Wizard', () {
    String columnName = "test";
    test('Column Wizard detects column type correctly', () async {
      BiocentralColumnWizardRepository wizardRepo = BiocentralColumnWizardRepository.withDefaultWizards();

      List<String> strings = ["Hallo", "Test", "123"];
      ColumnWizard columnWizard =
          await wizardRepo.getColumnWizardForColumn(columnName: columnName, valueMap: strings.asStringMap());
      expect(columnWizard is StringColumnWizard, equals(true));

      List<int> ints = [1234, 555, -31904, 0];
      columnWizard = await wizardRepo.getColumnWizardForColumn(columnName: columnName, valueMap: ints.asStringMap());
      expect(columnWizard is IntColumnWizard, equals(true));

      List<double> doubles = [125.0, -313.1232, -950.1];
      columnWizard = await wizardRepo.getColumnWizardForColumn(columnName: columnName, valueMap: doubles.asStringMap());
      expect(columnWizard is DoubleColumnWizard, equals(true));

      List<dynamic> mixed = ["Hallo", 1234, 901.23];
      columnWizard = await wizardRepo.getColumnWizardForColumn(columnName: columnName, valueMap: mixed.asStringMap());
      expect(columnWizard is StringColumnWizard, equals(true));
    });
    test('Column Wizard calculates metrics correctly', () async {
      BiocentralColumnWizardRepository wizardRepo = BiocentralColumnWizardRepository.withDefaultWizards();

      List<int> ints = [5, 0, 3, -2];
      ColumnWizard columnWizard =
          await wizardRepo.getColumnWizardForColumn(columnName: columnName, valueMap: ints.asStringMap());
      if (columnWizard is NumericStats) {
        expect(nearEqual(await columnWizard.mean(), 1.5, 0.01), equals(true));
      } else {
        fail("Wrong column wizard type created!");
      }
      List<double> doubles = [1.1, 2.2, 3.3];
      columnWizard = await wizardRepo.getColumnWizardForColumn(columnName: columnName, valueMap: doubles.asStringMap());
      if (columnWizard is NumericStats) {
        expect(nearEqual(await columnWizard.mean(), 2.2, 0.01), equals(true));
      } else {
        fail("Wrong column wizard type created!");
      }
    });
    test('Column Wizard converts continuous values to bins correctly', () async {
      BiocentralColumnWizardRepository wizardRepo = BiocentralColumnWizardRepository.withDefaultWizards();

      List<int> ints = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
      ColumnWizard columnWizard =
          await wizardRepo.getColumnWizardForColumn(columnName: columnName, valueMap: ints.asStringMap());
      if (columnWizard is NumericStats) {
        List<List<double>> bins = await columnWizard.toBins();
        expect(bins.length, equals(10));
        expect(bins[0][0], equals(0.0));
      } else {
        fail("Wrong column wizard type created!");
      }
      ints = [45, 45, 1, 1, 1, 100, 1, 1, 1, 1, 1];
      columnWizard = await wizardRepo.getColumnWizardForColumn(columnName: columnName, valueMap: ints.asStringMap());
      if (columnWizard is NumericStats) {
        List<List<double>> bins = await columnWizard.toBins(numberBins: 3);
        expect(bins.length, equals(3));
        expect(
            bins,
            equals([
              [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
              [45.0, 45.0],
              [100.0]
            ]));
      } else {
        fail("Wrong column wizard type created!");
      }
      int n = 20;
      List<double> doubles = List.generate(n, (index) => Random().nextDouble());
      columnWizard = await wizardRepo.getColumnWizardForColumn(columnName: columnName, valueMap: doubles.asStringMap());
      if (columnWizard is NumericStats) {
        List<List<double>> bins = await columnWizard.toBins();
        expect(bins.length, equals(10));
      } else {
        fail("Wrong column wizard type created!");
      }
      n = 500;
      doubles = List.generate(n, (index) => Random().nextDouble());
      columnWizard = await wizardRepo.getColumnWizardForColumn(columnName: columnName, valueMap: doubles.asStringMap());
      if (columnWizard is NumericStats) {
        List<List<double>> bins = await columnWizard.toBins(numberBins: 5);
        expect(bins.length, equals(5));
      } else {
        fail("Wrong column wizard type created!");
      }
    });
  });
}
