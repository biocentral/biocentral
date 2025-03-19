import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';

class PLMEvalPersistentResult {
  final String modelName;
  final Map<BenchmarkDataset, PredictionModel?> results; // TODO Prediction Model from/to minimal JSON

  PLMEvalPersistentResult._internal(this.modelName, this.results);

  // TODO TO JSON, DOMAIN, DIRECTORY, SAVE, LOAD
  PLMEvalPersistentResult.fromAutoEvalProgress(AutoEvalProgress progress)
      : modelName = progress.modelName,
        results = Map.from(progress.results);

  static PLMEvalPersistentResult? fromMap(Map<String, dynamic> map) {
    final embedderName = map['modelName'];
    final Map<String, dynamic> parsedResults = map['results'] ?? {};
    if (embedderName == null || parsedResults.isEmpty) {
      return null;
    }
    final Map<BenchmarkDataset, PredictionModel?> results = {};
    for (final entry in parsedResults.entries) {
      final datasetName = entry.key;
      for (final parsedSplit in entry.value.entries) {
        final splitName = parsedSplit.key;
        final predictionModel = PredictionModel.fromMap(parsedSplit.value);

        final benchmarkDataset = BenchmarkDataset(datasetName: datasetName, splitName: splitName);
        results[benchmarkDataset] = predictionModel;
      }
    }
    return PLMEvalPersistentResult._internal(embedderName, results);
  }

  Map<String, dynamic> toMap() {
    final Map<String, Map<String, Map>> resultsMap = {};
    final separatedResultMap = BenchmarkDataset.separateBenchmarkDatasetsMapToSplitList(results);
    for (final entry in separatedResultMap.entries) {
      resultsMap.putIfAbsent(entry.key, () => {});
      for (final (splitName, predictionModel) in entry.value) {
        resultsMap[entry.key]?[splitName] = predictionModel?.toMap(includeTrainingLogs: false) ?? {};
      }
    }
    return {'modelName': modelName, 'results': resultsMap};
  }
}
