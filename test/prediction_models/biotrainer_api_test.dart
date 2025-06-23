import 'dart:io';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Prediction Model', () {
    final String outputPath = 'test/test_files/out.yml';
    test('Prediction Model can be loaded from result yaml file', () async {
      final File biotrainerOutput = File(outputPath);
      final PredictionModel? model = BiotrainerFileHandler.parsePredictionModelFromRawFiles(
          biotrainerOutput: biotrainerOutput.readAsStringSync(), failOnConflict: true,);
      if (model == null) {
        fail('Model could not be loaded!');
      }
      expect(model.embedderName, equals('one_hot_encoding'));
      expect(model.modelChoice, equals('CNN'));
      expect(model.databaseType, equals(const Protein.empty().typeName));
      expect(model.protocol, equals(PredictionProtocol.residue_to_class));
    });
  });
}
