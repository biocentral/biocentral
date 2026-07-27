import 'dart:convert';

import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_repository_auto_saver.dart';
import 'package:biocentral/sdk/domain/streamable_database.dart';

class CustomModelRepository with AutoSaving, StreamableDatabase<List<PredictionModel>> {
  @override
  late final BiocentralRepositoryAutoSaver autoSaver;

  final List<PredictionModel> _predictionModels = [];

  CustomModelRepository(BiocentralProjectRepository projectRepository) {
    autoSaver = BiocentralRepositoryAutoSaver(
      projectRepository: projectRepository,
      fileName: 'model_db.json',
      fileType: PredictionModel,
      saveFunctionString: saveDBInfo,
    );
  }

  void addModel(PredictionModel predictionModel) {
    // TODO Autosaving without files
    _predictionModels.add(predictionModel);
    updateStream();
    autosave();
  }

  void addModels(List<PredictionModel> models) {
    _predictionModels.addAll(models);
    updateStream();
    autosave();
  }

  Map<String, dynamic> serialize() => {'models': _predictionModels.map((model) => model.serialize()).toList()};

  Future<String> saveDBInfo() async {
    final jsonMap = serialize();
    return jsonEncode(jsonMap);
  }

  List<PredictionModel> databaseToList() {
    return List.from(_predictionModels);
  }

  @override
  List<PredictionModel> toStreamable() {
    return databaseToList();
  }
}
