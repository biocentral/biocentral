import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_hub_bloc.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_iteration_bloc.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_training_result.dart';
import 'package:biocentral/plugins/bay_opt/presentation/views/bayesian_optimization_database_grid_view.dart';
import 'package:biocentral/plugins/bay_opt/presentation/views/bayesian_optimization_plot_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_task_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BayesianOptimizationIterationResultView extends StatefulWidget {
  const BayesianOptimizationIterationResultView({super.key});

  @override
  State<BayesianOptimizationIterationResultView> createState() => _BayesianOptimizationIterationResultViewState();
}

class _BayesianOptimizationIterationResultViewState extends State<BayesianOptimizationIterationResultView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<BayesianOptimizationHubBloc, BayesianOptimizationHubState>(
      builder: (context, hubState) {
        return Scaffold(
          body: SingleChildScrollView(
            child: buildResult(hubState),
          ),
        );
      },
    );
  }

  Widget buildResult(BayesianOptimizationHubState hubState) {
    if (hubState.selectedResult == null) {
      return const Text('No results yet!');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetWidth = (constraints.maxWidth * 0.8); // 90% of available width
        final widgetHeight = widgetWidth * 0.4; // Maintain aspect ratio
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO Use index Center(child: Text('Results for iteration: ${hubState.selectedResultIndex + 1}')),
            Center(child: Text('Results for iteration: ${hubState.trainingResults.length}')),
            SizedBox(
              width: widgetWidth,
              height: widgetHeight,
              child: BayesianOptimizationPlotView(
                yLabel: 'Score',
                data: hubState.selectedResult,
              ),
            ),
            SizedBox(
              width: widgetWidth,
              height: widgetHeight,
              child: const BayesianOptimizationDatabaseGridView(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildPredictionErrorDisplay(hubState),
            ),
          ],
        );
      },
    );
  }

  Widget buildPredictionErrorDisplay(BayesianOptimizationHubState hubState) {
    final predictionError = hubState.selectedResult?.getAveragePredictionError();
    if (predictionError == null) {
      return Container();
    }
    return Text('Average prediction error: ${predictionError.toStringAsFixed(Constants.maxDoublePrecision)}');
  }

  @override
  bool get wantKeepAlive => true;
}
