import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

/// Class to store logic of plugin directory handling (loading, files, etc.)
class BiocentralPluginDirectory {
  final String path;
  final Type saveType;

  /// Returns functions that add load events to the command bloc
  /// TODO: Can be improved such that used files/subdirs are returned and tracked, if there is a file/subdir not loaded
  final List<void Function(BuildContext context)> Function(
    List<XFile> scannedFiles,
    Map<String, List<XFile>> scannedSubDirectories,
  ) createDirectoryLoadingEvents;

  BiocentralPluginDirectory({
    required this.path,
    required this.saveType,
    required this.createDirectoryLoadingEvents,
  });
}
