import 'package:biocentral/sdk/util/seed_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dateSeed', () {
    test('concatenates the zero-padded day and month', () {
      expect(dateSeed(DateTime(2026, 10, 15)), equals(1510));
      expect(dateSeed(DateTime(2026, 3, 5)), equals(503));
      expect(dateSeed(DateTime(2026, 12, 31)), equals(3112));
    });

    test('keeps dates apart that unpadded digits would merge', () {
      expect(dateSeed(DateTime(2026, 11)), equals(111)); // 1 Nov
      expect(dateSeed(DateTime(2026, 1, 11)), equals(1101));
    });
  });
}
