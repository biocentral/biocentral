import 'dart:convert';

import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_training_result.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_repository_auto_saver.dart';

/// Repository for managing Bayesian Optimization training results.
///
/// This repository handles the following:
/// - Storing and retrieving current and previous training results.
/// - Saving training results to JSON files.
/// - Loading training results from JSON files.
class BayesianOptimizationRepository with AutoSaving {
  final BiocentralProjectRepository _projectRepository;

  @override
  late final BiocentralRepositoryAutoSaver autoSaver;

  final List<BayesianOptimizationTrainingResult> _trainingResults = [];

  /// Constructor for [BayesianOptimizationRepository].
  ///
  /// - [_projectRepository]: The project repository for handling external file operations.
  BayesianOptimizationRepository(this._projectRepository) {
    autoSaver = BiocentralRepositoryAutoSaver(
      biocentralProjectRepository: _projectRepository,
      fileName: 'bo_results.json',
      fileType: BayesianOptimizationTrainingResult,
      saveFunctionString: saveTrainingResults,
    );
  }

  void addTrainingResult(BayesianOptimizationTrainingResult? result) => withAutoSave(() {
        if (result != null) {
          _trainingResults.add(result);
        }
      });

  List<BayesianOptimizationTrainingResult> loadTrainingResults(String fileContent) {
    // TODO CHECK THIS FUNCTION
    final resultMaps = jsonDecode(fileContent);

    _trainingResults.clear();

    for (final map in resultMaps) {
      final BayesianOptimizationTrainingResult result = BayesianOptimizationTrainingResult.fromMap(map);
      _trainingResults.add(result);
    }

    return trainingResultsToList();
  }

  /// Converts the current training results as json
  Future<String> saveTrainingResults() async {
    if (_trainingResults.isEmpty) {
      return '';
    }

    final trainingResultMaps = _trainingResults.map((result) => result.toMap()).toList();
    return jsonEncode(trainingResultMaps);
  }

  List<BayesianOptimizationTrainingResult> trainingResultsToList() => List.from(_trainingResults);
}
