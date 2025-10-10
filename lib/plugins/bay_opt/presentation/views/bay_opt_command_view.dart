import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_config_dialog_bloc.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_hub_bloc.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_iteration_bloc.dart';
import 'package:biocentral/plugins/bay_opt/presentation/dialogs/bay_opt_add_experimental_data_dialog.dart';
import 'package:biocentral/plugins/bay_opt/presentation/dialogs/bay_opt_config_dialog_builder.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/dialogs/biocentral_config_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BayOptCommandView extends StatefulWidget {
  const BayOptCommandView({super.key});

  @override
  State<BayOptCommandView> createState() => _BayOptCommandViewState();
}

class _BayOptCommandViewState extends State<BayOptCommandView> {
  @override
  void initState() {
    super.initState();
  }

  void openStartTrainingDialog(BayOptHubState hubState, BayOptIterationBloc iterationBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => BayOptConfigDialogBloc(
            context.read<BiocentralDatabaseRepository>(),
            context.read<BiocentralProjectRepository>(),
          ),
          child: BlocBuilder<BayOptConfigDialogBloc, BayOptConfigDialogState>(
            builder: (context, state) => BiocentralConfigDialog(
              configDialogBuilder:
                  BayOptConfigDialogBuilder((config) => iterationBloc.add(BayOptIterationStartEvent(config))),
              bloc: BlocProvider.of<BayOptConfigDialogBloc>(context),
              state: state,
            ),
          ),
        );
      },
    );
  }

  void openAddExperimentalDataDialog(BayOptHubBloc hubBloc, BayOptHubState hubState) {
    if (hubState.trainingResults.isEmpty || hubState.latestResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No current training result available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BayOptAddExperimentalDataDialog(
          currentResult: hubState.latestResult!,
          onFinishedAddingData: (experimentalData) {
            if (experimentalData != null && experimentalData.isNotEmpty) {
              hubBloc.add(BayOptHubAddExperimentalDataEvent(experimentalData: experimentalData));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final BayOptHubBloc hubBloc = BlocProvider.of<BayOptHubBloc>(context);
    final BayOptIterationBloc iterationBloc = context.read<BayOptIterationBloc>();

    return BlocBuilder<BayOptHubBloc, BayOptHubState>(
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
