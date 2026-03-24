import 'package:biocentral/plugins/active_learning/bloc/al_config_dialog_bloc.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_iteration_bloc.dart';
import 'package:biocentral/plugins/active_learning/presentation/dialogs/al_add_experimental_data_dialog.dart';
import 'package:biocentral/plugins/active_learning/presentation/dialogs/al_config_dialog_builder.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/dialogs/biocentral_config_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ALCommandView extends StatefulWidget {
  const ALCommandView({super.key});

  @override
  State<ALCommandView> createState() => _ALCommandViewState();
}

class _ALCommandViewState extends State<ALCommandView> {
  @override
  void initState() {
    super.initState();
  }

  void openStartTrainingDialog(ALHubState hubState, ALIterationBloc iterationBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => ALConfigDialogBloc(
            context.read<BiocentralDatabaseRepository>(),
            context.read<BiocentralProjectRepository>(),
          ),
          child: BlocBuilder<ALConfigDialogBloc, ALConfigDialogState>(
            builder: (context, state) => BiocentralConfigDialog(
              configDialogBuilder:
                  ALConfigDialogBuilder((config) => iterationBloc.add(ALIterationStartEvent(config))),
              bloc: BlocProvider.of<ALConfigDialogBloc>(context),
              state: state,
            ),
          ),
        );
      },
    );
  }

  void openAddExperimentalDataDialog(ALHubBloc hubBloc, ALHubState hubState) {
    if (hubState.trainingResults.isEmpty || hubState.latestResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No current training result available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ALAddExperimentalDataDialog(
          currentResult: hubState.latestResult!,
          onFinishedAddingData: (experimentalData) {
            if (experimentalData != null && experimentalData.isNotEmpty) {
              hubBloc.add(ALHubAddExperimentalDataEvent(experimentalData: experimentalData));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ALHubBloc hubBloc = BlocProvider.of<ALHubBloc>(context);
    final ALIterationBloc iterationBloc = context.read<ALIterationBloc>();

    return BlocBuilder<ALHubBloc, ALHubState>(
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
