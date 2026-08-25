import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_metrics_display.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:flutter/material.dart';

class ModelComparisonView extends StatelessWidget {
  final List<PredictionModel> modelsToCompare;

  const ModelComparisonView({required this.modelsToCompare, super.key});

  @override
  Widget build(BuildContext context) {
    if (modelsToCompare.isEmpty) {
      return const Center(child: Text('Drag models to the comparison tab to compare models!'));
    }
    return compareMetricsDisplay();
  }

  Widget compareMetricsDisplay() {
    final metrics = <String, Set<BootstrappedMetric>>{};
    //    final metrics = {'Test Set Metrics': testResult.metrics}
    //       ..addAll(testResult.baselineMetrics);
    for (final predictionModel in modelsToCompare) {
      // TODO Support multiple test sets
      final testResult = predictionModel.defaultTestResult;
      if (testResult != null) {
        metrics.addAll({predictionModel.getReadableModelID(): testResult.bootstrappedMetrics?.toSet() ?? {}});
        metrics.addAll(
          testResult.baselines?.asMap().map(
                    (name, metrics) =>
                        // Prefix random model with model ID because it can be different for the compared models
                        MapEntry(name.contains('random') ? '${predictionModel.getReadableModelID()}-random' : name,
                            metrics.toSet()),
                  ) ??
              {},
        );
      }
    }
    return BiocentralMetricsDisplay(metrics: metrics);
  }
}
