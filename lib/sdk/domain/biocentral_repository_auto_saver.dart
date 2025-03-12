import 'dart:async';
import 'dart:typed_data';

import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/util/constants.dart';
import 'package:biocentral/sdk/util/logging.dart';

class BiocentralRepositoryAutoSaver {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final String _fileName;
  final Type _fileType;
  final Future<String?> Function()? _saveFunctionString;
  final Future<Uint8List?> Function()? _saveFunctionBytes;

  Timer? _debounceTimer;

  bool _saveScheduled = false;

  BiocentralRepositoryAutoSaver({
    required BiocentralProjectRepository biocentralProjectRepository,
    required String fileName,
    required Type fileType,
    Future<String?> Function()? saveFunctionString,
    Future<Uint8List?> Function()? saveFunctionBytes,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _fileName = fileName,
        _fileType = fileType,
        _saveFunctionString = saveFunctionString,
        _saveFunctionBytes = saveFunctionBytes;

  void scheduleSave() {
    _saveScheduled = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Constants.autoSaveDebounceTime, _executeSave);
  }

  Future<void> _executeSave() async {
    if (!_saveScheduled) return;

    try {
      await _biocentralProjectRepository.handleProjectInternalSave(
        fileName: _fileName,
        type: _fileType,
        contentFunction: _saveFunctionString,
        bytesFunction: _saveFunctionBytes,
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
