import 'package:biocentral/plugins/proteins/bloc/proteins_commands.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProteinExportCommandDisplay extends StatefulWidget {
  const ProteinExportCommandDisplay({super.key});

  @override
  State<ProteinExportCommandDisplay> createState() => _ProteinExportCommandDisplayState();
}

class _ProteinExportCommandDisplayState extends State<ProteinExportCommandDisplay> {
  String? _exportPath;

  ExportProteinsCommand? collectCommand() {
    if (_exportPath != null) {
      return ExportProteinsCommand(
        biocentralProjectRepository: context.read(),
        proteinRepository: context.read(),
        filePath: _exportPath!,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandWidget(
      icon: const Icon(Icons.save),
      name: 'Export proteins',
      description: 'Save a copy of your current protein database as fasta file',
      executeButtonLabel: 'Export',
      parameterSelection: buildParameterSelection,
      collectCommand: collectCommand,
      visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
      commandAvailability: BiocentralCommandAvailability.always(),
      alwaysAutoAccept: true,
    );
  }

  Widget buildParameterSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          BiocentralFilePathSelection(
            defaultName: _exportPath ?? '/path/to/fasta',
            allowedExtensions: ['fasta'],
            fileSelectedCallback: (xFile, path) => setState(() {
              _exportPath = path;
            }),
            pickForExport: true,
          ),
        ].withPadding(const Padding(
          padding: EdgeInsetsGeometry.all(8.0),
        )),
      ),
    );
  }
}
