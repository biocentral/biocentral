import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/presentation/style/biocentral_style.dart';
import 'package:biocentral/sdk/util/constants.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

/// A widget that displays a scatter plot visualization of Active Learning results.
/// The plot shows protein sequences on the x-axis and their corresponding scores on the y-axis.
/// Points are color-coded based on their score values, with a gradient legend showing the score range.
/// Supports single-iteration and combined multi-iteration modes.
class ALPlotView extends StatelessWidget {
  final String yLabel;

  /// The training results data to be displayed
  final ActiveLearningIterationResult? data;
  final List<ActiveLearningIterationResult>? allData;

  /// Suggested graph export finelname
  final String? fileNamePrefix;

  final List<ActiveLearningResult> _suggestedResults;
  final List<(int iteration, List<ActiveLearningResult> results)> _iterationData;

  /// Cached min/max values for the y-axis range
  final MinMaxValues minMaxValues;

  final WidgetsToImageController _exportController = WidgetsToImageController();

  ALPlotView({
    required this.yLabel,
    this.data,
    this.allData,
    this.fileNamePrefix,
    super.key,
  }) : assert(data != null || allData != null, 'Either data or allData must be provided'),
        _suggestedResults = allData == null ? _buildSuggestedResults(data) : const [],
        _iterationData = allData != null ? _groupByIteration(allData) : const [],
        minMaxValues = allData != null ? _calculateMinMax(_groupByIteration(allData).expand((e) => e.$2).toList(),) : _calculateMinMax(_buildSuggestedResults(data));

  static List<ActiveLearningResult> _buildSuggestedResults(ActiveLearningIterationResult? data) {
    if (data == null) return [];
    final suggestionSet = data.suggestions.toSet();
    return data.results.where((r) => suggestionSet.contains(r.entityId)).toList();
  }

  static List<(int, List<ActiveLearningResult>)> _groupByIteration(List<ActiveLearningIterationResult> allData) {
    return allData.map((r) {
      final s = r.suggestions.toSet();
      return (r.iteration, r.results.where((res) => s.contains(res.entityId)).toList());
    }).toList();
  }

