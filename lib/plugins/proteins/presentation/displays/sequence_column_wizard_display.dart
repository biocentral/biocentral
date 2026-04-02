import 'package:biocentral/plugins/proteins/model/sequence_column_wizard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/plots/biocentral_bar_plot.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';

class SequenceColumnWizardDisplay extends StatefulWidget {
  final SequenceColumnWizard columnWizard;

  const SequenceColumnWizardDisplay({required this.columnWizard, super.key});

  @override
  State<SequenceColumnWizardDisplay> createState() => _SequenceColumnWizardDisplayState();
}

class _SequenceColumnWizardDisplayState extends State<SequenceColumnWizardDisplay> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSequenceStats(),
        SizedBox(
          width: SizeConfig.safeBlockHorizontal(context) * 5,
        ),
        buildCompositionPlot(),
      ],
    );
  }

  Widget buildSequenceStats() {
    final SequenceColumnWizard columnWizard = widget.columnWizard;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Descriptive Statistics:\n'),
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
                const DataCell(Text('Sequence Type:')),
                DataCell(
                  textFuture(
                    future: Future.value(columnWizard.valueMap.values.firstOrNull?.runtimeType ?? 'Unknown'),
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                const DataCell(Text('Mean Sequence Length:')),
                DataCell(
                  textFuture(
                    future: Future.value(
                      columnWizard.meanSequenceLength().then((mean) => mean.toStringAsFixed(1)),
                    ),
                  ),
                ),
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
                const DataCell(Text('Unique sequence lengths found:')),
                DataCell(
                  textFuture(
                    future: columnWizard.lengthCount().then((counts) => counts.keys.length),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCompositionPlot() {
    return FutureBuilder<Map<String, double>>(
      future: widget.columnWizard.composition(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return SizedBox(
            width: SizeConfig.screenWidth(context) * 0.4,
            height: SizeConfig.screenHeight(context) * 0.3,
            child: BiocentralBarPlot(
              data: BiocentralBarPlotData.withoutErrors(snapshot.data!),
              xAxisLabel: 'Composition',
              yAxisLabel: 'Relative Frequency',
            ),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
