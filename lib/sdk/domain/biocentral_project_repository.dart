import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/util/biocentral_exception.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:biocentral/sdk/bloc/biocentral_command.dart';

/// Stores data related to the project, like directory path
class BiocentralProjectRepository {
  static const String _webDownloadDirectoryPath = '#flutter_web_downloads';

  String _directoryPath;

  final List<BiocentralCommandLog> _commandLog = [];

  /// Map to store paths of downloaded files to clean them up if the download fails
  final Map<String, String> _temporaryPartialFilePaths = {};

  BiocentralProjectRepository(this._directoryPath);

  static Future<BiocentralProjectRepository> fromLastProjectDirectory() async {
    if (kIsWeb) {
      return BiocentralProjectRepository(_webDownloadDirectoryPath);
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastProjectDirectory = _sanitizePath(prefs.getString('lastProjectDirectory'));
    final bool exists = lastProjectDirectory != null && await Directory(lastProjectDirectory).exists();
    return BiocentralProjectRepository(exists ? lastProjectDirectory : '');
  }

  static String? _sanitizePath(String? path) {
    if (path == null) {
      return null;
    } else {
      return path.endsWith('/') ? path : '$path/';
    }
  }

  bool isDirectoryPathSet() {
    return _directoryPath.isNotEmpty;
  }

  Future<void> setDirectoryPath(String value) async {
    _directoryPath = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastProjectDirectory', _directoryPath);
  }

  Future<Either<BiocentralException, Uint8List?>> handleBytesLoad(
      {required PlatformFile? platformFile, bool ignoreIfNoFile = false,}) async {
    if (ignoreIfNoFile && platformFile == null) {
      return right(null);
    }
    if (platformFile == null) {
      return left(BiocentralIOException(message: 'No file given to load!'));
    }
    Uint8List? fileBytes = platformFile.bytes;

    if (fileBytes == null && !kIsWeb && platformFile.path != null) {
      final String filePath = platformFile.path!;
      final XFile xFile = XFile(filePath);
      try {
        fileBytes = await xFile.readAsBytes();
      } catch (e, stackTrace) {
        return left(BiocentralIOException(
            message: 'File ${platformFile.name} could not be read!', error: e, stackTrace: stackTrace,),);
      }
    }
    if (fileBytes == null) {
      return left(BiocentralIOException(message: 'File ${platformFile.name} could not be read!'));
    }
    return right(fileBytes);
  }

  Future<Either<BiocentralException, FileData?>> handleLoad(
      {required PlatformFile? platformFile, bool ignoreIfNoFile = false,}) async {
    if (ignoreIfNoFile && platformFile == null) {
      return right(null);
    }
    final fileBytesEither = await handleBytesLoad(platformFile: platformFile, ignoreIfNoFile: ignoreIfNoFile);
    return fileBytesEither.flatMap((unit8List) => right(FileData(
        content: String.fromCharCodes(unit8List ?? []),
        name: platformFile?.name ?? '',
        extension: platformFile?.extension ?? '',),),);
  }

  /// TODO Improve error handling
  Future<Either<BiocentralException, String>> handleSave(
      {required String fileName, String? content, Uint8List? bytes, String? dirPath,}) async {
    if (content == null && bytes == null) {
      return left(BiocentralIOException(
          message: 'Cannot save file $fileName, because both string content and bytes are null!',),);
    }
    if (content != null && bytes != null) {
      return left(BiocentralIOException(
          message: 'Cannot save file $fileName, because both string content and bytes are provided!',),);
    }
    String fullPath = '';
    if (kIsWeb) {
      await triggerFileDownload(bytes ?? utf8.encode(content ?? ''), fileName);
    } else {
      final String directoryPathToSave = _sanitizePath(dirPath) ?? _directoryPath;
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

  Future<Either<BiocentralException, String>> handleStreamSave(
      {required String fileName, required Stream<List<int>> byteStream, String? dirPath,}) async {
    try {
      final directoryPathToSave = _sanitizePath(dirPath) ?? _directoryPath;
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

  Future<Either<BiocentralException, String>> handleArchiveExtraction(
      {required String archiveFilePath, String? outDirectoryName,}) async {
    // TODO Handle web and errors
    outDirectoryName ??= 'extracted';

    final outFile = "$_directoryPath$outDirectoryName";
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

    final dir = Directory(_directoryPath);
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

  bool doesPathExistInProjectDirectory(String path) {
    if (kIsWeb) {
      return false;
    }
    return File("$_directoryPath$path").existsSync();
  }

  String getPathWithProjectDirectory(String path) {
    return "$_directoryPath$path";
  }

  List<BiocentralCommandLog> getCommandLog() {
    return List.of(_commandLog);
  }
}

final class FileData {
  final String content;
  final String name;
  final String extension;

  const FileData({required this.content, required this.name, required this.extension});
}
