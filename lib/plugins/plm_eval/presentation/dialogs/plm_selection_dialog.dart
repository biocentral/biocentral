import 'package:biocentral/plugins/embeddings/presentation/displays/tokenizer_config_selection.dart';
import 'package:biocentral/plugins/plm_eval/bloc/plm_selection_dialog_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Either;

class PLMSelectionDialog extends StatefulWidget {
  final void Function(
    Either<String, XFile> modelSelection,
    Map<String, dynamic> tokenizerConfig,
    List<PLMEvalTaskInformation> tasks,
  ) onStartAutoeval;

  const PLMSelectionDialog({required this.onStartAutoeval, super.key});

  @override
  State<PLMSelectionDialog> createState() => _PLMSelectionDialogState();
}

class _PLMSelectionDialogState extends State<PLMSelectionDialog> with BiocentralDialogCloseMixin {
  String? _plmSelection;
  XFile? _onnxFile;

  Map<String, dynamic> _tokenizerConfig = {};

  @override
  void initState() {
    super.initState();
  }

  void startAutoeval(PLMSelectionDialogState state) {
    if (state.status == PLMSelectionDialogStatus.validated && state.modelSelection != null && state.tasks.isNotEmpty) {
      closeDialog(callback: () => widget.onStartAutoeval(state.modelSelection!, _tokenizerConfig, state.tasks));
    }
  }

  void updateTokenizerConfig(Map<String, dynamic>? updatedConfig) {
    if (updatedConfig != null) {
      setState(() {
        _tokenizerConfig = updatedConfig;
      });
    }
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

    dialogChildren.add(
      Text(
        'Create an evaluation for your protein language model',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );

    // Helper Text for errors
    String helperText = state.errorMessage ?? '';
    Color helperStyleColor = Colors.red;

    if (state.status == PLMSelectionDialogStatus.validated) {
      helperText = 'Successfully validated, you are good to go!';
      helperStyleColor = Colors.green;
    }

    if (helperText.isNotEmpty) {
      dialogChildren.add(
        Text(
          helperText,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: helperStyleColor),
        ),
      );
    }
    dialogChildren.addAll([
      buildModelSelection(plmSelectionDialogBloc, state),
      buildTasksInformation(plmSelectionDialogBloc, state, state.tasks),
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
            child: TabBar(
              labelColor: Theme.of(context).colorScheme.onSurface,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              tabs: [
                const Tab(icon: Icon(Icons.hub), text: 'Huggingface'),
                const Tab(icon: Icon(Icons.folder_open_sharp), text: 'ONNX'),
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
    return Column(
      children: [
        const Flexible(
          child: Text('Evaluate a model on huggingface. Results can be published to the '
              'leaderboard after successful evaluation.'),
        ),
        Flexible(
          child: TextFormField(
            initialValue: '',
            decoration: const InputDecoration(
              labelText: 'Enter a valid huggingface model ID here',
              hintText: 'e.g. Rostlab/prot_t5_xl_uniref50',
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
            onTap: () =>
                plmSelectionDialogBloc.add(PLMSelectionDialogValidateHuggingfaceEvent(plmSelection: _plmSelection)),
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
            allowedExtensions: ['.onnx'],
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
          onTap: () => plmSelectionDialogBloc.add(
            PLMSelectionDialogValidateONNXEvent(onnxFile: _onnxFile),
          ),
        )
      ],
    );
  }

  Widget buildTasksInformation(PLMSelectionDialogBloc plmSelectionDialogBloc, PLMSelectionDialogState state,
      List<PLMEvalTaskInformation> tasks) {
    if (tasks.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        ...tasks.map((task) => Text('${task.name}:${task.description}')),
        buildSequenceLengthHint(),
        buildEvaluateButton(plmSelectionDialogBloc, state),
      ],
    );
  }

  Widget buildSequenceLengthHint() {
    return Text(
      'Note: Proteins in all datasets are currently limited to a length of 2000!',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.red),
    );
  }

  Widget buildEvaluateButton(PLMSelectionDialogBloc plmSelectionDialogBloc, PLMSelectionDialogState state) {
    if (state.status == PLMSelectionDialogStatus.validated && state.tasks.isNotEmpty) {
      return BiocentralSmallButton(onTap: () => startAutoeval(state), label: 'Start Evaluation');
    }
    return Container();
  }

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: 'Close');
  }
}
