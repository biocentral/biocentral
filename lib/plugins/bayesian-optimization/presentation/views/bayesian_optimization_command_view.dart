import 'package:biocentral/plugins/bayesian-optimization/bloc/bayesian_optimization_bloc.dart';
import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_model_types.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/dialogs/bayesian_optimization_training_dialog_bloc.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/dialogs/iterate_training_dialog.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/dialogs/start_bayesian_optimization_dialog.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            TaskType? selectedTask,
            String? selectedFeature,
            BayesianOptimizationModelTypes? selectedModel,
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

  void openPreviousTrainingsDialog(BuildContext context) async {
    BlocProvider.of<BayesianOptimizationBloc>(context).add(BayesianOptimizationLoadPreviousTrainings());
  }

  void openIterateTrainingDialog(BuildContext context) {
    final boBloc = context.read<BayesianOptimizationBloc>();
    if (boBloc.currentResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No current training result available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return IterateTrainingDialog(
          currentResult: boBloc.currentResult!,
          onStartIteration: (inputList) {
            boBloc.add(BayesianOptimizationIterateTraining(context, boBloc.currentResult!, inputList));
          },
          onStartDirectIteration: (inputList) {
            boBloc.add(BayesianOptimizationDirectIterateTraining(context, boBloc.currentResult!, inputList));
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
            requiredServices: const ['protein_service'],
          ),
        ),
        BiocentralTooltip(
          message: 'Iterate new training with actual data',
          child: BiocentralButton(
            iconData: Icons.model_training,
            onTap: () {
              openIterateTrainingDialog(context);
            },
          ),
        ),
        BiocentralTooltip(
          message: 'Select previous training to view results',
          child: BiocentralButton(
            iconData: Icons.history,
            onTap: () {
              openPreviousTrainingsDialog(context);
            },
          ),
        ),
      ],
    );
  }
}
