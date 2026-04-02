import 'package:biocentral/plugins/proteins/bloc/proteins_commands.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_database_update_display.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProteinLoadCommandDisplay extends StatefulWidget {
  const ProteinLoadCommandDisplay({super.key});

  @override
  State<ProteinLoadCommandDisplay> createState() => _ProteinLoadCommandDisplayState();
}

class _ProteinLoadCommandDisplayState extends State<ProteinLoadCommandDisplay> {
  XFile? _result;
  DatabaseImportMode _importMode = DatabaseImportMode.defaultMode;

  LoadProteinsFromFileCommand? collectCommand() {
    if (_result != null) {
      return LoadProteinsFromFileCommand(
        biocentralProjectRepository: context.read(),
        proteinRepository: context.read(),
        xFile: _result,
        assetDataset: null,
        importMode: _importMode,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandWidget(
      icon: const Icon(Icons.file_open),
      name: 'Load proteins from file',
      description: 'Load new protein data from a file',
      executeButtonLabel: 'Load',
      parameterSelection: buildParameterSelection,
      collectCommand: collectCommand,
      visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
      commandAvailability: BiocentralCommandAvailability.always(),
    );
  }

  Widget buildParameterSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          BiocentralFilePathSelection(
            defaultName: _result?.name ?? '/path/to/fasta',
            allowedExtensions: ['fasta'],
            fileSelectedCallback: (xFile, path) => setState(() {
              _result = xFile;
            }),
          ),
          BiocentralImportModeSelection(
            onChangedCallback: (importMode) => setState(() {
              _importMode = importMode ?? DatabaseImportMode.defaultMode;
            }),
          ),
        ].withPadding(const Padding(
          padding: EdgeInsetsGeometry.all(8.0),
        )),
      ),
    );
  }
}
