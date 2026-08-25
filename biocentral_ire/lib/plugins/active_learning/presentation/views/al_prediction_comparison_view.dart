import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/presentation/style/biocentral_style.dart';
import 'package:biocentral/sdk/util/constants.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class ALPredictionComparisonView extends StatelessWidget {
  final String yLabel;
  final ALCampaign campaign;
  final ActiveLearningIterationResult? result;
  final List<ActiveLearningIterationResult>? allResults;

  final WidgetsToImageController _exportController = WidgetsToImageController();

  ALPredictionComparisonView({
    required this.yLabel,
    required this.campaign,
    this.result,
    this.allResults,
    super.key,
  }) : assert(result != null || allResults != null, 'Either result or allResults must be provided');

  String get _defaultFileName {
    final suffix = result != null ? 'iteration_${result!.iteration}' : 'all_iterations';
    return 'al_prediction_comparison_${campaign.config.name}_$suffix.png';
  }

  List<(ActiveLearningResult, double, double)> _plottableData(Map<String, Protein> proteinDb) {
    if (allResults != null) {
      return _plottableDataFromAll(proteinDb, allResults!);
    }
    return _plottableDataFromSingle(proteinDb, result!);
  }

  List<(ActiveLearningResult, double, double)> _plottableDataFromSingle(Map<String, Protein> proteinDb, ActiveLearningIterationResult result) {
    final suggestionSet = result.suggestions.toSet();
    final entries = <(ActiveLearningResult, double, double)>[];
    for (final r in result.results) {
      if (!suggestionSet.contains(r.entityId)) continue;
      final prediction = double.tryParse(r.prediction);
      if (prediction == null) continue;
      final rawExperimental = proteinDb[r.entityId]?.attributes[campaign.columnName];
      final experimental = double.tryParse(rawExperimental?.toString() ?? '');
      if (experimental == null) continue;
      entries.add((r, prediction, experimental));
    }
    return entries;
  }

  List<(ActiveLearningResult, double, double)> _plottableDataFromAll(Map<String, Protein> proteinDb, List<ActiveLearningIterationResult> allResults) {
    final entries = <(ActiveLearningResult, double, double)>[];
    for (final iterResult in allResults) {
      entries.addAll(_plottableDataFromSingle(proteinDb, iterResult));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ALHubBloc, ALHubState>(
      buildWhen: (previous, current) => previous.proteinDatabase != current.proteinDatabase || previous.selectedCampaign != current.selectedCampaign,
      builder: (context, state) {
        final data = _plottableData(state.proteinDatabase);
        if (data.isEmpty) return const SizedBox.shrink();

        return ExpansionTile(
          title: const Text('Predictions vs. Experiments'),
          leading: const Icon(Icons.compare_arrows),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Export plot as PNG',
                  onPressed: () => exportWidgetAsPng(
                    messenger: ScaffoldMessenger.of(context),
                    projectRepository: context.read<BiocentralProjectRepository>(),
                    controller: _exportController,
                    defaultFileName: _defaultFileName,
                  ),
                ),
              ],
            ),
            WidgetsToImage(
              controller: _exportController,
              child: Container( // used to color background of screenshot the same as application
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    SizedBox(
                      height: 500,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 35, 16, 24),
                        child: LineChart(_buildChartData(data)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legendDot(BiocentralStyle.alPredictionLineColor),
                          const SizedBox(width: 4),
                          const Text('Prediction', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 16),
                          _legendDot(BiocentralStyle.alExperimentalLineColor),
                          const SizedBox(width: 4),
                          const Text('Experiment', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  LineChartData _buildChartData(List<(ActiveLearningResult, double, double)> data) {
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    for (final (_, pred, exp) in data) {
      if (pred < minY) minY = pred;
      if (pred > maxY) maxY = pred;
      if (exp < minY) minY = exp;
      if (exp > maxY) maxY = exp;
    }
    final range = maxY - minY;
    final padding = range == 0 ? 1.0 : range * 0.15;

    final predictionSeries = LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key + 1.0, e.value.$2)).toList(),
      barWidth: 0,
      color: BiocentralStyle.alPredictionLineColor,
      dotData: FlDotData(
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 7, color: BiocentralStyle.alPredictionLineColor),
      ),
    );

    final experimentalSeries = LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key + 1.0, e.value.$3)).toList(),
      barWidth: 0,
      color: BiocentralStyle.alExperimentalLineColor,
      dotData: FlDotData(
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 7, color: BiocentralStyle.alExperimentalLineColor),
      ),
    );

    final connectors = data.asMap().entries.map((e) {
      final (_, pred, exp) = e.value;
      return LineChartBarData(
        spots: [FlSpot(e.key + 1.0, pred), FlSpot(e.key + 1.0, exp)],
        barWidth: 1.5,
        color: const Color.fromRGBO(120, 120, 120, 0.55),
        dotData: const FlDotData(show: false),
      );
    }).toList();

    final allSeries = [...connectors, predictionSeries, experimentalSeries];

    return LineChartData(
      minX: 0,
      maxX: data.length + 1.0,
      minY: minY - padding,
      maxY: maxY + padding,
      lineBarsData: allSeries,
      titlesData: _buildTitlesData(data),
      borderData: FlBorderData(show: true),
      lineTouchData: _buildTouchData(data, predictionSeries, experimentalSeries),
    );
  }

  FlTitlesData _buildTitlesData(List<(ActiveLearningResult, double, double)> data) {
    return FlTitlesData(
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(sideTitles: SideTitles(reservedSize: 40)),
      leftTitles: AxisTitles(
        axisNameWidget: Align(
          alignment: Alignment.bottomCenter,
          child: Text(yLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) => Text(
            value.toStringAsFixed(Constants.maxDoublePrecision),
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 80,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 1 || index > data.length) return const SizedBox.shrink();
            return RotatedBox(
              quarterTurns: 3,
              child: Text(
                data[index - 1].$1.entityId,
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }

  LineTouchData _buildTouchData(
    List<(ActiveLearningResult, double, double)> data,
    LineChartBarData predictionSeries,
    LineChartBarData experimentalSeries,
  ) {
    return LineTouchData(
      getTouchedSpotIndicator: (barData, spotIndexes) {
        if (barData == predictionSeries || barData == experimentalSeries) {
          return spotIndexes.map((_) => const TouchedSpotIndicatorData(
            FlLine(color: BiocentralStyle.alConnectorLineColor),
            FlDotData(show: false),
          ),).toList();
        }
        // Hide indicators on connector segments
        return spotIndexes.map((_) => null).toList();
      },
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => BiocentralStyle.alTooltipBackground,
        getTooltipItems: (spots) {
          return spots.map((spot) {
            // connectors occupy barIndex 0..data.length-1; prediction is at data.length
            if (spot.barIndex != data.length) return null;
            final index = spot.x.toInt() - 1;
            if (index < 0 || index >= data.length) return null;
            final (result, prediction, experimental) = data[index];
            final delta = experimental - prediction;
            final sign = delta >= 0 ? '+' : '';
            return LineTooltipItem(
              '${result.entityId}\n'
              'Prediction: ${prediction.toStringAsFixed(Constants.maxDoublePrecision)}\n'
              'Experiment: ${experimental.toStringAsFixed(Constants.maxDoublePrecision)}\n'
              'Δ: $sign${delta.toStringAsFixed(Constants.maxDoublePrecision)}',
              const TextStyle(color: BiocentralStyle.alTooltipTextColor, fontSize: 10),
            );
          }).toList();
        },
      ),
    );
  }
}
