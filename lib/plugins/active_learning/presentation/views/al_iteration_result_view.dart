import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
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

  int _selectedResultIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<ALHubBloc, ALHubState>(
      listenWhen: (previous, current) =>
          previous.selectedCampaign?.internalName() != current.selectedCampaign?.internalName(),
      listener: (context, state) {
        setState(() {
          _selectedResultIndex = 0;
        });
      },
      builder: (context, hubState) {
        return Scaffold(
          body: SingleChildScrollView(
            child: buildContent(hubState),
          ),
        );
      },
    );
  }

  Widget buildContent(ALHubState hubState) {
    if (hubState.campaigns.isEmpty) {
      return const Center(child: Text('No active learning campaigns yet!'));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: BiocentralDiscreteSelection<ALCampaign>(
            title: 'Select Campaign',
            initialValue: hubState.selectedCampaign,
            selectableValues: hubState.campaigns,
            displayConversion: (campaign) => campaign.config.name,
            onChangedCallback: (campaign) =>
                context.read<ALHubBloc>().add(ALHubSelectCampaignEvent(campaign)),
          ),
        ),
        if (hubState.selectedCampaign != null) buildResult(hubState.selectedCampaign!),
      ],
    );
  }

  Widget buildResult(ALCampaign campaign) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetWidth = constraints.maxWidth * 0.8; // 90% of available width
        final widgetHeight = widgetWidth * 0.4; // Maintain aspect ratio
        final totalIterations = campaign.iterationResults.length;
        if (totalIterations == 0) {
          return const Center(child: Text('No iteration results available.'));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(campaign.config.name),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: _selectedResultIndex > 0 ? () => setState(() => _selectedResultIndex--) : null,
                ),
                Text('Results for iteration: ${_selectedResultIndex + 1}'),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: _selectedResultIndex < totalIterations - 1  ? () => setState(() => _selectedResultIndex++) : null,
                ),
              ],
            ),
            SizedBox(
              width: widgetWidth,
              height: widgetHeight,
              child: ALPlotView(
                yLabel: 'Score',
                data: campaign.iterationResults[_selectedResultIndex].$2,
              ),
            ),
            SizedBox(
              width: widgetWidth,
              height: widgetHeight,
              child: ALDatabaseGridView(
                campaign: campaign,
                displayedResult: campaign.iterationResults[_selectedResultIndex].$2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildPredictionErrorDisplay(campaign),
            ),
          ],
        );
      },
    );
  }

  Widget buildPredictionErrorDisplay(ALCampaign campaign) {
    final predictionError = null; // TODO
    if (predictionError == null) {
      return Container();
    }
    return Text('Average prediction error: ${predictionError.toStringAsFixed(Constants.maxDoublePrecision)}');
  }

  @override
  bool get wantKeepAlive => true;
}

// TODO
/*
  double? getAveragePredictionError() {
    // TODO Add accuracy for binary predictions, maybe include in BiocentralMLMetric
    if(experimentalData.isEmpty) {
      return null;
    }
    final predictionErrors = <double>[];
    for(final result in results) {
      final experimentalValue = double.tryParse(experimentalData[result.id].toString());
      if(experimentalValue != null) {
        final prediction = result.prediction;
        final predictionError = (experimentalValue.abs() - prediction.abs()).abs();
        predictionErrors.add(predictionError);
      }
    }
    final predictionErrorSum = predictionErrors.reduce((e1, e2) => e1 + e2);
    return predictionErrorSum / predictionErrors.length;
  }
 */
