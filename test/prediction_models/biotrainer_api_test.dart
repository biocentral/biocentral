import 'dart:io';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Prediction Model', () {
    String outputPath = "test/test_files/out.yml";
    test('Prediction Model can be loaded from result yaml file', () async {
      File biotrainerOutput = File(outputPath);
      PredictionModel model = BiotrainerFileHandler.parsePredictionModelFromRawFiles(
          biotrainerOutput: biotrainerOutput.readAsStringSync(), failOnConflict: true);
      if (model.isEmpty()) {
        fail("Model could not be loaded!");
      }
      expect(model.embedderName, equals("one_hot_encoding"));
      expect(model.architecture, equals("CNN"));
      expect(model.databaseType, equals(Protein));
      expect(model.predictionProtocol, equals(PredictionProtocol.residue_to_class));
    });
  });
}
