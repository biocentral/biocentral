import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class PLMEvalPersistentResult {
  final String embedderName;
  final DateTime trainingDate;
  final Map<BenchmarkDataset, PredictionModel> results;

  PLMEvalPersistentResult._internal(this.embedderName, this.trainingDate, this.results);

  PLMEvalPersistentResult.fromAutoEvalProgress(AutoEvalProgress progress)
      : embedderName = progress.modelName,
        trainingDate = DateTime.now(),
        results = Map.from(progress.results);

  static PLMEvalPersistentResult? fromMap(Map<String, dynamic> map) {
    final embedderName = map['embedder_name'];
    final trainingDate = DateTime.tryParse(map['training_date'] ?? '');
    final Map<String, dynamic> parsedResults = map['results'] ?? {};
    if (embedderName == null || trainingDate == null || parsedResults.isEmpty) {
      return null;
    }
    final Map<BenchmarkDataset, PredictionModel> results = {};
    for (final (benchmarkName, benchmarkResult)  in parsedResults.entriesRecord) {
      final benchmarkDataset = BenchmarkDataset.fromCombinedString(benchmarkName);
      if(benchmarkDataset == null) {
        return null;
      }
      final predictionModel = PredictionModel.fromMap(benchmarkResult);

      if(predictionModel == null) {
        return null;
      }

      results[benchmarkDataset] = predictionModel;
    }
    return PLMEvalPersistentResult._internal(embedderName, trainingDate, results);
  }

  Map<String, dynamic> toMap() {
    final Map<String, Map<String, dynamic>> resultsMap = {};

    for (final (benchmarkDataset, predictionModel) in results.entriesRecord) {
      final benchmarkName = benchmarkDataset.toCombinedString();
      resultsMap[benchmarkName] = predictionModel.toMap(includeTrainingLogs: false);
    }
    return {'embedder_name': embedderName, 'training_date': trainingDate.toIso8601String(), 'results': resultsMap};
  }
}
