import 'package:biocentral/plugins/prediction_models/bloc/load_model_dialog_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/model_hub_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_directory_path_selection.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadModelDialog extends StatefulWidget {
  final ModelHubBloc modelHubBloc;

  const LoadModelDialog({required this.modelHubBloc, super.key});

  @override
  State<LoadModelDialog> createState() => _LoadModelDialogState();
}

class _LoadModelDialogState extends State<LoadModelDialog> {
  DatabaseImportMode _selectedImportMode = DatabaseImportMode.overwrite;

  String? _selectedDirectory;

  @override
  void initState() {
    super.initState();
  }

  void doLoading(LoadModelDialogState state) {
    widget.modelHubBloc.add(
      ModelHubLoadModelEvent(
        configFile: state.selectedConfigFile,
        outputFile: state.selectedOutputFile,
        loggingFile: state.selectedLoggingFile,
        checkpointFile: state.selectedCheckpointFile,
        importMode: _selectedImportMode,
      ),
    );
    closeDialog();
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final LoadModelDialogBloc loadModelDialogBloc = BlocProvider.of<LoadModelDialogBloc>(context);

    return BlocBuilder<LoadModelDialogBloc, LoadModelDialogState>(
      builder: (context, state) {
        return BiocentralDialog(
          children: [
            Text(
              'Load a model',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: SizeConfig.safeBlockVertical(context) * 3),
            BiocentralImportModeSelection(
              onChangedCallback: (DatabaseImportMode? value) {
                setState(() {
                  _selectedImportMode = value!;
                });
              },
            ),
            // Format selection
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BiocentralFilePathSelection(
                  defaultName: state.selectedConfigFile?.name ?? 'path/to/config_file',
                  allowedExtensions: ['.yml', '.yaml'],
                  fileSelectedCallback: (file) => loadModelDialogBloc.add(
                    LoadModelDialogSelectionEvent(
                      selectedConfigFile: file,
                      selectedOutputFile: null,
                      selectedLoggingFile: null,
                      selectedCheckpointFile: null,
                    ),
                  ),
                ),
                BiocentralFilePathSelection(
                  defaultName: state.selectedOutputFile?.name ?? 'path/to/output_file',
                  allowedExtensions: ['.yml', '.yaml'],
                  fileSelectedCallback: (file) => loadModelDialogBloc.add(
                    LoadModelDialogSelectionEvent(
                      selectedConfigFile: null,
                      selectedOutputFile: file,
                      selectedLoggingFile: null,
                      selectedCheckpointFile: null,
                    ),
                  ),
                ),
                BiocentralFilePathSelection(
                  defaultName: state.selectedLoggingFile?.name ?? 'path/to/logging_file',
                  allowedExtensions: ['.log'],
                  fileSelectedCallback: (file) => loadModelDialogBloc.add(
                    LoadModelDialogSelectionEvent(
                      selectedConfigFile: null,
                      selectedOutputFile: null,
                      selectedLoggingFile: file,
                      selectedCheckpointFile: null,
                    ),
                  ),
                ),
                BiocentralFilePathSelection(
                  defaultName: state.selectedCheckpointFile?.name ?? 'path/to/checkpoint_file',
                  allowedExtensions: ['.safetensors', '.pt'],
                  fileSelectedCallback: (file) => loadModelDialogBloc.add(
                    LoadModelDialogSelectionEvent(
                      selectedConfigFile: null,
                      selectedOutputFile: null,
                      selectedLoggingFile: null,
                      selectedCheckpointFile: file,
                    ),
                  ),
                ),
                BiocentralDirectoryPathSelection(
                  defaultName: _selectedDirectory ?? 'path/to/model_directory',
                  directorySelectedCallback: (path) {
                    loadModelDialogBloc.add(LoadModelDialogDirectorySelectionEvent(path));
                    setState(() {
                      _selectedDirectory = path;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BiocentralSmallButton(
                  label: 'Load',
                  onTap: () => doLoading(state),
                ),
                BiocentralSmallButton(
                  label: 'Close',
                  onTap: closeDialog,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
