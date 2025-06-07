import 'dart:convert';
import 'dart:typed_data';

import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_training_result.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';

/// Repository for managing Bayesian Optimization training results.
///
/// This repository handles the following:
/// - Storing and retrieving current and previous training results.
/// - Saving training results to JSON files.
/// - Loading training results from JSON files.
class BayesianOptimizationRepository {
  final BiocentralProjectRepository _projectRepository;

  /// Constructor for [BayesianOptimizationRepository].
  ///
  /// - [_projectRepository]: The project repository for handling external file operations.
  BayesianOptimizationRepository(this._projectRepository);

  BayesianOptimizationTrainingResult? currentResult;

  void setCurrentResult(BayesianOptimizationTrainingResult? r) {
    currentResult = r;
    saveCurrentResultIntoJson(currentResult);
  }

  void addPickedPreviousTrainingResults(String fileContent) {
    final BayesianOptimizationTrainingResult result = convertJsonToTrainingResult(fileContent);
    setCurrentResult(result);
  }

  /// Saves the current training result to a JSON file.
  ///
  /// - [currentResult]: The training result to save.
  ///
  /// This method uses the project repository to handle the external save operation.
  Future<void> saveCurrentResultIntoJson(BayesianOptimizationTrainingResult? currentResult) async {
    if (currentResult == null) return;

    final String jsonString = convertTrainingResultToJson(currentResult);
    await _projectRepository.handleExternalSave(
      fileName: 'bo_result_${currentResult.taskID!}.json',
      contentFunction: () async => jsonString,
    );
  }

  /// Converts a JSON file content to a [BayesianOptimizationTrainingResult].
  ///
  /// - [bytes]: The JSON file content as a byte array.
  ///
  /// Returns a [BayesianOptimizationTrainingResult] object. If the conversion fails, an empty result is returned.
  BayesianOptimizationTrainingResult convertJsonToTrainingResult(String fileContent) {
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(fileContent);
      return BayesianOptimizationTrainingResult.fromMap(jsonMap);
    } catch (e) {
      return const BayesianOptimizationTrainingResult(results: []);
    }
  }

  String convertTrainingResultToJson(BayesianOptimizationTrainingResult result) {
    return jsonEncode(result.toJson());
  }

  // Clear the current training result from the repository to start a new training.
  void clearCurrentResult() {
    currentResult = null;
  }
}
