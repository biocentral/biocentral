import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PathResolver {
  static String resolve(String projectDir, String? pluginDir, String? subDir, String? fileName) {
    String result = projectDir;
    if(result.characters.last != '/') {
      result += '/';
    }
    result += pluginDir ?? '';
    result += '/${subDir ?? ""}';
    result += fileName ?? '';
    return result;
  }


  static String? sanitize(String? path) {
    if (path == null) {
      return null;
    } else {
      return path.endsWith('/') ? path : '$path/';
    }
  }
}
class PathScanner {
  /// Scans the provided directory and returns a PathScanResult containing:
  /// - The directory path
  /// - List of files in the current directory
  /// - Map of subdirectories with their respective PathScanResults
  static PathScanResult scanDirectory(String path) {
    final directory = Directory(path);

    if (!directory.existsSync()) {
      throw DirectoryNotFoundException('Directory not found: $path');
    }

    final baseFiles = <XFile>[];
    final subdirectoryResults = <String, PathScanResult>{};

    try {
      final entities = directory.listSync(recursive: false); // Non-recursive initial scan

      // First pass: separate files and create subdirectory structure
      for (var entity in entities) {
        if (entity is File) {
          baseFiles.add(XFile(entity.path));
        } else if (entity is Directory) {
          final subdirName = entity.path.split(Platform.pathSeparator).last;
          // Recursively scan subdirectories
          subdirectoryResults[subdirName] = scanDirectory(entity.path);
        }
      }

    } catch (e) {
      throw DirectoryScanException('Error scanning directory: $e');
    }

    return PathScanResult(path, baseFiles, subdirectoryResults);
  }

  /// Prints the scanned directory structure for debugging purposes
  static void printDirectoryStructure(PathScanResult result, {int indent = 0}) {
    if (kDebugMode) {
      final indentation = '  ' * indent;
      final dirName = result.path.split(Platform.pathSeparator).last;

      print('$indentation📁 $dirName');

      // Print files in current directory
      if (result.baseFiles.isNotEmpty) {
        print('$indentation  📄 Files:');
        for (var file in result.baseFiles) {
          print('$indentation    ${file.path.split(Platform.pathSeparator).last}');
        }
      }

      // Recursively print subdirectories
      if (result.subdirectoryResults.isNotEmpty) {
        result.subdirectoryResults.forEach((subdirName, scanResult) {
          printDirectoryStructure(scanResult, indent: indent + 2);
        });
      }
    }
  }
}

/// Custom exceptions remain the same
class DirectoryNotFoundException implements Exception {
  final String message;
  DirectoryNotFoundException(this.message);
  @override
  String toString() => message;
}

class DirectoryScanException implements Exception {
  final String message;
  DirectoryScanException(this.message);
  @override
  String toString() => message;
}

class PathScanResult {
  final String path;
  final List<XFile> baseFiles;
  final Map<String, PathScanResult> subdirectoryResults;

  PathScanResult(this.path, this.baseFiles, this.subdirectoryResults);

  Map<String, List<XFile>> getAllSubdirectoryFiles() {
    if(subdirectoryResults.isEmpty) {
      return {path: baseFiles};
    }

    final Map<String, List<XFile>> result = {};
    for(final entry in subdirectoryResults.entries) {
      result.addAll(entry.value.getAllSubdirectoryFiles());
    }

    return result;
  }
}