  /// Gets the x-axis label from the training config
  String get xLabel => 'Result plot for iteration: ${data?.iteration}';

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
    if (allData != null) {
      return _ALCombinedPlotView(
        yLabel: yLabel,
        iterationData: _iterationData,
        minMaxValues: minMaxValues,
        fileNamePrefix: fileNamePrefix,
      );
    }
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
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
                  defaultFileName: 'al_scatter_${fileNamePrefix ?? 'plot'}_iteration_${data?.iteration}.png',
                ),
              ),
            ],
          ),
          Expanded(
            child: WidgetsToImage(
              controller: _exportController,
              child: Container( // used to color background of screenshot the same as application
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildScatterPlot(),
                      _buildColorLegend(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                colors: BiocentralStyle.alScoreGradientColors,
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
        getTooltipColor: (_) => BiocentralStyle.alTooltipBackground,
        getTooltipItems: (ScatterSpot touchedSpot) {
          return ScatterTooltipItem(
            '${_suggestedResults[touchedSpot.x.toInt() - 1].entityId}\n '
            'Score: ${touchedSpot.y.toStringAsFixed(Constants.maxDoublePrecision)}',
            textStyle: const TextStyle(color: BiocentralStyle.alTooltipTextColor, fontSize: 10),
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
      final double scoreRatio = maxScore == minScore ? 0.5 : (result.score - minScore) / (maxScore - minScore);
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
    if (ratio <= 0.2) return BiocentralStyle.alScoreGradientColors[0];
    if (ratio <= 0.4) return BiocentralStyle.alScoreGradientColors[1];
    if (ratio <= 0.6) return BiocentralStyle.alScoreGradientColors[2];
    if (ratio <= 0.8) return BiocentralStyle.alScoreGradientColors[3];
    return BiocentralStyle.alScoreGradientColors[4];
  }
}

class _ALCombinedPlotView extends StatelessWidget {
  final String yLabel;
  final String? fileNamePrefix;
  final List<(int iteration, List<ActiveLearningResult> results)> iterationData;
  final MinMaxValues minMaxValues;

  final WidgetsToImageController _exportController = WidgetsToImageController();

  _ALCombinedPlotView({
    required this.yLabel,
    required this.iterationData,
    required this.minMaxValues,
    this.fileNamePrefix,
  });

  @override
  Widget build(BuildContext context) {
    final allResults = iterationData.expand((e) => e.$2).toList();
    if (allResults.isEmpty) return const SizedBox.shrink();

    final List<(int iteration, String entityId, double score)> spotInfo = [];
    final List<ScatterSpot> spots = [];

    double counterX = 1.0;
    for (final (iteration, results) in iterationData) {
      final color = BiocentralStyle.alIterationColors[iteration % BiocentralStyle.alIterationColors.length];
      for (final result in results) {
        spotInfo.add((iteration, result.entityId, result.score.toDouble()));
        spots.add(ScatterSpot(
          counterX++,
          result.score.toDouble(),
          show: true,
          dotPainter: FlDotCirclePainter(radius: 8, color: color),
        ),);
      }
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
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
                  defaultFileName: 'al_scatter_${fileNamePrefix ?? 'plot'}_all_iterations.png',
                ),
              ),
            ],
          ),
          Expanded(
            child: WidgetsToImage(
              controller: _exportController,
              child: Container( // used to color background of screenshot the same as application
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: _buildCombinedScatterPlot(spots, spotInfo)),
                      _buildIterationLegend(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedScatterPlot(
    List<ScatterSpot> spots,
    List<(int, String, double)> spotInfo,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ScatterChart(
        ScatterChartData(
          titlesData: _buildCombinedTitlesData(spotInfo),
          gridData: const FlGridData(),
          scatterSpots: spots,
          minX: 0,
          maxX: spots.length.toDouble() + 1,
          minY: minMaxValues.getMinY,
          maxY: minMaxValues.getMaxY,
          borderData: FlBorderData(show: true),
          scatterTouchData: _buildCombinedTouchData(spotInfo),
        ),
      ),
    );
  }

  FlTitlesData _buildCombinedTitlesData(List<(int, String, double)> spotInfo) {
    return FlTitlesData(
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(
        axisNameWidget: Text(
          'All Iterations',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
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
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            final int index = value.toInt();
            if (index < 1 || index > spotInfo.length) return const SizedBox.shrink();
            return RotatedBox(
              quarterTurns: 3,
              child: Text(
                spotInfo[index - 1].$2,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }

  ScatterTouchData _buildCombinedTouchData(List<(int, String, double)> spotInfo) {
    return ScatterTouchData(
      touchTooltipData: ScatterTouchTooltipData(
        getTooltipColor: (_) => BiocentralStyle.alTooltipBackground,
        getTooltipItems: (ScatterSpot touchedSpot) {
          final index = touchedSpot.x.toInt() - 1;
          if (index < 0 || index >= spotInfo.length) return null;
          final (iteration, entityId, score) = spotInfo[index];
          return ScatterTooltipItem(
            'Iteration $iteration\n$entityId\nScore: ${score.toStringAsFixed(Constants.maxDoublePrecision)}',
            textStyle: const TextStyle(color: BiocentralStyle.alTooltipTextColor, fontSize: 10),
          );
        },
      ),
      enabled: true,
    );
  }

  Widget _buildIterationLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      width: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: iterationData.map((entry) {
          final (iteration, _) = entry;
          final color = BiocentralStyle.alIterationColors[iteration % BiocentralStyle.alIterationColors.length];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: 8),
                Text('Iteration $iteration', style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
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

  double get getMinY {
    if (minY == maxY) return minY - 1;
    return minY - (maxY - minY) * 0.1;
  }

  double get getMaxY {
    if (minY == maxY) return maxY + 1;
    return maxY + (maxY - minY) * 0.1;
  }
}
