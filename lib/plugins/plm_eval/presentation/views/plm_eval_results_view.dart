import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

class PLMEvalResultsView extends StatefulWidget {
  final Map<String, Map<String, Set<BiocentralMLMetric>>> metrics; // Dataset name -> Split name -> Metrics

  const PLMEvalResultsView({required this.metrics, super.key});

  @override
  State<PLMEvalResultsView> createState() => _PLMEvalResultsViewState();
}

class _PLMEvalResultsViewState extends State<PLMEvalResultsView> with AutomaticKeepAliveClientMixin {
  String? _selectedDatasetName;

  @override
  void initState() {
    super.initState();
    _selectedDatasetName = widget.metrics.keys.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        BiocentralDropdownMenu(
          dropdownMenuEntries: widget.metrics.keys
              .map((datasetName) => DropdownMenuEntry(value: datasetName, label: datasetName))
              .toList(),
          label: const Text('Select dataset..'),
          controller: TextEditingController.fromValue(TextEditingValue(text: _selectedDatasetName ?? '')),
          onSelected: (String? value) {
            if (value != null && value.isNotEmpty) {
              setState(() {
                _selectedDatasetName = value;
              });
            }
          },
        ),
        BiocentralMetricsTable(
          metrics: widget.metrics[_selectedDatasetName] ?? {},
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
