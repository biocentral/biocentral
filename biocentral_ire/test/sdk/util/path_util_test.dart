import 'package:biocentral/sdk/util/path_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Path Scanner', () {
    final String path = 'test';
    test('Path Scanner finds files in tests', () async {
      final scanResult = PathScanner.scanDirectory(path);
      expect(scanResult.subdirectoryResults.isNotEmpty, equals(true));
      PathScanner.printDirectoryStructure(scanResult);
      final allSubDirFiles = scanResult.getAllSubdirectoryFiles();
      print(allSubDirFiles);
      expect(allSubDirFiles.isNotEmpty, equals(true));
    });
  });
}
