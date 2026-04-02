import 'dart:async';
import 'dart:convert';

import 'package:biocentral/sdk/bloc/biocentral_command.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_repository_auto_saver.dart';
import 'package:biocentral/sdk/domain/project_loading_context.dart';
import 'package:biocentral/sdk/util/biocentral_exception.dart';
import 'package:fpdart/fpdart.dart';

class BiocentralCommandLogRepository with AutoSaving, ProjectLoadingContext {
  final List<BiocentralCommandLog> _commandLog = [];

  final _databaseController = StreamController<List<BiocentralCommandLog>>.broadcast();

  Stream<List<BiocentralCommandLog>> get databaseStream => _databaseController.stream;

  @override
  late final BiocentralRepositoryAutoSaver autoSaver;

  BiocentralCommandLogRepository(BiocentralProjectRepository biocentralProjectRepository) {
    autoSaver = BiocentralRepositoryAutoSaver(
      projectRepository: biocentralProjectRepository,
      fileName: 'command_log.json',
      fileType: BiocentralCommandLog,
      saveFunctionString: _saveCommandLog,
    );
  }

  void _updateStream() {
    _databaseController.add(getCommandLog());
  }

  Future<void> loadCommandLog(Either<BiocentralException, LoadedFileData?> loadedEither) async {
    //TODO [Refactoring] Move command log handling to separate repository
    final commandLogLoadedEither = loadedEither.flatMap((loadedFile) {
      final List decodedContent = jsonDecode(loadedFile?.content ?? '[]');

      final List<BiocentralCommandLog> reconstructedCommandLog = [];
      for (final commandMap in decodedContent) {
        final reconstructedLog = BiocentralCommandLog.deserialize(commandMap);
        reconstructedCommandLog.add(reconstructedLog);
      }
      return right(reconstructedCommandLog);
    });
    _commandLog.clear();
    _commandLog.addAll(commandLogLoadedEither.getOrElse((_) => []));
    _updateStream();
  }

  void logCommand(BiocentralCommandLog? newCommand) {
    if (newCommand == null) {
      return;
    }

    if (isLoading) {
      return;
    }

    _commandLog.add(newCommand);

    _updateStream();
    autosave();
  }

  Future<String> _saveCommandLog() async {
    final commandLogMapped = _commandLog.map((loggedCommand) => loggedCommand.serialize()).toList();
    final result = jsonEncode(commandLogMapped);
    return result;
  }

  List<BiocentralCommandLog> getCommandLog() {
    return List.of(_commandLog);
  }
}
