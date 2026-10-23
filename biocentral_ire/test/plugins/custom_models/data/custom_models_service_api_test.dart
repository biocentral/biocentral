import 'package:biocentral/plugins/custom_models/data/custom_models_service_api.dart';
import 'package:biocentral/sdk/model/biocentral_config.dart';
import 'package:flutter_test/flutter_test.dart';

BiocentralConfigOption _option(String name, dynamic defaultValue) => BiocentralConfigOption(
      name: name,
      required: false,
      defaultValue: defaultValue,
      category: 'general',
      description: 'Description of $name',
    );

void main() {
  group('filterBiotrainerOptionsForBiocentral', () {
    test("replaces biotrainer's default seed with today's date as DDMM", () {
      final DateTime now = DateTime.now();
      final int today = int.parse('${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}');

      final seed = filterBiotrainerOptionsForBiocentral([_option('seed', 42)]).single;

      expect(seed.defaultValue, equals(today));
      expect(seed.name, equals('seed'));
      expect(seed.category, equals('general'));
      expect(seed.description, equals('Description of seed'));
    });

    test('leaves other defaults alone', () {
      final epochs = filterBiotrainerOptionsForBiocentral([_option('num_epochs', 200)]).single;

      expect(epochs.defaultValue, equals(200));
    });
  });
}
