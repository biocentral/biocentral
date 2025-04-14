import 'dart:typed_data';

import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:file_picker/file_picker.dart';

class BayesianOptimizationRepository {
  BayesianOptimizationTrainingResult? currentResult;
  List<BayesianOptimizationTrainingResult>? previousTrainingResults;

  void addPreviousTrainingResults(BayesianOptimizationTrainingResult r) {
    previousTrainingResults ??= [];
    previousTrainingResults?.add(r);
  }

  void setPreviousTrainingResults(List<BayesianOptimizationTrainingResult> results) {
    previousTrainingResults = results;
  }

  void setCurrentResult(BayesianOptimizationTrainingResult? r) {
    currentResult = r;
    saveCurrentResultIntoCSV(currentResult);
  }

  void addPickedPreviousTrainingResults(Uint8List? bytes) {
    final BayesianOptimizationTrainingResult result = convertCSVtoTrainingResult(bytes);
    addPreviousTrainingResults(result);
  }

  void saveCurrentResultIntoCSV(BayesianOptimizationTrainingResult? currentResult) {
    final String buffer = convertTrainingResultToCSV(currentResult!);

    // For desktop/mobile, use file_picker to save
    FilePicker.platform.saveFile(
      fileName: 'bayesian_optimization_results.csv',
      bytes: Uint8List.fromList(buffer.toString().codeUnits),
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    // biocentralProjectRepository.handleSave(fileName: 'bayesian_optimization_results.csv', content: buffer);
  }

  BayesianOptimizationTrainingResult convertCSVtoTrainingResult(Uint8List? bytes) {
    final String csvString = String.fromCharCodes(bytes!);
    final List<String> rows = csvString.split('\n');

    final List<BayesianOptimizationTrainingResultData> results = [];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i].trim();
      if (row.isEmpty) continue;

      final List<String> columns = row.split(',');
      if (columns.length < 3) continue; // Only need 3 columns now: protein_id, sequence, score

      try {
        results.add(
          BayesianOptimizationTrainingResultData(
            proteinId: columns[0],
            sequence: columns[1],
            score: double.parse(columns[2]),
          ),
        );
      } catch (e) {
        // Skip invalid rows
        continue;
      }
    }

    return BayesianOptimizationTrainingResult(results: results);
  }

  String convertTrainingResultToCSV(BayesianOptimizationTrainingResult result) {
    final StringBuffer buffer = StringBuffer();

    // Updated header with new fields
    buffer.writeln('protein_id,sequence,score');

    if (result.results != null) {
      for (final data in result.results!) {
        buffer.writeln('${data.proteinId},${data.sequence},${data.score}');
      }
    }

    return buffer.toString();
  }
}
