import 'package:biocentral/plugins/embeddings/bloc/embeddings_commands.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/plugins/embeddings/presentation/displays/embeddings_file_display.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadEmbeddingsCommandDisplay extends StatefulWidget {
  const LoadEmbeddingsCommandDisplay({super.key});

  @override
  State<LoadEmbeddingsCommandDisplay> createState() => _LoadEmbeddingsCommandDisplayState();
}

class _LoadEmbeddingsCommandDisplayState extends State<LoadEmbeddingsCommandDisplay> {
  XFile? _result;
  EmbeddingsFileInformation? _info;

  Future<void> _statsFuture = Future.value({});

  final TextEditingController _embedderNameController = TextEditingController();

  EmbeddingsFileLoadMode _loadMode = EmbeddingsFileLoadMode.defaultMode;
  DatabaseImportMode _importMode = DatabaseImportMode.defaultMode;

  LoadEmbeddingsFromFileCommand? collectCommand() {
    if (_result != null && _info != null && _embedderNameController.text.isNotEmpty) {
      final embeddingsFile =
          EmbeddingsFile(path: _result!.path, embedderName: _embedderNameController.text, fileInformation: _info!);
      return LoadEmbeddingsFromFileCommand(
        biocentralProjectRepository: context.read(),
        embeddingsRepository: context.read(),
        pythonCompanion: context.read(),
        xFile: _result!,
        preloadedFile: embeddingsFile,
        loadMode: _loadMode,
        importMode: _importMode,
      );
    }
    return null;
  }

  Future<void> getEmbeddingsFileInfo() async {
    if (_result != null) {
      if (mounted) {
        final pythonCompanion = context.read<BiocentralPythonCompanion>();
        final info = await pythonCompanion.getH5Info(_result!.path);
        info.match(
          (l) => logger.e(l.message),
          (r) {
            _info = r;
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandWidget(
      icon: const Icon(Icons.file_open),
      name: 'Load embeddings from h5 file',
      description: 'Load new embeddings data from a file',
      executeButtonLabel: 'Load',
      parameterSelection: buildParameterSelection,
      collectCommand: collectCommand,
      visualizeResult: EmbeddingsFileDisplay.visualizeEmbeddingsFileResult,
      commandAvailability: BiocentralCommandAvailability.always(),
    );
  }

  Widget buildParameterSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          BiocentralFilePathSelection(
            defaultName: _result?.name ?? '/path/to/h5',
            allowedExtensions: ['h5'],
            fileSelectedCallback: (xFile, path) => setState(() {
              _result = xFile;
              setState(() {
                _statsFuture = getEmbeddingsFileInfo();
                if (_embedderNameController.text.isEmpty && xFile?.name != null) {
                  _embedderNameController.text = xFile!.name;
                }
              });
            }),
          ),
          BiocentralDiscreteSelection(
            title: 'Select Load Mode',
            initialValue: _loadMode,
            selectableValues: EmbeddingsFileLoadMode.values,
            displayConversion: (mode) => mode.name.capitalize(),
            onChangedCallback: (loadMode) {
              setState(() {
                _loadMode = loadMode ?? _loadMode;
              });
            },
          ),
          BiocentralImportModeSelection(
            onChangedCallback: (importMode) => setState(() {
              _importMode = importMode ?? DatabaseImportMode.defaultMode;
            }),
          ),
          buildEmbedderNaming(),
          visualizeEmbeddingsFileInformation(),
        ].withPadding(
          const Padding(
            padding: EdgeInsetsGeometry.all(8.0),
          ),
        ),
      ),
    );
  }

  Widget visualizeEmbeddingsFileInformation() {
    return FutureBuilder(
      future: _statsFuture,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return EmbeddingsFileDisplay(file: _result, information: _info);
      },
    );
  }

  Widget buildEmbedderNaming() {
    return TextFormField(
      controller: _embedderNameController,
      decoration: const InputDecoration(labelText: 'Embedder Name'),
    );
  }
}
