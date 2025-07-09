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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Descriptive Statistics:\n'),
        textFuture('Number values:', widget.columnWizard.length()),
        textFuture(
            'Sequence Type:', Future.value(widget.columnWizard.valueMap.values.firstOrNull?.runtimeType ?? 'Unknown'),),
        textFuture('Number missing values:', widget.columnWizard.numberMissing()),
      ],
    );
  }

  Widget buildCompositionPlot() {
    return FutureBuilder<Map<String, double>>(
      future: widget.columnWizard.composition(),
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data != null) {
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
