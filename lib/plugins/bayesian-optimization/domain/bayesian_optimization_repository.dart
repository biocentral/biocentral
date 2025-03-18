import 'dart:typed_data';
import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:file_picker/file_picker.dart';

class BayesianOptimizationRepository {
  BayesianOptimizationTrainingResult? currentResult;
  List<BayesianOptimizationTrainingResult>? previousTrainingResults;

  BayesianOptimizationRepository() {
    currentResult = dummyData;
    previousTrainingResults = [dummyData, dummyData, dummyData];
  }

  void addPreviousTrainingResults(BayesianOptimizationTrainingResult r) {
    previousTrainingResults ??= [];
    previousTrainingResults?.add(r);
  }

  void setPreviousTrainingResults(List<BayesianOptimizationTrainingResult> results) {
    previousTrainingResults = results;
  }

  void setCurrentResult(BayesianOptimizationTrainingResult? r) {
    r ??= dummyData;
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
  }

  BayesianOptimizationTrainingResult convertCSVtoTrainingResult(Uint8List? bytes) {
    if (bytes == null) {
      return dummyData;
    }

    final String csvString = String.fromCharCodes(bytes);
    final List<String> rows = csvString.split('\n');

    if (rows.isEmpty) {
      return dummyData;
    }

    final List<BayesianOptimizationTrainingResultData> results = [];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i].trim();
      if (row.isEmpty) continue;

      final List<String> columns = row.split(',');
      if (columns.length < 4) continue;

      try {
        results.add(
          BayesianOptimizationTrainingResultData(
            proteinId: columns[0],
            prediction: double.parse(columns[1]),
            uncertainty: double.parse(columns[2]),
            utility: double.parse(columns[3]),
          ),
        );
      } catch (e) {
        // Skip invalid rows
        continue;
      }
    }

    if (results.isEmpty) {
      return dummyData;
    }

    return BayesianOptimizationTrainingResult(results: results);
  }

  String convertTrainingResultToCSV(BayesianOptimizationTrainingResult result) {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('protein_id,prediction,uncertainty,utility');

    if (result.results != null) {
      for (final data in result.results!) {
        buffer.writeln('${data.proteinId},${data.prediction},${data.uncertainty},${data.utility}');
      }
    }

    return buffer.toString();
  }

  // EXAMPLE DATA
  final BayesianOptimizationTrainingResult dummyData = const BayesianOptimizationTrainingResult(
    results: [
      BayesianOptimizationTrainingResultData(proteinId: '1', prediction: 32, uncertainty: -1.4, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '2', prediction: 35, uncertainty: -1.0, utility: -1.2),
      BayesianOptimizationTrainingResultData(proteinId: '3', prediction: 37, uncertainty: -0.8, utility: -0.5),
      BayesianOptimizationTrainingResultData(proteinId: '4', prediction: 40, uncertainty: -0.5, utility: -0.2),
      BayesianOptimizationTrainingResultData(proteinId: '5', prediction: 42, uncertainty: -0.2, utility: 0.0),
      BayesianOptimizationTrainingResultData(proteinId: '6', prediction: 45, uncertainty: 0.0, utility: 0.2),
      BayesianOptimizationTrainingResultData(proteinId: '7', prediction: 47, uncertainty: 0.2, utility: 0.5),
      BayesianOptimizationTrainingResultData(proteinId: '8', prediction: 50, uncertainty: 0.5, utility: 0.8),
      BayesianOptimizationTrainingResultData(proteinId: '9', prediction: 52, uncertainty: 0.8, utility: 1.0),
      BayesianOptimizationTrainingResultData(proteinId: '10', prediction: 55, uncertainty: 1.0, utility: 1.5),
      BayesianOptimizationTrainingResultData(proteinId: '11', prediction: 32, uncertainty: -1.5, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '12', prediction: 35, uncertainty: -1.1, utility: -1.2),
      BayesianOptimizationTrainingResultData(proteinId: '13', prediction: 37, uncertainty: -0.1, utility: -0.5),
      BayesianOptimizationTrainingResultData(proteinId: '14', prediction: 40, uncertainty: -0.2, utility: -0.2),
      BayesianOptimizationTrainingResultData(proteinId: '15', prediction: 42, uncertainty: -0.5, utility: 1.0),
      BayesianOptimizationTrainingResultData(proteinId: '16', prediction: 45, uncertainty: 0.5, utility: 1.2),
      BayesianOptimizationTrainingResultData(proteinId: '17', prediction: 47, uncertainty: 0.6, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '18', prediction: 50, uncertainty: 0.1, utility: 0.8),
    ],
  );
}
