import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/bayesian-optimization/bloc/bayesian_optimization_bloc.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/dialogs/start_bayesian_optimization_dialog.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class BayesianOptimizationCommandView extends StatefulWidget {
  const BayesianOptimizationCommandView({super.key});

  @override
  State<BayesianOptimizationCommandView> createState() => _BayesianOptimizationCommandViewState();
}

class _BayesianOptimizationCommandViewState extends State<BayesianOptimizationCommandView> {
  @override
  void initState() {
    super.initState();
  }

  void openStartTrainingDialog(BuildContext dialogContext) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StartBOTrainingDialog(
          (
            String? selectedTask,
            String? selectedFeature,
            String? selectedModel,
            double exploitationExplorationValue,
            PredefinedEmbedder? selectedEmbedder, {
            String? optimizationType,
            double? targetValue,
            double? targetRangeMin,
            double? targetRangeMax,
            bool? desiredBooleanValue,
          }) {
            final boBloc = dialogContext.read<BayesianOptimizationBloc>();

            boBloc.add(
              BayesianOptimizationTrainingStarted(
                dialogContext,
                selectedTask,
                selectedFeature,
                selectedModel,
                exploitationExplorationValue,
                selectedEmbedder,
                optimizationType: optimizationType,
                targetValue: targetValue,
                targetRangeMin: targetRangeMin,
                targetRangeMax: targetRangeMax,
                desiredBooleanValue: desiredBooleanValue,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandBar(
      commands: [
        BiocentralTooltip(
          message: 'Start new training',
          child: BiocentralButton(
            iconData: Icons.add,
            onTap: () {
              openStartTrainingDialog(context);
            },
          ),
        ),
        BiocentralTooltip(
          message: 'Add new experimental data',
          child: BiocentralButton(
            iconData: Icons.model_training,
            onTap: () {
              // Add your onTap logic here
            },
          ),
        ),
      ],
    );
  }
}
