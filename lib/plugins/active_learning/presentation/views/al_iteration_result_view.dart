import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/presentation/views/al_database_grid_view.dart';
import 'package:biocentral/plugins/active_learning/presentation/views/al_plot_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ALIterationResultView extends StatefulWidget {
  const ALIterationResultView({super.key});

  @override
  State<ALIterationResultView> createState() => _ALIterationResultViewState();
}

class _ALIterationResultViewState extends State<ALIterationResultView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ALHubBloc, ALHubState>(
      builder: (context, hubState) {
        return Scaffold(
          body: SingleChildScrollView(
            child: buildResult(hubState),
          ),
        );
      },
    );
  }

  Widget buildResult(ALHubState hubState) {
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
              child: ALPlotView(
                yLabel: 'Score',
                data: hubState.selectedResult,
              ),
            ),
            SizedBox(
              width: widgetWidth,
              height: widgetHeight,
              child: const ALDatabaseGridView(),
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

  Widget buildPredictionErrorDisplay(ALHubState hubState) {
    final predictionError = hubState.selectedResult?.getAveragePredictionError();
    if (predictionError == null) {
      return Container();
    }
    return Text('Average prediction error: ${predictionError.toStringAsFixed(Constants.maxDoublePrecision)}');
  }

  @override
  bool get wantKeepAlive => true;
}
