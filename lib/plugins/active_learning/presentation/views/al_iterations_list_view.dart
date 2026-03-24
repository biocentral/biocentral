import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_iteration_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_task_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ALIterationsListView extends StatefulWidget {
  const ALIterationsListView({super.key});

  @override
  State<ALIterationsListView> createState() => _ALIterationsListViewState();
}

class _ALIterationsListViewState extends State<ALIterationsListView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ALHubBloc, ALHubState>(
      builder: (context, hubState) {
        return BlocBuilder<ALIterationBloc, ALIterationState>(
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

  Widget buildRunningIterationView(ALIterationState iterationState) {
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

  Widget buildFinishedIterationsView(ALHubState hubState) {
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
