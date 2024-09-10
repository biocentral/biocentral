import 'dart:async';

import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/load_model_dialog_bloc.dart';

class LoadModelDialog extends StatefulWidget {
  const LoadModelDialog({super.key});

  @override
  State<LoadModelDialog> createState() => _LoadModelDialogState();
}

class _LoadModelDialogState extends State<LoadModelDialog> {
  DatabaseImportMode _selectedImportMode = DatabaseImportMode.overwrite;

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickFile(void Function(PlatformFile) setFileOnPicked) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowedExtensions: ["yml", "yaml", "log", "pt"], type: FileType.custom, withData: kIsWeb);
    if (result != null) {
      setFileOnPicked(result.files.single);
    } else {
      // User canceled the picker
    }
  }

  Future<void> doLoading(LoadModelDialogBloc loadModelDialogBloc) async {
    loadModelDialogBloc.add(LoadModelDialogLoadEvent(_selectedImportMode));
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    LoadModelDialogBloc loadModelDialogBloc = BlocProvider.of<LoadModelDialogBloc>(context);

    return BlocConsumer<LoadModelDialogBloc, LoadModelDialogState>(
      listener: (context, state) {
        if (state.status == LoadModelDialogStatus.loaded) {
          closeDialog();
        }
      },
      builder: (context, state) {
        return BiocentralDialog(children: [
          Text(
            "Load a model",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: SizeConfig.safeBlockVertical(context) * 3),
          BiocentralImportModeSelection(onChangedCallback: (DatabaseImportMode? value) {
            setState(() {
              _selectedImportMode = value!;
            });
          }),
          // Format selection
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildConfigFileSelection(loadModelDialogBloc, state),
              buildOutputFileSelection(loadModelDialogBloc, state),
              buildLoggingFileSelection(loadModelDialogBloc, state),
              buildCheckpointPathSelection(loadModelDialogBloc, state)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BiocentralSmallButton(
                label: "Load",
                onTap: () async => doLoading(loadModelDialogBloc),
              ),
              BiocentralSmallButton(
                label: "Close",
                onTap: closeDialog,
              ),
            ],
          )
        ]);
      },
    );
  }

  Widget buildConfigFileSelection(LoadModelDialogBloc loadModelDialogBloc, LoadModelDialogState state) {
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal(context)),
      child: Row(
        children: [
          Flexible(
            child: Text(
              state.selectedConfigFile?.name ?? "path/to/config_file",
              softWrap: true,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
              onPressed: () => pickFile((file) => loadModelDialogBloc.add(LoadModelDialogSelectionEvent(
                  selectedConfigFile: file,
                  selectedOutputFile: null,
                  selectedLoggingFile: null,
                  selectedCheckpointFile: null))),
              icon: const Icon(Icons.search))
        ],
      ),
    );
  }

  Widget buildOutputFileSelection(LoadModelDialogBloc loadModelDialogBloc, LoadModelDialogState state) {
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal(context)),
      child: Row(
        children: [
          Flexible(
            child: Text(
              state.selectedOutputFile?.name ?? "path/to/output_file",
              softWrap: true,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
              onPressed: () => pickFile((file) => loadModelDialogBloc.add(LoadModelDialogSelectionEvent(
                  selectedConfigFile: null,
                  selectedOutputFile: file,
                  selectedLoggingFile: null,
                  selectedCheckpointFile: null))),
              icon: const Icon(Icons.search))
        ],
      ),
    );
  }

  Widget buildLoggingFileSelection(LoadModelDialogBloc loadModelDialogBloc, LoadModelDialogState state) {
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal(context)),
      child: Row(
        children: [
          Flexible(
            child: Text(
              state.selectedLoggingFile?.name ?? "path/to/logging_file",
              softWrap: true,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
              onPressed: () => pickFile((file) => loadModelDialogBloc.add(LoadModelDialogSelectionEvent(
                  selectedConfigFile: null,
                  selectedOutputFile: null,
                  selectedLoggingFile: file,
                  selectedCheckpointFile: null))),
              icon: const Icon(Icons.search))
        ],
      ),
    );
  }

  Widget buildCheckpointPathSelection(LoadModelDialogBloc loadModelDialogBloc, LoadModelDialogState state) {
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal(context)),
      child: Row(
        children: [
          Flexible(
            child: Text(
              state.selectedCheckpointFile?.name ?? "path/to/checkpoint_file",
              softWrap: true,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
              onPressed: () => pickFile((file) => loadModelDialogBloc.add(LoadModelDialogSelectionEvent(
                  selectedConfigFile: null,
                  selectedOutputFile: null,
                  selectedLoggingFile: null,
                  selectedCheckpointFile: file))),
              icon: const Icon(Icons.search))
        ],
      ),
    );
  }
}
