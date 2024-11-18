import 'package:biocentral/plugins/plm_eval/bloc/plm_selection_dialog_bloc.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PLMSelectionDialog extends StatefulWidget {
  final void Function(String, List<BenchmarkDataset>, bool) onStartAutoeval;

  const PLMSelectionDialog({required this.onStartAutoeval, super.key});

  @override
  State<PLMSelectionDialog> createState() => _PLMSelectionDialogState();
}

class _PLMSelectionDialogState extends State<PLMSelectionDialog> {
  String? plmSelection;
  bool recommendedOnlySelection = true;

  @override
  void initState() {
    super.initState();
  }

  void startAutoeval(PLMSelectionDialogState state) {
    if (state.status == PLMSelectionDialogStatus.validated &&
        state.plmHuggingface != null &&
        state.availableDatasets.isNotEmpty) {
      closeDialog();
      widget.onStartAutoeval(state.plmHuggingface!,
          recommendedOnlySelection ? state.recommendedDatasets : state.availableDatasets, recommendedOnlySelection);
    }
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PLMSelectionDialogBloc, PLMSelectionDialogState>(
      builder: (context, state) => buildDialog(state),
    );
  }

  Widget buildDialog(PLMSelectionDialogState state) {
    final PLMSelectionDialogBloc plmSelectionDialogBloc = BlocProvider.of<PLMSelectionDialogBloc>(context);
    final List<Widget> dialogChildren = [];

    // Helper Text for errors
    String helperText = state.errorMessage ?? '';
    Color helperStyleColor = Colors.red;

    if (state.status == PLMSelectionDialogStatus.validated) {
      helperText = 'Successfully validated, you are good to go!';
      helperStyleColor = Colors.green;
    }

    dialogChildren.addAll([
      Text(
        'Create an evaluation for your protein language model',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      TextFormField(
        initialValue: '',
        decoration: InputDecoration(
          labelText: 'Enter a valid huggingface model ID here',
          hintText: 'e.g. Rostlab/prot_t5_xl_uniref50',
          helperText: helperText,
          helperStyle: Theme.of(context).textTheme.labelSmall?.copyWith(color: helperStyleColor),
        ),
        onChanged: (String? value) {
          setState(() {
            plmSelection = value ?? '';
          });
        },
      ),
      buildDatasetSplitsDisplay(state.availableDatasets, state.recommendedDatasets),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [buildCheckAndEvaluateButton(plmSelectionDialogBloc, state), buildCancelButton()],
      ),
    ]);

    return BiocentralDialog(
      children: dialogChildren,
    );
  }

  TextStyle? _getTextStyleForSplits(String datasetName, String splitName, List<BenchmarkDataset> recommended) {
    final standardTheme = Theme.of(context).textTheme.labelMedium;
    if (recommendedOnlySelection == false) {
      return standardTheme;
    }

    final benchmarkDataset = BenchmarkDataset(datasetName: datasetName, splitName: splitName);
    final isRecommendedDataset = recommended.contains(benchmarkDataset);
    if (isRecommendedDataset) {
      return standardTheme?.copyWith(color: Theme.of(context).colorScheme.primary);
    }
    return standardTheme?.copyWith(color: Colors.grey);
  }

  Widget buildDatasetSplitsDisplay(List<BenchmarkDataset> available, List<BenchmarkDataset> recommended) {
    if (available.isEmpty) {
      return Container();
    }
    final Map<String, List<String>> availableDatasetMap = BenchmarkDataset.benchmarkDatasetsByDatasetName(available);

    return Column(
      children: [
        const Text('Benchmark Datasets (FLIP):'),
        const SizedBox(
          height: 8,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: availableDatasetMap.entries.map((entry) {
              final String datasetName = entry.key;
              final List<String> splits = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      datasetName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_forward, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: splits.map((splitName) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                splitName,
                                style: _getTextStyleForSplits(datasetName, splitName, recommended),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        buildRecommendedOnlyCheckBox(),
      ],
    );
  }

  Widget buildRecommendedOnlyCheckBox() {
    return CheckboxListTile(
      title: const Text('Only use recommended datasets'),
      controlAffinity: ListTileControlAffinity.leading,
      value: recommendedOnlySelection,
      onChanged: (bool? value) => setState(() {
        recommendedOnlySelection = value ?? false;
      }),
    );
  }

  Widget buildCheckAndEvaluateButton(PLMSelectionDialogBloc plmSelectionDialogBloc, PLMSelectionDialogState state) {
    if (state.status == PLMSelectionDialogStatus.validated && state.availableDatasets.isNotEmpty) {
      return BiocentralSmallButton(onTap: () => startAutoeval(state), label: 'Start Evaluation');
    }
    return BiocentralSmallButton(
      onTap: () => plmSelectionDialogBloc.add(PLMSelectionDialogSelectedEvent(plmSelection ?? '')),
      label: 'Check Model',
    );
  }

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: 'Close');
  }
}
