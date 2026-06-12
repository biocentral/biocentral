import 'package:biocentral/sdk/util/constants.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A widget that displays a scatter plot visualization of Active Learning results.
/// The plot shows protein sequences on the x-axis and their corresponding scores on the y-axis.
/// Points are color-coded based on their score values, with a gradient legend showing the score range.
class ALPlotView extends StatelessWidget {
  /// Label for the y-axis (typically representing the score metric)
  final String yLabel;

  /// The training results data to be displayed
  final ActiveLearningIterationResult? data;

  /// Cached min/max values for the y-axis range
  final MinMaxValues minMaxValues;

  ALPlotView({
    required this.yLabel,
    this.data,
    super.key,
  }) : _suggestedResults = _buildSuggestedResults(data),
       minMaxValues = _calculateMinMax(_buildSuggestedResults(data));

  final List<ActiveLearningResult> _suggestedResults;

  static List<ActiveLearningResult> _buildSuggestedResults(ActiveLearningIterationResult? data) {
    if (data == null) return [];
    final suggestionSet = data.suggestions.toSet();
    return data.results.where((r) => suggestionSet.contains(r.entityId)).toList();
  }

  /// Gets the x-axis label from the training config
  String get xLabel {
    return 'Result plot for iteration: ${data?.iteration}';
  }

  /// Calculates the minimum and maximum values for the y-axis
  /// Adds a 10% padding to both ends of the range
  static MinMaxValues _calculateMinMax(List<ActiveLearningResult>? plotData) {
    if (plotData == null || plotData.isEmpty) {
      return MinMaxValues(minY: 0, maxY: 0);
    }

    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var data in plotData) {
      if (data.score < minY) minY = data.score.toDouble();
      if (data.score > maxY) maxY = data.score.toDouble();
    }

    return MinMaxValues(minY: minY, maxY: maxY);
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
            scatterSpots: getData(_suggestedResults),
            minX: 0,
            maxX: _suggestedResults.length.toDouble() + 1,
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
                minMaxValues.maxY.toStringAsFixed(Constants.maxDoublePrecision),
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                (minMaxValues.maxY - (minMaxValues.maxY - minMaxValues.minY) / 2)
                    .toStringAsFixed(Constants.maxDoublePrecision),
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                minMaxValues.minY.toStringAsFixed(Constants.maxDoublePrecision),
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
              value.toStringAsFixed(Constants.maxDoublePrecision),
              style: const TextStyle(fontSize: 12),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            final int index = value.toInt();
            if (index < 1 || index > _suggestedResults.length) {
              return const SizedBox.shrink();
            }
            return RotatedBox(
              quarterTurns: 3,
              child: Text(
                _suggestedResults[index - 1].entityId,
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
            '${_suggestedResults[touchedSpot.x.toInt() - 1].entityId}\n '
            'Score: ${touchedSpot.y.toStringAsFixed(Constants.maxDoublePrecision)}',
            textStyle: const TextStyle(color: Colors.white, fontSize: 10),
          );
        },
      ),
      enabled: true,
    );
  }

  /// Converts the training results into scatter plot data points
  List<ScatterSpot> getData(List<ActiveLearningResult> results) {
    final List<ScatterSpot> scatterSpots = [];
    final (minScore, maxScore) = _calculateScoreRange(results);

    double counterX = 1;
    for (var result in results) {
      final double scoreRatio = (result.score - minScore) / (maxScore - minScore);
      final Color pointColor = getColorBasedOnScore(scoreRatio);

      scatterSpots.add(
        ScatterSpot(
          counterX++,
          result.score.toDouble(),
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
  (double, double) _calculateScoreRange(List<ActiveLearningResult> results) {
    double minScore = double.infinity;
    double maxScore = double.negativeInfinity;

    for (var result in results) {
      if (result.score < minScore) minScore = result.score.toDouble();
      if (result.score > maxScore) maxScore = result.score.toDouble();
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
