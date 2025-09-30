import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_hub_bloc.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_iteration_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_task_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BayOptIterationsListView extends StatefulWidget {
  const BayOptIterationsListView({super.key});

  @override
  State<BayOptIterationsListView> createState() => _BayOptIterationsListViewState();
}

class _BayOptIterationsListViewState extends State<BayOptIterationsListView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<BayOptHubBloc, BayOptHubState>(
      builder: (context, hubState) {
        return BlocBuilder<BayOptIterationBloc, BayOptIterationState>(
          builder: (context, iterationState) {
            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildRunningIterationView(iterationState),
                    buildFinishedIterationsView(hubState),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildRunningIterationView(BayOptIterationState iterationState) {
    if (!iterationState.isOperating()) {
      return Container();
    }
    // TODO [Refactor] Unify running task display widget with prediction models
    return BiocentralTaskDisplay(
      title: 'Running iteration..',
      leadingIcon: const CircularProgressIndicator(),
      trailing: BiocentralStatusIndicator(state: iterationState),
      children: [],
    );
  }

  Widget buildFinishedIterationsView(BayOptHubState hubState) {
    if (hubState.trainingResults.isEmpty) {
      return const Text('No results yet!');
    }
    final taskDisplays = <Widget>[];
    for (final (index, iterationResult) in hubState.trainingResults.indexed.toList().reversed) {
      taskDisplays.add(
        BiocentralTaskDisplay(title: 'Iteration ${index + 1}', leadingIcon: const Icon(Icons.check), children: []),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: taskDisplays,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
