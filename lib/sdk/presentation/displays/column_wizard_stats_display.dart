import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../model/column_wizard_abstract.dart';
import '../../util/constants.dart';
import '../../util/size_config.dart';

class ColumnWizardStatsDisplay extends StatefulWidget {
  final ColumnWizard columnWizard;

  const ColumnWizardStatsDisplay({super.key, required this.columnWizard});

  @override
  State<StatefulWidget> createState() => _ColumnWizardStatsDisplayState();
}

class _ColumnWizardStatsDisplayState extends State<ColumnWizardStatsDisplay> {
  late Future<bool> handleAsDiscrete;

  @override
  void initState() {
    super.initState();
    handleAsDiscrete = widget.columnWizard.handleAsDiscrete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<bool>(
                future: handleAsDiscrete,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data != null && snapshot.data == true) {
                      return descriptiveStatisticsCounterStats();
                    } else {
                      return descriptiveStatisticsNumericStats();
                    }
                  }
                  return const CircularProgressIndicator();
                }),
            SizedBox(
              width: SizeConfig.safeBlockHorizontal(context) * 5,
            ),
            barDistributionPlot(),
          ],
        ),
      ],
    );
  }

  Widget descriptiveStatisticsNumericStats() {
    NumericStats columnWizard = widget.columnWizard as NumericStats;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Text("Descriptive Statistics"),
      textFuture("Number values:", columnWizard.length()),
      textFuture("Number missing values:", columnWizard.numberMissing()),
      textFuture("Max:", columnWizard.max()),
      textFuture("Min:", columnWizard.min()),
      textFuture("Mean:", columnWizard.mean()),
      textFuture("Median:", columnWizard.medianArray()),
      textFuture("Mode:", columnWizard.modeArray()),
      textFuture("Standard deviation:", columnWizard.stdDev()),
    ]);
  }

  Widget descriptiveStatisticsCounterStats() {
    CounterStats columnWizard = widget.columnWizard as CounterStats;
    return FutureBuilder<Map<String, int>>(
        future: columnWizard.getCounts(), // Cached
        builder: (context, snapshot) {
          List<Widget> classCounts = [];
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            classCounts.add(const Text("Class counts:"));
            classCounts.addAll(snapshot.data!.entries
                .sorted((e1, e2) => e1.value.compareTo(e2.value))
                .reversed
                .map((entry) => Text("${entry.key}: ${entry.value}")));
          }
          return Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Descriptive Statistics"),
            textFuture("Number values:", columnWizard.length()),
            textFuture("Number missing values:", columnWizard.numberMissing()),
            ...classCounts,
          ]);
        });
  }

  Widget textFuture(String text, Future<num> future) {
    return FutureBuilder<num>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            String valueString = "";
            if (snapshot.data.runtimeType == int) {
              valueString = snapshot.data.toString();
            } else {
              valueString = snapshot.data?.toStringAsPrecision(Constants.maxDoublePrecision) ?? "";
            }
            return Row(
              children: [
                Text("$text "),
                Text(valueString),
              ],
            );
          }
          return Row(children: [Text("$text "), const CircularProgressIndicator()]);
        });
  }

  Widget barDistributionPlot() {
    return Flexible(
      fit: FlexFit.loose,
      child: FutureBuilder<ColumnWizardBarChartData>(
        future: widget.columnWizard.getBarChartData(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            ColumnWizardBarChartData barChartData = snapshot.data!;
            return SizedBox(
              width: 200,
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: barChartData.maxY,
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, titleMeta) =>
                            bottomTitles(value, titleMeta, barChartData.bottomTitles),
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, titleMeta) =>
                            leftTitles(value, titleMeta, barChartData.leftTitleValues),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: getBarChartData(barChartData.dataPoints),
                  gridData: const FlGridData(show: true),
                ),
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta, List<double> titleValues) {
    if (titleValues.contains(value)) {
      final Widget text = Text(
        value.toInt().toString(),
        style: const TextStyle(
          color: Color(0xff7589a2),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 0,
        child: text,
      );
    }
    return Container();
  }

  Widget bottomTitles(double value, TitleMeta meta, List<String> titles) {
    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      angle: 45,
      child: text,
    );
  }

  List<BarChartGroupData> getBarChartData(List<(int, double)> dataPoints) {
    List<BarChartGroupData> result = [];

    for ((int, double) dataPoint in dataPoints) {
      result.add(BarChartGroupData(x: dataPoint.$1, barRods: [BarChartRodData(toY: dataPoint.$2, color: Colors.red)]));
    }
    return result;
  }
}
