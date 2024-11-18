import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:biocentral/sdk/model/column_wizard_abstract.dart';
import 'package:biocentral/sdk/util/constants.dart';
import 'package:biocentral/sdk/util/size_config.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_bar_plot.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_histogram_kde_plot.dart';

class ColumnWizardGenericDisplay extends StatefulWidget {
  final ColumnWizard columnWizard;

  const ColumnWizardGenericDisplay({required this.columnWizard, super.key});

  @override
  State<StatefulWidget> createState() => _ColumnWizardGenericDisplayState();
}

class _ColumnWizardGenericDisplayState extends State<ColumnWizardGenericDisplay> {
  Future<bool> handleAsDiscrete = Future.value(false);

  @override
  void initState() {
    super.initState();
      handleAsDiscrete = widget.columnWizard.handleAsDiscrete();

  }

  @override
  void didUpdateWidget(ColumnWizardGenericDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columnWizard != widget.columnWizard) {
      handleAsDiscrete = widget.columnWizard.handleAsDiscrete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: handleAsDiscrete,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data == true) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                descriptiveStatisticsCounterStats(),
                SizedBox(
                  width: SizeConfig.safeBlockHorizontal(context) * 5,
                ),
                barDistributionPlot(),
              ],
            );
          } else {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                descriptiveStatisticsNumericStats(),
                SizedBox(
                  width: SizeConfig.safeBlockHorizontal(context) * 5,
                ),
                Builder(builder: (context) {
                  final data = (widget.columnWizard as NumericStats).numericValues.toList();
                  return SizedBox(
                    width: SizeConfig.screenWidth(context) * 0.4,
                    height: SizeConfig.screenHeight(context) * 0.3,
                    child: BiocentralHistogramKDEPlot(data: data),);
                },),
                //List.generate(1000, (_) => math.Random().nextDouble() * 100))),
              ],
            );
          }
        }
        return const CircularProgressIndicator();
      },);
  }

  Widget descriptiveStatisticsNumericStats() {
    final NumericStats columnWizard = widget.columnWizard as NumericStats;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Descriptive Statistics:\n'),
      textFuture('Number values:', columnWizard.length()),
      textFuture('Number missing values:', columnWizard.numberMissing()),
      textFuture('Max:', columnWizard.max()),
      textFuture('Min:', columnWizard.min()),
      textFuture('Mean:', columnWizard.mean()),
      textFuture('Median:', columnWizard.median()),
      textFuture('Mode:', columnWizard.mode()),
      textFuture('Standard deviation:', columnWizard.stdDev()),
    ],);
  }

  Widget descriptiveStatisticsCounterStats() {
    final CounterStats columnWizard = widget.columnWizard as CounterStats;
    return FutureBuilder<Map<String, int>>(
      future: columnWizard.getCounts(), // Cached
      builder: (context, snapshot) {
        final List<Widget> classCounts = [];
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
          classCounts.add(const Text('Class counts:'));
          classCounts.addAll(snapshot.data!
              .entries
              .sorted((e1, e2) => e1.value.compareTo(e2.value))
              .reversed
              .map((entry) => Text('${entry.key}: ${entry.value}')),);
        }
        return Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Descriptive Statistics:\n'),
          textFuture('Number values:', columnWizard.length()),
          textFuture('Number different classes:', columnWizard.getCounts().then((counts) => counts.keys.length)),
          textFuture('Number missing values:', columnWizard.numberMissing()),
          ...classCounts,
        ],);
      },);
  }

  Widget textFuture(String text, Future<num> future) {
    return FutureBuilder<num>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          String valueString = '';
          if (snapshot.data.runtimeType == int) {
            valueString = snapshot.data.toString();
          } else {
            valueString = snapshot.data?.toStringAsPrecision(Constants.maxDoublePrecision) ?? '';
          }
          return Row(
            children: [
              Text('$text '),
              Text(valueString),
            ],
          );
        }
        return Row(children: [Text('$text '), const CircularProgressIndicator()]);
      },);
  }

  Widget barDistributionPlot() {
    return Flexible(
      child: FutureBuilder<ColumnWizardBarChartData>(
        future: widget.columnWizard.getBarChartData(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final ColumnWizardBarChartData barChartData = snapshot.data!;
            final List<(String, double)> plotData = barChartData.dataPoints
                .map((point) => (barChartData.bottomTitles[point.$1], point.$2.toDouble()))
                .toList();
            return SizedBox(
              width: SizeConfig.screenWidth(context) * 0.4,
              height: SizeConfig.screenHeight(context) * 0.3,
              child: BiocentralBarPlot(
                data: plotData,
                xAxisLabel: 'Categories',
                yAxisLabel: 'Frequency',
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
