import 'dart:convert';

import 'package:biocentral/plugins/active_learning/model/al_training_result.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_repository_auto_saver.dart';

/// Repository for managing Active Learning training results.
///
/// This repository handles the following:
/// - Storing and retrieving current and previous training results.
/// - Saving training results to JSON files.
/// - Loading training results from JSON files.
class ALRepository with AutoSaving {
  final BiocentralProjectRepository _projectRepository;

  @override
  late final BiocentralRepositoryAutoSaver autoSaver;

  final List<ALTrainingResult> _trainingResults = [];

  /// Constructor for [ALRepository].
  ///
  /// - [_projectRepository]: The project repository for handling external file operations.
  ALRepository(this._projectRepository) {
    autoSaver = BiocentralRepositoryAutoSaver(
      biocentralProjectRepository: _projectRepository,
      fileName: 'al_results.json',
      fileType: ALTrainingResult,
      saveFunctionString: saveTrainingResults,
    );
  }

  List<ALTrainingResult> addTrainingResult(ALTrainingResult? result) =>
      withAutoSave(() {
        if (result != null) {
          _trainingResults.add(result);
        }
        return trainingResultsToList();
      });

  List<ALTrainingResult> updateLatestResult(ALTrainingResult updatedResult) =>
      withAutoSave(() {
        final updatedResults = [updatedResult, ..._trainingResults.sublist(1)];
        _trainingResults.clear();
        _trainingResults.addAll(updatedResults);
        return trainingResultsToList();
      });

  List<ALTrainingResult> loadTrainingResults(String fileContent) {
    // TODO CHECK THIS FUNCTION
    final resultMaps = jsonDecode(fileContent);

    _trainingResults.clear();

    for (final map in resultMaps) {
      final ALTrainingResult result = ALTrainingResult.fromMap(map);
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

  List<ALTrainingResult> trainingResultsToList() => List.from(_trainingResults);
}
