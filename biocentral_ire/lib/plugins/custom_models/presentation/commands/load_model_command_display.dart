import 'package:biocentral/plugins/custom_models/bloc/models_commands.dart';
import 'package:biocentral/plugins/custom_models/data/biotrainer_output_dir_handler.dart';
import 'package:biocentral/plugins/custom_models/presentation/displays/prediction_model_display.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_directory_path_selection.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:biocentral/sdk/util/path_util.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadModelCommandDisplay extends StatefulWidget {
  const LoadModelCommandDisplay({super.key});

  @override
  State<LoadModelCommandDisplay> createState() => _LoadModelCommandDisplayState();
}

class _LoadModelCommandDisplayState extends State<LoadModelCommandDisplay> {
  String? _selectedDirectory;
  XFile? _configFile;
  XFile? _outputFile;
  XFile? _loggingFile;
  XFile? _checkpointFile; // TODO [Optimization] Support multiple checkpoints
  DatabaseImportMode _importMode = DatabaseImportMode.defaultMode;

  Future<bool> _directoryScannerFuture = Future.value(true);

  LoadModelCommand? collectCommand() {
    if (_configFile != null || _outputFile != null || _loggingFile != null) {
      return LoadModelCommand(
        projectRepository: context.read(),
        modelRepository: context.read(),
        configFile: _configFile,
        outputFile: _outputFile,
        loggingFile: _loggingFile,
        checkpointFile: _checkpointFile,
        importMode: _importMode,
      );
    }
    return null;
  }

  Future<bool> scanDirectory() async {
    if (_selectedDirectory != null) {
      final directoryPath = _selectedDirectory!;

      final pathScanResult = PathScanner.scanDirectory(directoryPath);

      final List<XFile> allFiles = [
        ...pathScanResult.baseFiles,
        ...pathScanResult.getAllSubdirectoryFiles().values.reduce((l1, l2) => l1 + l2),
      ];

      final (configFile, outputFile, loggingFile, checkpointFile) =
          BiotrainerOutputDirHandler.scanDirectoryFiles(allFiles);
      _configFile = configFile ?? _configFile;
      _outputFile = outputFile ?? _outputFile;
      _loggingFile = loggingFile ?? _loggingFile;
      _checkpointFile = checkpointFile ?? _checkpointFile;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandWidget(
      icon: const Icon(Icons.file_open),
      name: 'Load model from file(s)',
      description: 'Load a prediction model from biotrainer file output',
      executeButtonLabel: 'Load',
      parameterSelection: buildParameterSelection,
      collectCommand: collectCommand,
      visualizeResult: PredictionModelDisplay.visualizePredictionModelResult,
      commandAvailability: BiocentralCommandAvailability.always(),
    );
  }

  Widget buildParameterSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          BiocentralDirectoryPathSelection(
            defaultName: _selectedDirectory ?? 'path/to/model_directory',
            directorySelectedCallback: (path) {
              setState(() {
                _selectedDirectory = path;
                _directoryScannerFuture = scanDirectory();
              });
            },
          ),
          FutureBuilder(
            future: _directoryScannerFuture,
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              return Column(
                children: [
                  BiocentralFilePathSelection(
                    defaultName: _configFile?.name ?? '/path/to/config_file',
                    allowedExtensions: ['.yml', '.yaml'],
                    fileSelectedCallback: (xFile, path) => setState(() {
                      _configFile = xFile;
                    }),
                  ),
                  const SizedBox(height: 16.0,),
                  BiocentralFilePathSelection(
                    defaultName: _outputFile?.name ?? '/path/to/output_file',
                    allowedExtensions: ['.yml', '.yaml'],
                    fileSelectedCallback: (xFile, path) => setState(() {
                      _outputFile = xFile;
                    }),
                  ),
                  const SizedBox(height: 16.0,),
                  BiocentralFilePathSelection(
                    defaultName: _loggingFile?.name ?? '/path/to/logging_file',
                    allowedExtensions: ['.log'],
                    fileSelectedCallback: (xFile, path) => setState(() {
                      _loggingFile = xFile;
                    }),
                  ),
                  const SizedBox(height: 16.0,),
                  BiocentralFilePathSelection(
                    defaultName: _checkpointFile?.name ?? 'path/to/checkpoint_file',
                    allowedExtensions: ['.safetensors', '.pt', '.onnx'],
                    fileSelectedCallback: (xFile, path) => setState(() {
                      _checkpointFile = xFile;
                    }),
                  ),
                ],
              );
            },
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
