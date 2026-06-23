import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/sdk/util/constants.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Line chart showing how the average absolute prediction error (MAE) evolves
/// across iterations for the selected campaign.
/// Returns [SizedBox.shrink] when no iteration has experimental data to compare.
class ALPredictionErrorTrendView extends StatelessWidget {
  static const Color _plotColor = Colors.pink;

  final ALCampaign campaign;

  const ALPredictionErrorTrendView({required this.campaign, super.key});

  /// Computes per-iteration MAE using only suggested proteins that have
  /// both a numeric prediction and an experimental value in [proteinDatabase].
  List<(int iteration, double mae)> _computeErrorsPerIteration(Map<String, Protein> proteinDatabase) {
    final points = <(int, double)>[];
    for (final (_, iterResult) in campaign.iterationResults) {
      final mae = _computeMAE(iterResult, proteinDatabase);
      if (mae != null) {
        points.add((iterResult.iteration, mae));
      }
    }
    return points;
  }

  double? _computeMAE(ActiveLearningIterationResult iterResult, Map<String, Protein> proteinDatabase) {
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
    if (errors.isEmpty) return null;
    return errors.reduce((a, b) => a + b) / errors.length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ALHubBloc, ALHubState>(
      buildWhen: (previous, current) => previous.proteinDatabase != current.proteinDatabase,
      builder: (context, state) {
        final points = _computeErrorsPerIteration(state.proteinDatabase);
        if (points.isEmpty) return const SizedBox.shrink();
        return ExpansionTile(
          title: const Text('Prediction Error Trend'),
          leading: const Icon(Icons.show_chart),
          children: [
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 32, 16),
                child: LineChart(_buildChartData(points)),
              ),
            ),
          ],
        );
      },
    );
  }

  LineChartData _buildChartData(List<(int, double)> points) {
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    for (final (_, mae) in points) {
      if (mae < minY) minY = mae;
      if (mae > maxY) maxY = mae;
    }
    final range = maxY - minY;
    final yPadding = range == 0 ? 1.0 : range * 0.2;

    final spots = points.map((p) => FlSpot(p.$1.toDouble(), p.$2)).toList();

    final series = LineChartBarData(
      spots: spots,
      isCurved: points.length > 2,
      color: _plotColor,
      dotData: FlDotData(
        getDotPainter: (_, __, ___, ____) =>
            FlDotCirclePainter(radius: 5, color: _plotColor),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: _plotColor.withAlpha(30),
      ),
    );

    return LineChartData(
      minY: minY - yPadding,
      maxY: maxY + yPadding,
      lineBarsData: [series],
      titlesData: _buildTitlesData(points),
      borderData: FlBorderData(show: true),
      lineTouchData: _buildTouchData(),
    );
  }

  FlTitlesData _buildTitlesData(List<(int, double)> points) {
    final iterationNumbers = points.map((p) => p.$1).toSet();
    return FlTitlesData(
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        axisNameWidget: const Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            'MAE',
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
            if (!iterationNumbers.contains(iter)) return const SizedBox.shrink();
            return Text('$iter', style: const TextStyle(fontSize: 11));
          },
        ),
      ),
    );
  }

  LineTouchData _buildTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (spots) => spots.map((spot) {
          return LineTooltipItem(
            'Iteration ${spot.x.toInt()}\n'
            'MAE: ${spot.y.toStringAsFixed(Constants.maxDoublePrecision)}',
            const TextStyle(color: Colors.white, fontSize: 10),
          );
        }).toList(),
      ),
    );
  }
}
