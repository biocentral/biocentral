import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:universal_io/io.dart';
import 'package:archive/archive_io.dart';
import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/bloc/biocentral_command.dart';
import 'package:biocentral/sdk/bloc/biocentral_state.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:biocentral/sdk/util/biocentral_exception.dart';
import 'package:biocentral/sdk/util/constants.dart';
import 'package:biocentral/sdk/util/logging.dart';
import 'package:biocentral/sdk/util/path_util.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';

/// Stores data related to the project, like directory path
class BiocentralProjectRepository {
  static const String _webDownloadDirectoryPath = '#flutter_web_downloads';

  final Map<Type, BiocentralPluginDirectory> _registeredPluginDirectories = {};
  final List<BiocentralCommandLog> _commandLog = [];

  /// Map to store paths of downloaded files to clean them up if the download fails
  final Map<String, String> _temporaryPartialFilePaths = {};

  String _projectDir;
  bool _isLoadingProject = false; // If project is loading, no saves should be done

  BiocentralProjectRepository(this._projectDir);

  static Future<BiocentralProjectRepository> fromLastProjectDirectory() async {
    if (kIsWeb) {
      return BiocentralProjectRepository(_webDownloadDirectoryPath);
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastProjectDirectory = PathResolver.sanitize(prefs.getString('lastProjectDirectory'));
    final bool exists = lastProjectDirectory != null && await Directory(lastProjectDirectory).exists();
    return BiocentralProjectRepository(exists ? lastProjectDirectory : '');
  }

  void registerPluginDirectory(Type fileType, BiocentralPluginDirectory directory) {
    if (_registeredPluginDirectories.containsKey(fileType)) {
      throw Exception('Plugin type $fileType already registered for biocentral project repository directories!');
    }
    _registeredPluginDirectories[fileType] = directory;
  }

  List<BiocentralPluginDirectory> getAllPluginDirectories() {
    return _registeredPluginDirectories.values.toList();
  }

  bool isProjectDirectoryPathSet() {
    return _projectDir.isNotEmpty;
  }

  Future<void> setProjectDirectoryPath(String value) async {
    _projectDir = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastProjectDirectory', _projectDir);
  }

  String getProjectDirectoryPath() => _projectDir;

  void enterProjectLoadingContext() {
    _isLoadingProject = true;
  }

  void exitProjectLoadingContext() {
    // TODO [Refactoring] A bit of a hacky solution here to decouple auto-saving from the project repository
    final Timer autoSaveDebounce =
        Timer(Duration(seconds: Constants.autoSaveDebounceTime.inSeconds + 2), () => _isLoadingProject = false);
  }

  Future<Either<BiocentralException, Uint8List?>> handleBytesLoad({
    required XFile? xFile,
    bool ignoreIfNoFile = false,
  }) async {
    if (ignoreIfNoFile && xFile == null) {
      return right(null);
    }
    if (xFile == null) {
      return left(BiocentralIOException(message: 'No file given to load!'));
    }

    Uint8List? fileBytes;
    try {
      fileBytes = await xFile.readAsBytes();
    } catch (e, stackTrace) {
      return left(
        BiocentralIOException(
          message: 'File ${xFile.name} could not be read!',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
    return right(fileBytes);
  }

  Future<Either<BiocentralException, LoadedFileData?>> handleLoad({
    required XFile? xFile,
    bool ignoreIfNoFile = false,
  }) async {
    if (ignoreIfNoFile && xFile == null) {
      return right(null);
    }
    final fileBytesEither = await handleBytesLoad(xFile: xFile, ignoreIfNoFile: ignoreIfNoFile);
    return fileBytesEither.flatMap(
      (unit8List) => right(
        LoadedFileData(
          content: String.fromCharCodes(unit8List ?? []),
          name: xFile?.name ?? '',
          extension: xFile?.extension ?? '', // TODO Check if this is correct
        ),
      ),
    );
  }

  /// TODO Improve error handling
  Future<Either<BiocentralException, String?>> _handleSave({
    required String fileName,
    Future<String?> Function()? contentFunction,
    Future<Uint8List?> Function()? bytesFunction,
    String? dirPath,
  }) async {
    if (_isLoadingProject) {
      return right(null);
    }
    final content = contentFunction != null ? await contentFunction() : null;
    final bytes = bytesFunction != null ? await bytesFunction() : null;

    if (content == null && bytes == null) {
      return left(
        BiocentralIOException(
          message: 'Cannot save file $fileName, because both string content and bytes are null!',
        ),
      );
    }
    if (content != null && bytes != null) {
      return left(
        BiocentralIOException(
          message: 'Cannot save file $fileName, because both string content and bytes are provided!',
        ),
      );
    }
    String fullPath = '';
    if (kIsWeb) {
      await triggerFileDownload(bytes ?? utf8.encode(content ?? ''), fileName);
    } else {
      final String directoryPathToSave = PathResolver.sanitize(dirPath) ?? _projectDir;

      final Directory dir = Directory(directoryPathToSave);
      await dir.create(recursive: true);

      fullPath = directoryPathToSave + fileName;
      final File fileToSave = File(fullPath);

      if (content != null) {
        await fileToSave.writeAsString(content);
      } else if (bytes != null) {
        await fileToSave.writeAsBytes(bytes);
      }
    }
    return right(fullPath);
  }

  Future<Either<BiocentralException, String?>> handleExternalSave({
    required String fileName,
    Future<String?> Function()? contentFunction,
    Future<Uint8List?> Function()? bytesFunction,
    String? dirPath,
  }) async {
    return _handleSave(
      fileName: fileName,
      contentFunction: contentFunction,
      bytesFunction: bytesFunction,
      dirPath: dirPath,
    );
  }

  Future<Either<BiocentralException, String?>> handleProjectInternalSave({
    required String fileName,
    required Type type,
    String? subDir,
    Future<String?> Function()? contentFunction,
    Future<Uint8List?> Function()? bytesFunction,
  }) async {
    if (!isProjectDirectoryPathSet()) {
      return right('');
    }

    final String? pluginDir = _registeredPluginDirectories[type]?.path;
    if (pluginDir == null) {
      return left(BiocentralIOException(message: 'Cannot find registered plugin for type $type in autoSave!'));
    }
    final String path = PathResolver.resolve(_projectDir, pluginDir, subDir, null);
    return _handleSave(
      fileName: fileName,
      contentFunction: contentFunction,
      bytesFunction: bytesFunction,
      dirPath: path,
    );
  }

  Future<Either<BiocentralException, String>> handleStreamSave({
    required String fileName,
    required Stream<List<int>> byteStream,
    String? dirPath,
  }) async {
    try {
      final directoryPathToSave = PathResolver.sanitize(dirPath) ?? _projectDir;
      final fullPath = directoryPathToSave + fileName;
      _temporaryPartialFilePaths[fileName] = fullPath;
      final fileToSave = File(fullPath);
      final sink = fileToSave.openWrite();
      await byteStream.forEach(sink.add);
      await sink.close();
      return right(fullPath);
    } catch (e) {
      return left(BiocentralIOException(message: 'Error saving file: $e'));
    }
  }

  Future<Either<BiocentralException, Unit>> cleanUpFailedDownload({required String fileName}) async {
    try {
      final fullPath = _temporaryPartialFilePaths[fileName];
      if (fullPath != null) {
        final fileToDelete = File(fullPath);

        _temporaryPartialFilePaths.remove(fileName);
        if (fileToDelete.existsSync()) {
          await fileToDelete.delete();
        }
      }
      return right(unit);
    } catch (e) {
      return left(BiocentralIOException(message: 'Error cleaning up file: $e'));
    }
  }

  Future<Either<BiocentralException, String>> handleArchiveExtraction({
    required String archiveFilePath,
    String? outDirectoryName,
  }) async {
    // TODO Handle web and errors
    outDirectoryName ??= 'extracted';

    final outFile = "$_projectDir$outDirectoryName";
    Future<void> extractionFunction(_) => extractFileToDisk(archiveFilePath, outFile);
    await compute(extractionFunction, []);

    return right(outFile);
  }

  Future<void> loadCommandLog(XFile? commandLogFile) async {
    //TODO [Refactoring] Move command log handling to separate repository
    final loadedEither = await handleLoad(xFile: commandLogFile);
    final commandLogLoadedEither = loadedEither.flatMap((loadedFile) {
      final List decodedContent = jsonDecode(loadedFile?.content ?? '[]');

      final List<BiocentralCommandLog> reconstructedCommandLog = [];
      for (final commandMap in decodedContent) {
        final reconstructedLog = BiocentralCommandLog.fromJsonMap(commandMap);
        reconstructedCommandLog.add(reconstructedLog);
      }
      return right(reconstructedCommandLog);
    });
    _commandLog.clear();
    _commandLog.addAll(commandLogLoadedEither.getOrElse((_) => []));
  }

  void logCommand(BiocentralCommandLog newCommand) {
    if (_isLoadingProject) {
      return;
    }

    final indexExisting = _commandLog.indexWhere(
      (log) =>
          log.commandStatus == BiocentralCommandStatus.operating &&
          log.metaData.startTime == newCommand.metaData.startTime,
    );

    switch (newCommand.commandStatus) {
      case BiocentralCommandStatus.operating:
        if (indexExisting != -1) {
          final existingCommand = _commandLog[indexExisting];
          if (existingCommand.metaData.serverTaskID == null && newCommand.metaData.serverTaskID != null) {
            // Replace after retrieving serverTaskID
            _commandLog[indexExisting] = newCommand;
          }
        } else {
          _commandLog.add(newCommand);
        }
        break;

      case BiocentralCommandStatus.finished:
      case BiocentralCommandStatus.errored:
        // Try to find and replace existing operating command with result command

        if (indexExisting != -1) {
          _commandLog[indexExisting] = newCommand;
        } else {
          logger.e('Did not find an operating command for finished command: $newCommand!');
          _commandLog.add(newCommand);
        }
        break;
      default:
        _commandLog.add(newCommand);
        break;
    }

    _handleSave(fileName: 'command_log.json', dirPath: _projectDir, contentFunction: _saveCommandLog);
  }

  Future<String> _saveCommandLog() async {
    final commandLogMapped = _commandLog.map((loggedCommand) => loggedCommand.toMap()).toList();
    final result = jsonEncode(commandLogMapped);
    return result;
  }

  Future<Map<String, String>> getMatchingFilesInProjectDirectory(String? Function(String) matchingFunction) async {
    if (kIsWeb) {
      return {};
    }

    final dir = Directory(_projectDir);
    final Iterable<File> files = (await dir.list().toList()).whereType<File>();
    final Map<String, String> result = {};
    for (File file in files) {
      final match = matchingFunction(file.path);
      if (match != null) {
        result[match] = file.absolute.path;
      }
    }
    return result;
  }

  List<BiocentralCommandLog> getCommandLog() {
    return List.of(_commandLog);
  }
}

final class LoadedFileData {
  final String content;
  final String name;
  final String extension;

  const LoadedFileData({required this.content, required this.name, required this.extension});
}

extension GetFileExtension on XFile {
  String get extension => name.split(Platform.pathSeparator).last.split('.').last;
}
