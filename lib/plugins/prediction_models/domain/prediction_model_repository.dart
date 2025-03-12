import 'dart:typed_data';

import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class PredictionModelRepository {
  final BiocentralProjectRepository _projectRepository;

  final List<PredictionModel> _predictionModels = [];

  PredictionModelRepository(this._projectRepository);

  void _addModel(PredictionModel predictionModel) {
    _predictionModels.add(predictionModel);
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
    // TODO Get model id from prediction model directly
    final String modelID = predictionModel.hashCode.toString().substring(0, 8);

    if (predictionModel.isNotEmpty()) {
      _addModel(predictionModel);
    }

    await save(
        modelID,
        {
          StorageFileType.biotrainer_config: configFile,
          StorageFileType.biotrainer_result: outputFile,
          StorageFileType.biotrainer_logging: loggingFile
        },
        checkpointFiles);
    return predictionModelsToList();
  }

  Future<void> save(
    String modelID,
    Map<StorageFileType, String?> stringFiles,
    Map<String, Uint8List>? checkpoints,
  ) async {
    // Save files
    for (MapEntry<StorageFileType, String?> fileEntry in stringFiles.entries) {
      if (fileEntry.value != null) {
        await _projectRepository.handleProjectInternalSave(
          fileName: fileEntry.key.getDefaultFileName(),
          type: PredictionModel,
          subDir: modelID,
          content: fileEntry.value.toString(),
        );
      }
    }
    if (checkpoints != null) {
      for (MapEntry<String, Uint8List> checkpoint in checkpoints.entries) {
        await _projectRepository.handleProjectInternalSave(
            fileName: checkpoint.key, type: PredictionModel, subDir: modelID, bytes: checkpoint.value);
      }
    }
  }

  List<PredictionModel> predictionModelsToList() {
    return List.from(_predictionModels);
  }
}
