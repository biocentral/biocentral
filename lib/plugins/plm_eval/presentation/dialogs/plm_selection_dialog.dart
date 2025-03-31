import 'package:biocentral/plugins/embeddings/presentation/displays/tokenizer_config_selection.dart';
import 'package:biocentral/plugins/plm_eval/bloc/plm_selection_dialog_bloc.dart';
import 'package:biocentral/plugins/plm_eval/model/benchmark_dataset.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Either;

class PLMSelectionDialog extends StatefulWidget {
  final void Function(Either<String, XFile> modelSelection, Map<String, dynamic>? tokenizerConfig,
      List<BenchmarkDataset> datasets, bool recommendedOnly) onStartAutoeval;

  const PLMSelectionDialog({required this.onStartAutoeval, super.key});

  @override
  State<PLMSelectionDialog> createState() => _PLMSelectionDialogState();
}

class _PLMSelectionDialogState extends State<PLMSelectionDialog> {
  String? _plmSelection;
  XFile? _onnxFile;

  Map<String, dynamic> _tokenizerConfig = {};

  bool _recommendedOnlySelection = true;

  @override
  void initState() {
    super.initState();
  }

  void startAutoeval(PLMSelectionDialogState state) {
    if (state.status == PLMSelectionDialogStatus.validated &&
        state.modelSelection != null &&
        state.availableDatasets.isNotEmpty) {
      closeDialog();
      widget.onStartAutoeval(state.modelSelection!, _tokenizerConfig,
          _recommendedOnlySelection ? state.recommendedDatasets : state.availableDatasets, _recommendedOnlySelection);
    }
  }

