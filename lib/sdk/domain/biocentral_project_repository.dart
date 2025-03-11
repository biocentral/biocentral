import 'dart:io';
import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/bloc/biocentral_command.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:biocentral/sdk/util/biocentral_exception.dart';
import 'package:biocentral/sdk/util/path_util.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores data related to the project, like directory path
class BiocentralProjectRepository {
  static const String _webDownloadDirectoryPath = '#flutter_web_downloads';

  String _projectDir;
  final Map<Type, BiocentralPluginDirectory> _registeredPluginDirectories = {};

  final List<BiocentralCommandLog> _commandLog = [];

  /// Map to store paths of downloaded files to clean them up if the download fails
  final Map<String, String> _temporaryPartialFilePaths = {};

  BiocentralProjectRepository(this._projectDir);

  static Future<BiocentralProjectRepository> fromLastProjectDirectory() async {
    if (kIsWeb) {
      return BiocentralProjectRepository(_webDownloadDirectoryPath);
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastProjectDirectory = _sanitizePath(prefs.getString('lastProjectDirectory'));
    final bool exists = lastProjectDirectory != null && await Directory(lastProjectDirectory).exists();
    return BiocentralProjectRepository(exists ? lastProjectDirectory : '');
  }

  void registerPluginDirectory(Type pluginType, BiocentralPluginDirectory directory) {
    if (_registeredPluginDirectories.containsKey(pluginType)) {
      throw Exception('Plugin type $pluginType already registered for biocentral project repository directories!');
    }
    _registeredPluginDirectories[pluginType] = directory;
  }
  
  List<BiocentralPluginDirectory> getAllPluginDirectories() {
    return _registeredPluginDirectories.values.toList();
  }
  
  static String? _sanitizePath(String? path) {
    if (path == null) {
      return null;
    } else {
      return path.endsWith('/') ? path : '$path/';
    }
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
    if (!kIsWeb) {
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
    }
    if (fileBytes == null) {
      return left(BiocentralIOException(message: 'File ${xFile.name} could not be read!'));
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
          extension: xFile?.extension ?? '',  // TODO Check if this is correct
        ),
      ),
    );
  }

  /// TODO Improve error handling
  Future<Either<BiocentralException, String>> _handleSave({
    required String fileName,
    String? content,
    Uint8List? bytes,
    String? dirPath,
  }) async {
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
      final String directoryPathToSave = _sanitizePath(dirPath) ?? _projectDir;

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

  Future<Either<BiocentralException, String>> handleExternalSave({
    required String fileName,
    String? content,
    Uint8List? bytes,
    String? dirPath,
  }) async {
    return _handleSave(fileName: fileName, content: content, bytes: bytes, dirPath: dirPath);
  }

  Future<Either<BiocentralException, String?>> handleProjectInternalSave({
    required String fileName,
    required Type type,
    String? subDir,
    String? content,
    Uint8List? bytes,
  }) async {
    if (!isProjectDirectoryPathSet()) {
      return right('');
    }

    final String? pluginDir = _registeredPluginDirectories[type]?.path;
    if (pluginDir == null) {
      return left(BiocentralIOException(message: 'Cannot find registered plugin for type $type in autoSave!'));
    }
    final String path = PathResolver.resolve(_projectDir, pluginDir, subDir, null);
    return _handleSave(fileName: fileName, content: content, bytes: bytes, dirPath: path);
  }

  Future<Either<BiocentralException, String>> handleStreamSave({
    required String fileName,
    required Stream<List<int>> byteStream,
    String? dirPath,
  }) async {
    try {
      final directoryPathToSave = _sanitizePath(dirPath) ?? _projectDir;
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

  void logCommand(BiocentralCommandLog commandLog) {
    _commandLog.add(commandLog);
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