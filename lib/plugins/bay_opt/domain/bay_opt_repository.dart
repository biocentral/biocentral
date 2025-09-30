import 'dart:convert';

import 'package:biocentral/plugins/bay_opt/model/bay_opt_training_result.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_repository_auto_saver.dart';

/// Repository for managing Bayesian Optimization training results.
///
/// This repository handles the following:
/// - Storing and retrieving current and previous training results.
/// - Saving training results to JSON files.
/// - Loading training results from JSON files.
class BayOptRepository with AutoSaving {
  final BiocentralProjectRepository _projectRepository;

  @override
  late final BiocentralRepositoryAutoSaver autoSaver;

  final List<BayOptTrainingResult> _trainingResults = [];

  /// Constructor for [BayOptRepository].
  ///
  /// - [_projectRepository]: The project repository for handling external file operations.
  BayOptRepository(this._projectRepository) {
    autoSaver = BiocentralRepositoryAutoSaver(
      biocentralProjectRepository: _projectRepository,
      fileName: 'bo_results.json',
      fileType: BayOptTrainingResult,
      saveFunctionString: saveTrainingResults,
    );
  }

  List<BayOptTrainingResult> addTrainingResult(BayOptTrainingResult? result) =>
      withAutoSave(() {
        if (result != null) {
          _trainingResults.add(result);
        }
        return trainingResultsToList();
      });

  List<BayOptTrainingResult> updateLatestResult(BayOptTrainingResult updatedResult) =>
      withAutoSave(() {
        final updatedResults = [updatedResult, ..._trainingResults.sublist(1)];
        _trainingResults.clear();
        _trainingResults.addAll(updatedResults);
        return trainingResultsToList();
      });

  List<BayOptTrainingResult> loadTrainingResults(String fileContent) {
    // TODO CHECK THIS FUNCTION
    final resultMaps = jsonDecode(fileContent);

    _trainingResults.clear();

    for (final map in resultMaps) {
      final BayOptTrainingResult result = BayOptTrainingResult.fromMap(map);
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

  List<BayOptTrainingResult> trainingResultsToList() => List.from(_trainingResults);
}
