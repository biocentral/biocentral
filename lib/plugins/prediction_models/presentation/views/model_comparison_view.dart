import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_metrics_display.dart';
import 'package:flutter/material.dart';

class ModelComparisonView extends StatelessWidget {
  final List<PredictionModel> modelsToCompare;

  const ModelComparisonView({required this.modelsToCompare, super.key});

  @override
  Widget build(BuildContext context) {
    if (modelsToCompare.isEmpty) {
      return const Text('Drag models to the comparison tab to compare models!');
    }
    return compareMetricsDisplay();
  }

  Widget compareMetricsDisplay() {
    final metrics = <String, Set<BiocentralMLMetric>>{};
    //    final metrics = {'Test Set Metrics': testResult.metrics}
    //       ..addAll(testResult.baselineMetrics);
    for (final predictionModel in modelsToCompare) {
      // TODO Support multiple test sets
      final testResult = predictionModel.defaultTestResult;
      if (testResult != null) {
        metrics.addAll({predictionModel.getReadableModelID(): testResult.metrics});
        metrics.addAll(
          testResult.baselineMetrics.map(
            (name, metrics) =>
                // Prefix random model with model ID because it can be different for the compared models
                MapEntry(name.contains('random') ? '${predictionModel.getReadableModelID()}-random' : name, metrics),
          ),
        );
      }
    }
    return BiocentralMetricsDisplay(metrics: metrics);
  }
}
