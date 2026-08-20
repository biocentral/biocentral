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

/// Candlestick chart showing the distribution of absolute prediction errors per
/// iteration. Each candle maps: low=min, open=Q1, close=Q3, high=max.
/// Hides itself when no iteration has experimental data to compare.
class ALPredictionErrorTrendView extends StatelessWidget {
  static const Color _bodyColor = BiocentralStyle.alPredictionErrorBodyColor;

  final ALCampaign campaign;

  final WidgetsToImageController _exportController = WidgetsToImageController();

  ALPredictionErrorTrendView({required this.campaign, super.key});

  /// Returns sorted absolute errors for all suggested proteins in [iterResult]
  /// that have both a numeric prediction and an experimental value.
  List<double> _errorsForIteration(
    ActiveLearningIterationResult iterResult,
    Map<String, Protein> proteinDatabase,
  ) {
    final suggestionSet = iterResult.suggestions.toSet();
    final errors = <double>[];
    for (final result in iterResult.results) {
      if (!suggestionSet.contains(result.entityId)) continue;
      final prediction = double.tryParse(result.prediction);
      if (prediction == null) continue;
      final rawExp = proteinDatabase[result.entityId]?.attributes[campaign.columnName];
      final experimental = double.tryParse(rawExp?.toString() ?? '');
      if (experimental == null) continue;
      errors.add((experimental - prediction).abs());
    }
    errors.sort();
    return errors;
  }

  double _quartile(List<double> sorted, double q) {
    final pos = (sorted.length - 1) * q;
    final lower = pos.floor();
    final upper = pos.ceil();
    if (lower == upper) return sorted[lower];
    return sorted[lower] + (sorted[upper] - sorted[lower]) * (pos - lower);
  }

  /// Builds one record per iteration: (iteration, min, q1, q3, max, mean).
  List<({int iteration, double min, double q1, double q3, double max, double mean})> _computeStats(
      Map<String, Protein> proteinDatabase) {
    final result = <({int iteration, double min, double q1, double q3, double max, double mean})>[];
    for (final (_, iterResult) in campaign.iterationResults) {
      final errors = _errorsForIteration(iterResult, proteinDatabase);
      if (errors.isEmpty) continue;
      result.add(
        (
          iteration: iterResult.iteration,
          min: errors.first,
          q1: _quartile(errors, 0.25),
          q3: _quartile(errors, 0.75),
          max: errors.last,
          mean: errors.reduce((a, b) => a + b) / errors.length,
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ALHubBloc, ALHubState>(
      buildWhen: (previous, current) =>
          previous.proteinDatabase != current.proteinDatabase || previous.selectedCampaign != current.selectedCampaign,
      builder: (context, state) {
        final stats = _computeStats(state.proteinDatabase);
        if (stats.isEmpty) return const SizedBox.shrink();
        return ExpansionTile(
          title: const Text('Prediction Error Distribution'),
          leading: const Icon(Icons.candlestick_chart),
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
                    defaultFileName: 'al_prediction_error_trend_${campaign.config.name}.png',
                  ),
                ),
              ],
            ),
            WidgetsToImage(
              controller: _exportController,
              child: Container(
                // used to color background of screenshot the same as application
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SizedBox(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 32, 16),
                    child: CandlestickChart(_buildChartData(stats)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  CandlestickChartData _buildChartData(
    List<({int iteration, double min, double q1, double q3, double max, double mean})> stats,
  ) {
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    for (final s in stats) {
      if (s.min < minY) minY = s.min;
      if (s.max > maxY) maxY = s.max;
    }
    final range = maxY - minY;
    final yPadding = range == 0 ? 1.0 : range * 0.2;

    final spots = stats
        .map(
          (s) => CandlestickSpot(
            x: s.iteration.toDouble(),
            open: s.q1,
            high: s.max,
            low: s.min,
            close: s.q3,
          ),
        )
        .toList();

    return CandlestickChartData(
      candlestickSpots: spots,
      minX: stats.first.iteration.toDouble() - 1.0,
      maxX: stats.last.iteration.toDouble() + 1.0,
      candlestickPainter: DefaultCandlestickPainter(
        candlestickStyleProvider: (spot, _) => const CandlestickStyle(
          lineColor: _bodyColor,
          lineWidth: 1.5,
          bodyStrokeColor: _bodyColor,
          bodyStrokeWidth: 0,
          bodyFillColor: _bodyColor,
          bodyWidth: 16,
          bodyRadius: 2,
        ),
      ),
      minY: minY - yPadding,
      maxY: maxY + yPadding,
      borderData: FlBorderData(show: true),
      titlesData: _buildTitlesData(stats),
      candlestickTouchData: _buildTouchData(stats),
    );
  }

  FlTitlesData _buildTitlesData(
    List<({int iteration, double min, double q1, double q3, double max, double mean})> stats,
  ) {
    final iterNums = stats.map((s) => s.iteration).toSet();
    return FlTitlesData(
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        axisNameWidget: const Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            'Absolute Error',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 56,
          getTitlesWidget: (value, meta) => Text(
            value.toStringAsFixed(Constants.maxDoublePrecision),
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        axisNameWidget: const Text(
          'Iteration',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            final iter = value.toInt();
            if (!iterNums.contains(iter)) return const SizedBox.shrink();
            return Text('$iter', style: const TextStyle(fontSize: 11));
          },
        ),
      ),
    );
  }

  CandlestickTouchData _buildTouchData(
    List<({int iteration, double min, double q1, double q3, double max, double mean})> stats,
  ) {
    return CandlestickTouchData(
      touchTooltipData: CandlestickTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        maxContentWidth: 180,
        getTooltipColor: (_) => BiocentralStyle.alTooltipBackground,
        getTooltipItems: (painter, spot, spotIndex) {
          if (spotIndex < 0 || spotIndex >= stats.length) return null;
          final s = stats[spotIndex];
          String fmt(double v) => v.toStringAsFixed(Constants.maxDoublePrecision);
          const style = TextStyle(color: BiocentralStyle.alTooltipTextColor, fontSize: 11);
          return CandlestickTooltipItem(
            'Iteration ${s.iteration}\n',
            textStyle: style,
            children: [
              TextSpan(text: 'MAE: ${fmt(s.mean)}\n', style: style),
              TextSpan(text: 'Min: ${fmt(s.min)}\n', style: style),
              TextSpan(text: 'Q1:  ${fmt(s.q1)}\n', style: style),
              TextSpan(text: 'Q3:  ${fmt(s.q3)}\n', style: style),
              TextSpan(text: 'Max: ${fmt(s.max)}', style: style),
            ],
          );
        },
      ),
    );
  }
}
