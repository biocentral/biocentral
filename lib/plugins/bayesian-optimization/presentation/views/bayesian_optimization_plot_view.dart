import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A widget that displays a scatter plot visualization of Bayesian optimization results.
/// The plot shows protein sequences on the x-axis and their corresponding scores on the y-axis.
/// Points are color-coded based on their score values, with a gradient legend showing the score range.
class BayesianOptimizationPlotView extends StatelessWidget {
  /// Label for the y-axis (typically representing the score metric)
  final String yLabel;

  /// The training results data to be displayed
  final BayesianOptimizationTrainingResult? data;

  /// Cached min/max values for the y-axis range
  final MinMaxValues minMaxValues;

  BayesianOptimizationPlotView({
    required this.yLabel,
    this.data,
    super.key,
  }) : minMaxValues = _calculateMinMax(data?.results);

  /// Gets the x-axis label from the training config
  String get xLabel {
    final feature = data?.trainingConfig?['feature_name'] as String? ?? 'Feature';
    final embedder = data?.trainingConfig?['embedder_name'] as String? ?? 'Embedder';
    return '$feature - $embedder';
  }

  /// Calculates the minimum and maximum values for the y-axis
  /// Adds a 10% padding to both ends of the range
  static MinMaxValues _calculateMinMax(List<BayesianOptimizationTrainingResultData>? plotData) {
    if (plotData == null || plotData.isEmpty) {
      return MinMaxValues(minY: 0, maxY: 0);
    }

    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var data in plotData) {
      if (data.score! < minY) minY = data.score!;
      if (data.score! > maxY) maxY = data.score!;
    }

    return MinMaxValues(minY: minY, maxY: maxY);
  }

  /// Formats a number to a maximum of 5 decimal places, removing trailing zeros.
  String formatNumber(double value) {
    return double.parse(value.toStringAsFixed(5)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildScatterPlot(),
            _buildColorLegend(),
          ],
        ),
      ),
    );
  }

  /// Builds the main scatter plot visualization
  Widget _buildScatterPlot() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ScatterChart(
          ScatterChartData(
            titlesData: _buildTitlesData(),
            gridData: const FlGridData(),
            scatterSpots: getData(data!),
            minX: 0,
            maxX: data!.results!.length.toDouble() + 1,
            minY: minMaxValues.getMinY,
            maxY: minMaxValues.getMaxY,
            borderData: FlBorderData(show: true),
            scatterTouchData: _buildTouchData(),
          ),
        ),
      ),
    );
  }

  /// Builds the color legend showing the score range
  Widget _buildColorLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64),
      width: 100,
      child: Row(
        children: [
          Container(
            width: 20,
            decoration: BoxDecoration(
              border: Border.all(),
              gradient: const LinearGradient(
                colors: [
                  Colors.blue, // Low score
                  Colors.purple,
                  Colors.red,
                  Colors.orange,
                  Colors.yellow, // High score
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatNumber(minMaxValues.maxY),
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                formatNumber(minMaxValues.maxY - (minMaxValues.maxY - minMaxValues.minY) / 2),
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                formatNumber(minMaxValues.minY),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the chart titles and axis labels
  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      rightTitles: AxisTitles(
        axisNameWidget: Text(
          yLabel,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      topTitles: AxisTitles(
        axisNameWidget: Text(
          xLabel,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            return Text(
              formatNumber(value),
              style: const TextStyle(fontSize: 12),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            final int index = value.toInt();
            return RotatedBox(
              quarterTurns: 3,
              child: Text(
                index == 0 || index > data!.results!.length ? value.toString() : data!.results![index - 1].proteinId!,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the touch interaction data for the scatter plot
  ScatterTouchData _buildTouchData() {
    return ScatterTouchData(
      touchTooltipData: ScatterTouchTooltipData(
        getTooltipItems: (ScatterSpot touchedSpot) {
          return ScatterTooltipItem(
            '${data!.results![touchedSpot.x.toInt() - 1].proteinId}\n Score: ${formatNumber(touchedSpot.y)}',
            textStyle: const TextStyle(color: Colors.white, fontSize: 10),
          );
        },
      ),
      enabled: true,
    );
  }

  /// Converts the training results into scatter plot data points
  List<ScatterSpot> getData(BayesianOptimizationTrainingResult plotData) {
    final List<ScatterSpot> scatterSpots = [];
    final (minScore, maxScore) = _calculateScoreRange(plotData);

    double counterX = 1;
    for (var data in plotData.results!) {
      final double scoreRatio = (data.score! - minScore) / (maxScore - minScore);
      final Color pointColor = getColorBasedOnScore(scoreRatio);

      scatterSpots.add(
        ScatterSpot(
          counterX++,
          data.score!,
          show: true,
          dotPainter: FlDotCirclePainter(
            radius: 8,
            color: pointColor,
          ),
        ),
      );
    }

    return scatterSpots;
  }

  /// Calculates the minimum and maximum score values from the training results
  (double, double) _calculateScoreRange(BayesianOptimizationTrainingResult plotData) {
    double minScore = double.infinity;
    double maxScore = double.negativeInfinity;

    for (var data in plotData.results!) {
      if (data.score! < minScore) minScore = data.score!;
      if (data.score! > maxScore) maxScore = data.score!;
    }

    return (minScore, maxScore);
  }

  /// Returns a color based on the score ratio (0.0 - 1.0)
  /// The color gradient goes from blue (low scores) to yellow (high scores)
  Color getColorBasedOnScore(double ratio) {
    if (ratio <= 0.2) return Colors.blue;
    if (ratio <= 0.4) return Colors.purple;
    if (ratio <= 0.6) return Colors.red;
    if (ratio <= 0.8) return Colors.orange;
    return Colors.yellow;
  }
}

/// A class to hold the minimum and maximum y-values for the scatter plot
class MinMaxValues {
  final double minY;
  final double maxY;

  MinMaxValues({
    required this.minY,
    required this.maxY,
  });

  /// Returns the minimum y-value with 10% padding
  double get getMinY => minY - (maxY - minY) * 0.1;

  /// Returns the maximum y-value with 10% padding
  double get getMaxY => maxY + (maxY - minY) * 0.1;
}
