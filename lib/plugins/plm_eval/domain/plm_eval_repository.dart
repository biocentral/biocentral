import 'dart:convert';

import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';

class PLMEvalRepository {
  final BiocentralProjectRepository _projectRepository;

  final List<AutoEvalProgressWrapper> _sessionResults = [];
  final List<PLMEvalPersistentResult> _persistentResults = [];

  PLMEvalRepository(this._projectRepository);

  Future<List<AutoEvalProgressWrapper>> addSessionResult(AutoEvalProgressWrapper progress) async {
    // TODO [Refactoring] Use autoSaving mixin
    _sessionResults.add(progress);

    // TODO [Refactoring] Create file type class
    // TODO [Error handling] Handle save error
    await _projectRepository.handleProjectInternalSave(
      fileName: 'plm_eval_results.json',
      type: PLMEvalPersistentResult,
      contentFunction: saveResults,
    );
    return getSessionResults();
  }

  Future<List<PLMEvalPersistentResult>> addPersistentResultsFromFile(String plmEvalResultsFile) async {
    final decodedFile = jsonDecode(plmEvalResultsFile);

    bool newResultAdded = false;
    if (decodedFile is List) {
      for (final value in decodedFile) {
        final PLMEvalPersistentResult? parsedResult = PLMEvalPersistentResult.fromMap(value);
        if (parsedResult != null) {
          _persistentResults.add(parsedResult);
          newResultAdded = true;
        }
      }
    } else if (decodedFile is Map) {
      final PLMEvalPersistentResult? parsedResult =
          PLMEvalPersistentResult.fromMap(decodedFile as Map<String, dynamic>);
      if (parsedResult != null) {
        _persistentResults.add(parsedResult);
        newResultAdded = true;
      }
    } else {
      // TODO Error handling
      return getPersistentResults();
    }
    if (newResultAdded) {
      await _projectRepository.handleProjectInternalSave(
        fileName: 'plm_eval_results.json',
        type: PLMEvalPersistentResult,
        contentFunction: saveResults,
      );
    }
    return getPersistentResults();
  }

  Future<String> saveResults() async {
    final List<Map<String, dynamic>> persistentResults = [
      ..._persistentResults.map((persistentResult) => persistentResult.toMap()),
      ..._sessionResults
          .map((autoEvalProgress) => PLMEvalPersistentResult.fromAutoEvalProgressWrapper(autoEvalProgress).toMap()),
    ];
    return jsonEncode(persistentResults);
  }

  List<AutoEvalProgressWrapper> getSessionResults() {
    return List.from(_sessionResults);
  }

  List<PLMEvalPersistentResult> getPersistentResults() {
    return List.from(_persistentResults);
  }

  List<PLMEvalPersistentResult> getAllResultsAsPersistent() {
    return getPersistentResults()
      ..addAll(getSessionResults().map((sessionResult) => PLMEvalPersistentResult.fromAutoEvalProgressWrapper(sessionResult)));
  }
}
