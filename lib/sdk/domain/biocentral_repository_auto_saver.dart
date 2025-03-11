import 'dart:async';
import 'dart:typed_data';

import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/util/logging.dart';

class BiocentralRepositoryAutoSaver {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final Future<(String, Type, String?, Uint8List?)> Function() _saveFunction; // TODO Bundle in file data

  Timer? _debounceTimer;
  static const Duration _defaultDebounceTime = Duration(seconds: 2);

  bool _saveScheduled = false;

  BiocentralRepositoryAutoSaver(this._biocentralProjectRepository, this._saveFunction);

  void scheduleSave() {
    _saveScheduled = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_defaultDebounceTime, _executeSave);
  }

  Future<void> _executeSave() async {
    if (!_saveScheduled) return;

    try {
      final (fileName, type, content, bytes) = await _saveFunction();
      await _biocentralProjectRepository.handleProjectInternalSave(
        fileName: fileName,
        type: type,
        content: content,
        bytes: bytes,
      );
    } catch (e) {
      logger.e('Error during auto-save: $e');
    } finally {
      _saveScheduled = false;
    }
  }
}

mixin AutoSaving {
  BiocentralRepositoryAutoSaver get autoSaver;

  T withAutoSave<T>(T Function() operation) {
    try {
      return operation();
    } finally {
      autoSaver.scheduleSave();
    }
  }
}
