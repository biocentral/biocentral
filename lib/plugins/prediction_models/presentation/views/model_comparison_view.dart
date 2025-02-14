import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:flutter/material.dart';

class ModelComparisonView extends StatelessWidget {
  final List<PredictionModel> modelsToCompare;

  const ModelComparisonView({required this.modelsToCompare, super.key});

  @override
  Widget build(BuildContext context) {
    if (modelsToCompare.isEmpty) {
      return const Text('Drag models to the comparison tag to compare models!');
    }
    return Column(
      children: modelsToCompare.map((model) => Text(model.toString())).toList(),
    );
  }
}
