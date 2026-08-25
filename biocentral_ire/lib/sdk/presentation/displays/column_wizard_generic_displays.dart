import 'package:biocentral/sdk/model/column_wizard_abstract.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_bar_plot.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_histogram_kde_plot.dart';
import 'package:biocentral/sdk/util/size_config.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

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
                Builder(
                  builder: (context) {
                    final data = (widget.columnWizard as NumericStats).numericValues.toList();
                    return SizedBox(
                      width: SizeConfig.screenWidth(context) * 0.4,
                      height: SizeConfig.screenHeight(context) * 0.3,
                      child: BiocentralHistogramKDEPlot(data: data),
                    );
                  },
                ),
                //List.generate(1000, (_) => math.Random().nextDouble() * 100))),
              ],
            );
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget descriptiveStatisticsNumericStats() {
    final NumericStats columnWizard = widget.columnWizard as NumericStats;
    return DataTable(
      columns: const [
        DataColumn(label: Text('Statistic')),
        DataColumn(label: Text('Value')),
      ],
      rows: [
        DataRow(
          cells: [
            const DataCell(Text('Number values:')),
            DataCell(textFuture(future: columnWizard.length())),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(Text('Number missing values:')),
            DataCell(textFuture(future: columnWizard.numberMissing())),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(Text('Max:')),
            DataCell(textFuture(future: columnWizard.max())),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(Text('Min:')),
            DataCell(textFuture(future: columnWizard.min())),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(Text('Mean:')),
            DataCell(textFuture(future: columnWizard.mean())),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(Text('Median:')),
            DataCell(textFuture(future: columnWizard.median())),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(Text('Mode:')),
            DataCell(textFuture(future: columnWizard.mode())),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(Text('5%-Percentile:')),
            DataCell(textFuture(future: columnWizard.percentile(5))),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(Text('95%-Percentile:')),
            DataCell(textFuture(future: columnWizard.percentile(95))),
          ],
        ),
        DataRow(
          cells: [
            const DataCell(Text('Standard deviation:')),
            DataCell(textFuture(future: columnWizard.stdDev())),
          ],
        ),
      ],
    );
  }

  Widget descriptiveStatisticsCounterStats() {
    final CounterStats columnWizard = widget.columnWizard as CounterStats;
    return FutureBuilder<Map<String, int>>(
      future: columnWizard.getCounts(), // Cached
      builder: (context, snapshot) {
        final Map<String, int> classCounts = snapshot.data ?? {};
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DataTable(
              columns: const [
                DataColumn(label: Text('Statistic')),
                DataColumn(label: Text('Value')),
              ],
              rows: [
                DataRow(
                  cells: [
                    const DataCell(Text('Number values:')),
                    DataCell(textFuture(future: columnWizard.length())),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('Number different classes:')),
                    DataCell(textFuture(future: columnWizard.getCounts().then((counts) => counts.keys.length))),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('Number missing values:')),
                    DataCell(textFuture(future: columnWizard.numberMissing())),
                  ],
                ),
              ],
            ),
            DataTable(
              columns: const [
                DataColumn(label: Text('Class Name')),
                DataColumn(label: Text('Count')),
              ],
              rows: classCounts.entries
                  .sorted((e1, e2) => e1.value.compareTo(e2.value))
                  .reversed
                  .map((entry) => DataRow(cells: [DataCell(Text(entry.key)), DataCell(Text(entry.value.toString()))]))
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget barDistributionPlot() {
    return Flexible(
      child: FutureBuilder<BiocentralBarPlotData>(
        future: widget.columnWizard.getBarPlotData(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final BiocentralBarPlotData barPlotData = snapshot.data!;
            return SizedBox(
              width: SizeConfig.screenWidth(context) * 0.4,
              height: SizeConfig.screenHeight(context) * 0.3,
              child: BiocentralBarPlot(
                data: barPlotData,
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
