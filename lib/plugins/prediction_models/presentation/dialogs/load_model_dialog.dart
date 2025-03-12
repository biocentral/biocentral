import 'dart:async';

import 'package:biocentral/plugins/prediction_models/bloc/load_model_dialog_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/model_hub_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> pickFile(void Function(XFile) onFilePicked) async {
    final FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowedExtensions: ['yml', 'yaml', 'log', 'pt'], type: FileType.custom, withData: kIsWeb);
    if (result != null) {
      onFilePicked(result.xFiles.single);
    } else {
      // User canceled the picker
    }
  }

  Future<void> pickDirectory(void Function(String) onDirectoryPicked) async {
    final String? result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Pick model directory..',
      lockParentWindow: true,
    );
    if (result != null && result.isNotEmpty) {
      onDirectoryPicked(result);

      setState(() {
        _selectedDirectory = result;
      });
    }
  }

  void doLoading(LoadModelDialogState state) {
    widget.modelHubBloc.add(
      ModelHubLoadModelEvent(
          configFile: state.selectedConfigFile,
          outputFile: state.selectedOutputFile,
          loggingFile: state.selectedLoggingFile,
          checkpointFile: state.selectedCheckpointFile,
          importMode: _selectedImportMode),
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
                buildFilePathSelection(
                  loadModelDialogBloc,
                  state,
                  state.selectedConfigFile?.name ?? 'path/to/config_file',
                  (file) => loadModelDialogBloc.add(
                    LoadModelDialogSelectionEvent(
                      selectedConfigFile: file,
                      selectedOutputFile: null,
                      selectedLoggingFile: null,
                      selectedCheckpointFile: null,
                    ),
                  ),
                ),
                buildFilePathSelection(
                  loadModelDialogBloc,
                  state,
                  state.selectedOutputFile?.name ?? 'path/to/output_file',
                  (file) => loadModelDialogBloc.add(
                    LoadModelDialogSelectionEvent(
                      selectedConfigFile: null,
                      selectedOutputFile: file,
                      selectedLoggingFile: null,
                      selectedCheckpointFile: null,
                    ),
                  ),
                ),
                buildFilePathSelection(
                  loadModelDialogBloc,
                  state,
                  state.selectedLoggingFile?.name ?? 'path/to/logging_file',
                  (file) => loadModelDialogBloc.add(
                    LoadModelDialogSelectionEvent(
                      selectedConfigFile: null,
                      selectedOutputFile: null,
                      selectedLoggingFile: file,
                      selectedCheckpointFile: null,
                    ),
                  ),
                ),
                buildFilePathSelection(
                  loadModelDialogBloc,
                  state,
                  state.selectedCheckpointFile?.name ?? 'path/to/checkpoint_file',
                  (file) => loadModelDialogBloc.add(
                    LoadModelDialogSelectionEvent(
                      selectedConfigFile: file,
                      selectedOutputFile: null,
                      selectedLoggingFile: null,
                      selectedCheckpointFile: file,
                    ),
                  ),
                ),
                buildDirectoryPathSelection(
                  loadModelDialogBloc,
                  state,
                  _selectedDirectory ?? 'path/to/model_directory',
                  (path) => loadModelDialogBloc.add(
                    LoadModelDialogDirectorySelectionEvent(path),
                  ),
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

  Widget buildFilePathSelection(LoadModelDialogBloc loadModelDialogBloc, LoadModelDialogState state, String defaultName,
      void Function(XFile) fileSelectedCallback) {
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal(context)),
      child: Row(
        children: [
          Flexible(
            child: Text(
              defaultName,
              softWrap: true,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            onPressed: () => pickFile(
              (file) => fileSelectedCallback(file),
            ),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  Widget buildDirectoryPathSelection(LoadModelDialogBloc loadModelDialogBloc, LoadModelDialogState state,
      String defaultName, void Function(String) directorySelectedCallback) {
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal(context)),
      child: Row(
        children: [
          Flexible(
            child: Text(
              defaultName,
              softWrap: true,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            onPressed: () => pickDirectory(
              (path) => directorySelectedCallback(path),
            ),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
