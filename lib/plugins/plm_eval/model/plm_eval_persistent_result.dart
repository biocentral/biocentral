import 'package:biocentral/plugins/plm_eval/data/plm_eval_service_api.dart';
import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class PLMEvalPersistentResult {
  final String embedderName;
  final DateTime trainingDate;
  final Map<String, PredictionModel> results;

  PLMEvalPersistentResult._internal(this.embedderName, this.trainingDate, this.results);

  PLMEvalPersistentResult.fromAutoEvalProgressWrapper(AutoEvalProgressWrapper progress)
      : embedderName = progress.embedderName,
        trainingDate = DateTime.now(),
        results = Map.from(progress.results);

  static PLMEvalPersistentResult? fromMap(Map<String, dynamic> map) {
    final embedderName = map['embedder_name'];
    final trainingDate = DateTime.tryParse(map['training_date'] ?? '');
    final Map<String, dynamic> parsedResults = map['results'] ?? {};
    if (embedderName == null || trainingDate == null || parsedResults.isEmpty) {
      return null;
    }
    final Map<String, PredictionModel> results = {};
    for (final (taskName, taskResult)  in parsedResults.entriesRecord) {
      final predictionModel = PredictionModel.fromMap(taskResult);

      if(predictionModel == null) {
        return null;
      }

      results[taskName] = predictionModel;
    }
    return PLMEvalPersistentResult._internal(embedderName, trainingDate, results);
  }

  Map<String, dynamic> toMap() {
    final Map<String, Map<String, dynamic>> resultsMap = {};

    for (final (taskName, predictionModel) in results.entriesRecord) {
      resultsMap[taskName] = predictionModel.toMap(includeTrainingLogs: false);
    }
    return {'embedder_name': embedderName, 'training_date': trainingDate.toIso8601String(), 'results': resultsMap};
  }
}
