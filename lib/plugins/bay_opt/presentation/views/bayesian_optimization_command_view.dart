import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_config_dialog_bloc.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_iteration_bloc.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_model_types.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_config_dialog_bloc.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_task.dart';
import 'package:biocentral/plugins/bay_opt/presentation/dialogs/bayesian_optimization_iterate_training_dialog.dart';
import 'package:biocentral/plugins/bay_opt/presentation/dialogs/bayesian_optimization_config_dialog.dart';
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

  void openStartTrainingDialog() {
    final BayesianOptimizationIterationBloc boIterationBloc = context.read<BayesianOptimizationIterationBloc>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BayesianOptimizationConfigDialog(
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

            boIterationBloc.add(
              BayesianOptimizationIterationStartEvent(
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

  /*
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
            boBloc.add(BayesianOptimizationIterateTrainingEvent(context, boBloc.currentResult!, inputList));
          },
          onStartDirectIteration: (inputList) {
            boBloc.add(BayesianOptimizationDirectIterateTrainingEvent(context, boBloc.currentResult!, inputList));
          },
        );
      },
    );
  }
*/

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandBar(
      commands: [
        BiocentralTooltip(
          message: 'Start new training',
          child: BiocentralButton(
            iconData: Icons.add,
            onTap: () {
              openStartTrainingDialog();
            },
            requiredServices: const ['protein_service'],
          ),
        ),
        //BiocentralTooltip(
        //  message: 'Iterate new training with actual data',
        //  child: BiocentralButton(
        //    iconData: Icons.model_training,
        //    onTap: () {
        //      openIterateTrainingDialog(context);
        //    },
        //  ),
        //),
        //BiocentralTooltip(
        //  message: 'Select previous training to view results',
        //  child: BiocentralButton(
        //    iconData: Icons.history,
        //    onTap: () {
        //      openPreviousTrainingsDialog(context);
        //    },
        //  ),
        //),
      ],
    );
  }
}
