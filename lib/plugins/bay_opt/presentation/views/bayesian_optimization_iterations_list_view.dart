import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_hub_bloc.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_iteration_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_task_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BayesianOptimizationIterationsListView extends StatefulWidget {
  const BayesianOptimizationIterationsListView({super.key});

  @override
  State<BayesianOptimizationIterationsListView> createState() => _BayesianOptimizationIterationsListViewState();
}

class _BayesianOptimizationIterationsListViewState extends State<BayesianOptimizationIterationsListView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<BayesianOptimizationHubBloc, BayesianOptimizationHubState>(
      builder: (context, hubState) {
        return BlocBuilder<BayesianOptimizationIterationBloc, BayesianOptimizationIterationState>(
          builder: (context, iterationState) {
            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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

  Widget buildRunningIterationView(BayesianOptimizationIterationState iterationState) {
    if (!iterationState.isOperating()) {
      return Container();
    }
    // TODO [Refactor] Unify running task display widget with prediction models
    return BiocentralTaskDisplay(
      title: 'Running bo iteration..',
      leadingIcon: const CircularProgressIndicator(),
      trailing: BiocentralStatusIndicator(state: iterationState),
      children: [],
    );
  }

  Widget buildFinishedIterationsView(BayesianOptimizationHubState hubState) {
    if (hubState.trainingResults.isEmpty) {
      return const Text('No results yet!');
    }
    final taskDisplays = <Widget>[];
    for (final (index, iterationResult) in hubState.trainingResults.indexed) {
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