  void updateTokenizerConfig(Map<String, dynamic>? updatedConfig) {
    if (updatedConfig != null) {
      setState(() {
        _tokenizerConfig = updatedConfig;
      });
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

    dialogChildren.addAll([
      Text(
        'Create an evaluation for your protein language model',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      buildModelSelection(plmSelectionDialogBloc, state),
      buildDatasetSplitsDisplay(plmSelectionDialogBloc, state, state.availableDatasets, state.recommendedDatasets),
      buildCancelButton(),
    ]);

    return BiocentralDialog(
      children: dialogChildren,
    );
  }

  Widget buildModelSelection(PLMSelectionDialogBloc plmSelectionDialogBloc, PLMSelectionDialogState state) {
    if (state.status == PLMSelectionDialogStatus.validated) {
      return state.modelSelection
              ?.match((modelID) => Text('Evaluate: $modelID'), (onnxFile) => Text('Evaluate: ${onnxFile.name}')) ??
          Container();
    }
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          SizedBox(
            height: SizeConfig.screenHeight(context) * 0.1,
            child: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.hub), text: 'Huggingface'),
                Tab(icon: Icon(Icons.folder_open_sharp), text: 'ONNX'),
              ],
            ),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical(context) * 2),
          SizedBox(
            height: SizeConfig.screenHeight(context) * 0.75,
            child: TabBarView(
              children: [
                IntrinsicHeight(child: buildHuggingfaceSelection(plmSelectionDialogBloc, state)),
                IntrinsicHeight(child: buildONNXSelection(plmSelectionDialogBloc, state)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHuggingfaceSelection(PLMSelectionDialogBloc plmSelectionDialogBloc, PLMSelectionDialogState state) {
    // Helper Text for errors
    String helperText = state.errorMessage ?? '';
    Color helperStyleColor = Colors.red;

    if (state.status == PLMSelectionDialogStatus.validated) {
      helperText = 'Successfully validated, you are good to go!';
      helperStyleColor = Colors.green;
    }

    return Column(
      children: [
        const Flexible(
          child: Text('Evaluate a model on huggingface. Results can be published to the '
              'leaderboard after successful evaluation.'),
        ),
        Flexible(
          child: TextFormField(
            initialValue: '',
            decoration: InputDecoration(
              labelText: 'Enter a valid huggingface model ID here',
              hintText: 'e.g. Rostlab/prot_t5_xl_uniref50',
              helperText: helperText,
              helperStyle: Theme.of(context).textTheme.labelSmall?.copyWith(color: helperStyleColor),
            ),
            onChanged: (String? value) {
              setState(() {
                _plmSelection = value ?? '';
              });
            },
          ),
        ),
        Flexible(
          child: BiocentralSmallButton(
            label: 'Validate huggingface ID',
            onTap: () => plmSelectionDialogBloc.add(PLMSelectionDialogValidateEvent(plmSelection: _plmSelection)),
          ),
        ),
      ],
    );
  }

  Widget buildONNXSelection(PLMSelectionDialogBloc plmSelectionDialogBloc, PLMSelectionDialogState state) {
    return Column(
      children: [
        const Flexible(
          child: Text('Evaluate a local ONNX model - the model gets transferred to the server and deleted afterwards. '
              'Note that results cannot be published to the leaderboard, they can only be viewed local.'),
        ),
        Flexible(
          child: BiocentralFilePathSelection(
            defaultName: _onnxFile?.name ?? 'path/to/onnx',
            fileSelectedCallback: (file) => setState(() {
              _onnxFile = file;
            }),
          ),
        ),
        Flexible(
          flex: 2,
          child: SingleChildScrollView(
            child: TokenizerConfigSelection(
              onConfigUpdate: updateTokenizerConfig,
            ),
          ),
        ),
        BiocentralSmallButton(
            label: 'Check ONNX Setup',
            onTap: () => plmSelectionDialogBloc.add(PLMSelectionDialogValidateEvent(onnxSelection: _onnxFile)))
      ],
    );
  }

  TextStyle? _getTextStyleForSplits(String datasetName, String splitName, List<BenchmarkDataset> recommended) {
    final standardTheme = Theme.of(context).textTheme.labelMedium;
    if (_recommendedOnlySelection == false) {
      return standardTheme?.copyWith(color: Colors.black);
    }

    final benchmarkDataset = BenchmarkDataset(datasetName: datasetName, splitName: splitName);
    final isRecommendedDataset = recommended.contains(benchmarkDataset);
    if (isRecommendedDataset) {
      return standardTheme?.copyWith(color: Colors.black);
    }
    return standardTheme?.copyWith(color: Colors.white);
  }

  Widget buildDatasetSplitsDisplay(PLMSelectionDialogBloc plmSelectionDialogBloc, PLMSelectionDialogState state,
      List<BenchmarkDataset> available, List<BenchmarkDataset> recommended) {
    if (available.isEmpty) {
      return Container();
    }
    final Map<String, List<String>> availableDatasetMap = BenchmarkDataset.benchmarkDatasetsByDatasetName(available);

    return Column(
      children: [
        const Text('Benchmark Datasets (FLIP):'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          child: Table(
            border: TableBorder.all(
              color: Colors.grey,
              width: 1,
            ),
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: [
              // Header row
              const TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Dataset',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Splits',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Data rows
              ...availableDatasetMap.entries.map((entry) {
                final String datasetName = entry.key;
                final List<String> splits = entry.value;

                return TableRow(
                  children: [
                    // Dataset name cell
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        datasetName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Splits cell
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: splits.map((splitName) {
                          return Chip(
                            label: Text(
                              splitName,
                              style: _getTextStyleForSplits(
                                datasetName,
                                splitName,
                                recommended,
                              ),
                            ),
                            backgroundColor: Colors.white,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        buildRecommendedOnlyCheckBox(),
        buildSequenceLengthHint(),
        buildEvaluateButton(plmSelectionDialogBloc, state),
      ],
    );
  }

  Widget buildRecommendedOnlyCheckBox() {
    return CheckboxListTile(
      title: const Text('Only use recommended datasets'),
      controlAffinity: ListTileControlAffinity.leading,
      value: _recommendedOnlySelection,
      onChanged: (bool? value) => setState(() {
        _recommendedOnlySelection = value ?? false;
      }),
    );
  }

  Widget buildSequenceLengthHint() {
    return Text(
      'Note: Proteins in all datasets are currently limited to a length of 2000!',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.red),
    );
  }

  Widget buildEvaluateButton(PLMSelectionDialogBloc plmSelectionDialogBloc, PLMSelectionDialogState state) {
    if (state.status == PLMSelectionDialogStatus.validated && state.availableDatasets.isNotEmpty) {
      return BiocentralSmallButton(onTap: () => startAutoeval(state), label: 'Start Evaluation');
    }
    return Container();
  }

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: 'Close');
  }
}
