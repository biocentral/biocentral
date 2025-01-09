import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BayesianOptimizationPlotView extends StatelessWidget {
  String yLabel;
  String xLabel;
  List<PlotData>? plotData;

  BayesianOptimizationPlotView({
    required this.yLabel,
    required this.xLabel,
    this.plotData,
    super.key,
  }) {
    plotData = plotData ?? dummyData;
  }

  late MinMaxValues minMaxValues;

  @override
  Widget build(BuildContext context) {
    minMaxValues = minMax(plotData);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              flex: 5,
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
                    scatterSpots: getData(plotData!),
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
            Expanded(
              child: Container(
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
                          '${minMaxValues.maxY}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${(minMaxValues.maxY - minMaxValues.minY) / 2}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${minMaxValues.minY}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Dummy list of PlotData
  final List<PlotData> dummyData = [
    PlotData(row: 1, x: 32, y: -1.4, utility: -1.5),
    PlotData(row: 2, x: 35, y: -1.0, utility: -1.2),
    PlotData(row: 3, x: 37, y: -0.8, utility: -0.5),
    PlotData(row: 4, x: 40, y: -0.5, utility: -0.3),
    PlotData(row: 5, x: 42, y: -0.2, utility: -0.1),
    PlotData(row: 6, x: 45, y: 0.0, utility: 0.0),
    PlotData(row: 7, x: 48, y: 0.3, utility: 0.1),
    PlotData(row: 8, x: 50, y: 0.5, utility: 0.5),
    PlotData(row: 9, x: 52, y: 0.7, utility: 0.8),
    PlotData(row: 10, x: 55, y: 0.9, utility: 1.0),
    PlotData(row: 11, x: 57, y: 0.6, utility: 0.7),
    PlotData(row: 12, x: 60, y: 0.3, utility: 0.2),
    PlotData(row: 13, x: 40, y: -1.5, utility: -1.4),
    PlotData(row: 14, x: 55, y: -0.5, utility: -0.2),
    PlotData(row: 15, x: 50, y: -1.2, utility: -1.0),
  ];

  List<ScatterSpot> getData(List<PlotData> plotData) {
    final List<ScatterSpot> scatterSpots = [];

    // Map the dummyData to ScatterSpot
    for (var data in plotData) {
      final Color pointColor = getColorBasedOnUtility(data.utility);

      scatterSpots.add(
        ScatterSpot(
          data.x,
          data.y,
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

  MinMaxValues minMax(List<PlotData>? plotData) {
    double minX = 99999;
    double minY = 99999;
    double maxX = -99999;
    double maxY = -99999;

    for (var data in plotData!) {
      if (data.x < minX) {
        minX = data.x;
      }
      if (data.y < minY) {
        minY = data.y;
      }
      if (data.x > maxX) {
        maxX = data.x;
      }
      if (data.y > maxY) {
        maxY = data.y;
      }
    }

    return MinMaxValues(minX: minX, minY: minY, maxX: maxX, maxY: maxY);
  }
}

// Define a class to hold Row, X, Y, and Utility
class PlotData {
  final int row;
  final double x;
  final double y;
  final double utility;

  PlotData({
    required this.row,
    required this.x,
    required this.y,
    required this.utility,
  });
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
