import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_hub_bloc.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_iteration_bloc.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_training_result.dart';
import 'package:biocentral/plugins/bay_opt/presentation/views/bay_opt_database_grid_view.dart';
import 'package:biocentral/plugins/bay_opt/presentation/views/bay_opt_plot_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_task_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BayOptIterationResultView extends StatefulWidget {
  const BayOptIterationResultView({super.key});

  @override
  State<BayOptIterationResultView> createState() => _BayOptIterationResultViewState();
}

class _BayOptIterationResultViewState extends State<BayOptIterationResultView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<BayOptHubBloc, BayOptHubState>(
      builder: (context, hubState) {
        return Scaffold(
          body: SingleChildScrollView(
            child: buildResult(hubState),
          ),
        );
      },
    );
  }

  Widget buildResult(BayOptHubState hubState) {
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
              child: BayOptPlotView(
                yLabel: 'Score',
                data: hubState.selectedResult,
              ),
            ),
            SizedBox(
              width: widgetWidth,
              height: widgetHeight,
              child: const BayOptDatabaseGridView(),
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

  Widget buildPredictionErrorDisplay(BayOptHubState hubState) {
    final predictionError = hubState.selectedResult?.getAveragePredictionError();
    if (predictionError == null) {
      return Container();
    }
    return Text('Average prediction error: ${predictionError.toStringAsFixed(Constants.maxDoublePrecision)}');
  }

  @override
  bool get wantKeepAlive => true;
}
