import 'dart:typed_data';

import 'package:biocentral/sdk/biocentral_sdk.dart';

import '../data/biotrainer_file_handler.dart';
import '../model/prediction_model.dart';

class PredictionModelRepository {
  final List<PredictionModel> _predictionModels = [];

  List<PredictionModel> addModel(PredictionModel predictionModel) {
    _predictionModels.add(predictionModel);
    return List.from(_predictionModels);
  }

  Future<void> addModelFromBiotrainerFiles(
      {String? configFile,
      String? outputFile,
      String? loggingFile,
      Map<String, Uint8List>? checkpointFiles,
      DatabaseImportMode databaseImportMode = DatabaseImportMode.overwrite}) async {
    PredictionModel predictionModel = BiotrainerFileHandler.parsePredictionModelFromRawFiles(
        biotrainerConfig: configFile,
        biotrainerOutput: outputFile,
        biotrainerTrainingLog: loggingFile,
        biotrainerCheckpoints: checkpointFiles,
        //TODO Manual setting of failOnConflict?
        failOnConflict: true);

    if (predictionModel.isNotEmpty()) {
      _predictionModels.add(predictionModel);
    }
  }

  List<PredictionModel> predictionModelsToList() {
    return List.from(_predictionModels);
  }
}
