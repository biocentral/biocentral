import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

class EmbeddingsFileDisplay extends StatelessWidget {
  final XFile? file;
  final EmbeddingsFileInformation? information;

  const EmbeddingsFileDisplay({required this.file, required this.information, super.key});

  static Widget visualizeEmbeddingsFileResult(BiocentralCommandLog result) {
    final commandResult = result.result?.result;
    if (commandResult == null || commandResult is! EmbeddingsFile) {
      // TODO ERROR HANDLING
      return BiocentralStatusIndicator(metaData: result.metaData);
    }
    final embeddingsFile = commandResult;
    return EmbeddingsFileDisplay(file: null, information: embeddingsFile.fileInformation);
  }

  Future<Map<String, dynamic>> getEmbeddingsFileInfo() async {
    final stats = <String, dynamic>{};

    if (file != null) {
      final fileSize = await file!.length();
      stats['File Size'] = bytesAsFormatString(fileSize);
    }
    if (information != null) {
      stats.addAll(information!.stats());
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getEmbeddingsFileInfo(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final stats = asyncSnapshot.data ?? {};
        if (stats.isEmpty) {
          return Container();
        }
        return DataTable(
          columns: [const DataColumn(label: Text('File Information')), const DataColumn(label: Text('Value'))],
          rows: stats.entries
              .map((entry) => DataRow(cells: [DataCell(Text(entry.key)), DataCell(Text(entry.value.toString()))]))
              .toList(),
        );
      },
    );
  }
}
