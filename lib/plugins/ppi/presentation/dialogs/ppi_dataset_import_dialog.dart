import 'dart:async';

import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/ppi_import_dialog_bloc.dart';

class PPIDatasetImportDialog extends StatefulWidget {
  final Function(FileData fileData, String format, DatabaseImportMode importMode) onImportInteractions;

  const PPIDatasetImportDialog({super.key, required this.onImportInteractions});

  @override
  State<PPIDatasetImportDialog> createState() => _PPIDatasetImportDialogState();
}

class _PPIDatasetImportDialogState extends State<PPIDatasetImportDialog> {
  bool _autoDetectedFormat = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickFilePath(PPIImportDialogBloc ppiImportDialogBloc) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowedExtensions: ["fasta", "csv", "txt", "json", "tsv"]);
    if (result != null) {
      ppiImportDialogBloc.add(PPIImportDialogSelectEvent({result.files.single}));
    } else {
      // User canceled the picker
    }
  }

  Future<void> doImport(PPIImportDialogState state) async {
    if (state.selectedFile != null && state.selectedFormat != null) {
      closeDialog();
      widget.onImportInteractions(
          state.selectedFile!, state.selectedFormat!, await getImportModeFromDialog(context: context));
    }
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    PPIImportDialogBloc ppiImportDialogBloc = BlocProvider.of<PPIImportDialogBloc>(context);

    return BlocEffectListener<PPIImportDialogBloc, ShowAutoDetectedFormat>(
      listener: (context, effect) {
        setState(() {
          _autoDetectedFormat = true;
        });
      },
      child: BlocConsumer<PPIImportDialogBloc, PPIImportDialogState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state.status == PPIImportDialogStatus.initial || state.status == PPIImportDialogStatus.loading) {
              return const CircularProgressIndicator();
            }
            return BiocentralDialog(children: [
              Text(
                "Import a dataset",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              buildDatasetSelection(ppiImportDialogBloc, state),
              SizedBox(height: SizeConfig.safeBlockVertical(context) * 3),
              // Format selection
              Padding(
                  padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal(context) * 2),
                  child: buildDatasetFormatDocs(state)),
              buildFormatSelection(ppiImportDialogBloc, state),
              SizedBox(height: SizeConfig.safeBlockVertical(context) * 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BiocentralSmallButton(
                    label: "Import",
                    onTap: () => doImport(state),
                  ),
                  BiocentralSmallButton(
                    label: "Close",
                    onTap: closeDialog,
                  ),
                ],
              )
            ]);
          }),
    );
  }

  Widget buildDocStringBox(String docString) {
    return SizedBox(
        height: SizeConfig.screenHeight(context) * 0.15,
        width: SizeConfig.screenWidth(context) * 0.8,
        child: SingleChildScrollView(
            child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.grey,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(docString),
                ))));
  }

  Widget buildDatasetSelection(PPIImportDialogBloc ppiImportDialogBloc, PPIImportDialogState state) {
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal(context)),
      child: Row(
        children: [
          Flexible(
            child: Text(
              state.selectedFile?.name ?? "path/to/file",
              softWrap: true,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(onPressed: () => pickFilePath(ppiImportDialogBloc), icon: const Icon(Icons.search))
        ],
      ),
    );
  }

  Widget buildDatasetFormatDocs(PPIImportDialogState state) {
    String docString = "";
    if (state.selectedFormat != null && state.availableFormatsWithDocs != null) {
      docString = "\n${state.selectedFormat!}:\n\n${state.availableFormatsWithDocs?[state.selectedFormat]!}\n";
    }
    return buildDocStringBox(docString);
  }

  Widget buildFormatSelection(PPIImportDialogBloc ppiImportDialogBloc, PPIImportDialogState state) {
    if (state.availableFormatsWithDocs == null) {
      return Container();
    }
    List<Widget> formatRadioTiles = [];
    for (String format in state.availableFormatsWithDocs!.keys) {
      Widget formatRadioTile = BiocentralQuickMessage(
        message: "Auto-detected format!",
        triggered: _autoDetectedFormat && format == state.selectedFormat,
        callback: () {
          _autoDetectedFormat = false;
        },
        child: RadioListTile<String>(
          title: Text(format, style: Theme.of(context).textTheme.bodyMedium),
          value: format,
          groupValue: state.selectedFormat,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (String? value) {
            ppiImportDialogBloc.add(PPIImportDialogSelectEvent({value}));
          },
        ),
      );
      formatRadioTiles.add(formatRadioTile);
    }
    return Column(
      children: formatRadioTiles,
    );
  }
}
