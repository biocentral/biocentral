import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_metrics_display.dart';
import 'package:flutter/material.dart';

class PLMEvalResultsDisplay extends StatefulWidget {
  final Map<String, Set<BiocentralMLMetric>> metrics; // Dataset name -> Split name -> Metrics

  const PLMEvalResultsDisplay({required this.metrics, super.key});

  @override
  State<PLMEvalResultsDisplay> createState() => _PLMEvalResultsDisplayState();
}

class _PLMEvalResultsDisplayState extends State<PLMEvalResultsDisplay> with AutomaticKeepAliveClientMixin {
  String? _selectedTaskName;

  @override
  void initState() {
    super.initState();
    _selectedTaskName = widget.metrics.keys.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        BiocentralDropdownMenu(
          dropdownMenuEntries: widget.metrics.keys
              .map((taskName) => DropdownMenuEntry(value: taskName, label: taskName))
              .toList(),
          label: const Text('Select task..'),
          controller: TextEditingController.fromValue(TextEditingValue(text: _selectedTaskName ?? '')),
          onSelected: (String? value) {
            if (value != null && value.isNotEmpty) {
              setState(() {
                _selectedTaskName = value;
              });
            }
          },
        ),
        SizedBox(
          height: SizeConfig.screenHeight(context) * 0.7,
          child: BiocentralMetricsDisplay(
            metrics: widget.metrics,
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
