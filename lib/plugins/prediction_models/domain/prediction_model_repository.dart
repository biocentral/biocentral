import 'dart:typed_data';

import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class PredictionModelRepository {
  final List<PredictionModel> _predictionModels = [];

  List<PredictionModel> addModel(PredictionModel predictionModel) {
    _predictionModels.add(predictionModel);
    return predictionModelsToList();
  }

  Future<List<PredictionModel>> addModelFromDirectoryFiles() async {
    return []; // TODO FIX AUTOSAVE
  }

  Future<List<PredictionModel>> addModelFromBiotrainerFiles({
    String? configFile,
    String? outputFile,
    String? loggingFile,
    Map<String, Uint8List>? checkpointFiles,
    DatabaseImportMode databaseImportMode = DatabaseImportMode.overwrite,
  }) async {
    final PredictionModel predictionModel = BiotrainerFileHandler.parsePredictionModelFromRawFiles(
      biotrainerConfig: configFile,
      biotrainerOutput: outputFile,
      biotrainerTrainingLog: loggingFile,
      biotrainerCheckpoints: checkpointFiles,
      //TODO Manual setting of failOnConflict?
      failOnConflict: true,
    );

    if (predictionModel.isNotEmpty()) {
      return addModel(predictionModel);
    }
    return predictionModelsToList();
  }

  List<PredictionModel> predictionModelsToList() {
    return List.from(_predictionModels);
  }
}
