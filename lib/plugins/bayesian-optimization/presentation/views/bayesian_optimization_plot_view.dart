import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BayesianOptimizationPlotView extends StatelessWidget {
  String yLabel;
  String xLabel;
  BayesianOptimizationTrainingResult? data;

  BayesianOptimizationPlotView({
    required this.yLabel,
    required this.xLabel,
    this.data,
    super.key,
  }) {
    data = data ?? dummyData;
  }

  late MinMaxValues minMaxValues;

  @override
  Widget build(BuildContext context) {
    minMaxValues = minMax(data!.results);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ScatterChart(
                  ScatterChartData(
                    titlesData: FlTitlesData(
                      rightTitles: AxisTitles(
                        axisNameWidget: Text(yLabel),
                      ),
                      topTitles: AxisTitles(
                        axisNameWidget: Text(xLabel),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(),
                    scatterSpots: getData(data!),
                    minX: minMaxValues.getMinX,
                    maxX: minMaxValues.getMaxX,
                    minY: minMaxValues.getMinY,
                    maxY: minMaxValues.getMaxY,
                    borderData: FlBorderData(show: true),
                    scatterTouchData: ScatterTouchData(
                      touchTooltipData: ScatterTouchTooltipData(
                        getTooltipItems: (ScatterSpot touchedSpot) {
                          return ScatterTooltipItem(
                            'x:${touchedSpot.x}, y:${touchedSpot.y}',
                            textStyle: const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                      enabled: true,
                    ),
                  ),
                ),
              ),
            ),

            // Color Legend Bar
            Container(
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
                          Colors.blue, // Low utility
                          Colors.purple,
                          Colors.red,
                          Colors.orange,
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
                        minMaxValues.maxY.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        ((minMaxValues.maxY - minMaxValues.minY) / 2).toStringAsFixed(2),
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        minMaxValues.minY.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Dummy list of PlotData
  final BayesianOptimizationTrainingResult dummyData = const BayesianOptimizationTrainingResult(
    results: [
      BayesianOptimizationTrainingResultData(proteinId: '1', prediction: 32, uncertainty: -1.4, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '2', prediction: 35, uncertainty: -1.0, utility: -1.2),
      BayesianOptimizationTrainingResultData(proteinId: '3', prediction: 37, uncertainty: -0.8, utility: -0.5),
      BayesianOptimizationTrainingResultData(proteinId: '4', prediction: 40, uncertainty: -0.5, utility: -0.2),
      BayesianOptimizationTrainingResultData(proteinId: '5', prediction: 42, uncertainty: -0.2, utility: 0.0),
      BayesianOptimizationTrainingResultData(proteinId: '6', prediction: 45, uncertainty: 0.0, utility: 0.2),
      BayesianOptimizationTrainingResultData(proteinId: '7', prediction: 47, uncertainty: 0.2, utility: 0.5),
      BayesianOptimizationTrainingResultData(proteinId: '8', prediction: 50, uncertainty: 0.5, utility: 0.8),
      BayesianOptimizationTrainingResultData(proteinId: '9', prediction: 52, uncertainty: 0.8, utility: 1.0),
      BayesianOptimizationTrainingResultData(proteinId: '10', prediction: 55, uncertainty: 1.0, utility: 1.5),
      BayesianOptimizationTrainingResultData(proteinId: '11', prediction: 32, uncertainty: -1.5, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '12', prediction: 35, uncertainty: -1.1, utility: -1.2),
      BayesianOptimizationTrainingResultData(proteinId: '13', prediction: 37, uncertainty: -0.1, utility: -0.5),
      BayesianOptimizationTrainingResultData(proteinId: '14', prediction: 40, uncertainty: -0.2, utility: -0.2),
      BayesianOptimizationTrainingResultData(proteinId: '15', prediction: 42, uncertainty: -0.5, utility: 1.0),
      BayesianOptimizationTrainingResultData(proteinId: '16', prediction: 45, uncertainty: 0.5, utility: 1.2),
      BayesianOptimizationTrainingResultData(proteinId: '17', prediction: 47, uncertainty: 0.6, utility: -1.5),
      BayesianOptimizationTrainingResultData(proteinId: '18', prediction: 50, uncertainty: 0.1, utility: 0.8),
    ],
  );

  List<ScatterSpot> getData(BayesianOptimizationTrainingResult plotData) {
    final List<ScatterSpot> scatterSpots = [];

    // Map the dummyData to ScatterSpot
    for (var data in plotData.results!) {
      final Color pointColor = getColorBasedOnUtility(data.utility!);

      scatterSpots.add(
        ScatterSpot(
          data.prediction!,
          data.uncertainty!,
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

// Function to assign colors based on utility value
  Color getColorBasedOnUtility(double utility) {
    if (utility <= -1.0) {
      return Colors.blue; // Low utility
    } else if (utility <= 0.0) {
      return Colors.purple;
    } else if (utility <= 0.5) {
      return Colors.red;
    } else if (utility <= 1.0) {
      return Colors.orange;
    } else {
      return Colors.yellow; // High utility
    }
  }

  MinMaxValues minMax(List<BayesianOptimizationTrainingResultData>? plotData) {
    double minX = 99999;
    double minY = 99999;
    double maxX = -99999;
    double maxY = -99999;

    for (var data in plotData!) {
      if (data.prediction! < minX) {
        minX = data.prediction!;
      }
      if (data.uncertainty! < minY) {
        minY = data.uncertainty!;
      }
      if (data.prediction! > maxX) {
        maxX = data.prediction!;
      }
      if (data.uncertainty! > maxY) {
        maxY = data.uncertainty!;
      }
    }

    return MinMaxValues(minX: minX, minY: minY, maxX: maxX, maxY: maxY);
  }
}

class MinMaxValues {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  MinMaxValues({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  double get getMinX => minX - 1;
  double get getMinY => minY - 1;
  double get getMaxX => maxX + 1;
  double get getMaxY => maxY + 1;
}
