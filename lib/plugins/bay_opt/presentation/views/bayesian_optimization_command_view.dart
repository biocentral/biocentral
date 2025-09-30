import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_hub_bloc.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_iteration_bloc.dart';
import 'package:biocentral/plugins/bay_opt/presentation/dialogs/bayesian_optimization_add_experimental_data_dialog.dart';
import 'package:biocentral/plugins/bay_opt/presentation/dialogs/bayesian_optimization_config_dialog.dart';
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

  void openStartTrainingDialog(BayesianOptimizationHubState hubState, BayesianOptimizationIterationBloc iterationBloc) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BayesianOptimizationConfigDialog(
          onStartTraining: (config) => iterationBloc.add(BayesianOptimizationIterationStartEvent(config)),
          initialConfig: hubState.latestResult?.trainingConfig,
        );
      },
    );
  }

  //void openPreviousTrainingsDialog(BuildContext context) async {
  //  BlocProvider.of<BayesianOptimizationBloc>(context).add(BayesianOptimizationLoadPreviousTrainings());
  //}

  void openAddExperimentalDataDialog(BayesianOptimizationHubBloc hubBloc, BayesianOptimizationHubState hubState) {
    if (hubState.trainingResults.isEmpty || hubState.latestResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No current training result available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BayesianOptimizationAddExperimentalDataDialog(
          currentResult: hubState.latestResult!,
          onFinishedAddingData: (experimentalData) {
            if (experimentalData != null && experimentalData.isNotEmpty) {
              hubBloc.add(BayesianOptimizationHubAddExperimentalDataEvent(experimentalData: experimentalData));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final BayesianOptimizationHubBloc hubBloc = BlocProvider.of<BayesianOptimizationHubBloc>(context);
    final BayesianOptimizationIterationBloc iterationBloc = context.read<BayesianOptimizationIterationBloc>();

    return BlocBuilder<BayesianOptimizationHubBloc, BayesianOptimizationHubState>(
      builder: (context, hubState) {
        return BiocentralCommandBar(
          commands: [
            BiocentralTooltip(
              message: 'Start new iteration',
              child: BiocentralButton(
                iconData: Icons.add,
                onTap: () {
                  openStartTrainingDialog(hubState, iterationBloc);
                },
                requiredServices: const ['protein_service'],
              ),
            ),
            BiocentralTooltip(
              message: 'Add experimental data',
              child: BiocentralButton(
                iconData: Icons.model_training,
                onTap: () {
                  openAddExperimentalDataDialog(hubBloc, hubState);
                },
              ),
            ),
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
      },
    );
  }
}
