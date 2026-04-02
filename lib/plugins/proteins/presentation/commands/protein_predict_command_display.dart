import 'package:biocentral/plugins/proteins/bloc/proteins_commands.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_database_update_display.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_file_path_selection.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProteinPredictCommandDisplay extends StatefulWidget {
  const ProteinPredictCommandDisplay({super.key});

  @override
  State<ProteinPredictCommandDisplay> createState() => _ProteinPredictCommandDisplayState();
}

class _ProteinPredictCommandDisplayState extends State<ProteinPredictCommandDisplay> {
  final Set<String> _selectedModels = {};
  DatabaseImportMode _importMode = DatabaseImportMode.defaultMode;

  late Future<List<ModelMetadata>> _metaDataFuture;

  @override
  void initState() {
    super.initState();
    _metaDataFuture = queryModelMetadata(context.read());
  }

  ProteinPredictCommand? collectCommand() {
    if (_selectedModels.isNotEmpty) {
      return ProteinPredictCommand(
        biocentralProjectRepository: context.read(),
        proteinRepository: context.read(),
        apiRepository: context.read(),
        selectedModels: _selectedModels,
        importMode: _importMode,
      );
    }
    return null;
  }

  Future<List<ModelMetadata>> queryModelMetadata(BiocentralAPIRepository apiRepository) async {
    try {
      final biocentralAPI = apiRepository.getBiocentralAPI();
      final metadata = await biocentralAPI.getModelMetadata();
      return metadata ?? [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final BiocentralAPIRepository apiRepository = context.read();
    return StreamBuilder(
      initialData: apiRepository.currentHealth,
      stream: apiRepository.healthStatusStream,
      builder: (context, asyncSnapshot) {
        final currentHealth = asyncSnapshot.data ?? [];
        final availability = BiocentralCommandAvailability.fromHealth(currentHealth);
        return BiocentralCommandWidget(
          icon: const Icon(Icons.batch_prediction_outlined),
          name: 'Predict protein features',
          description: 'Use AI models to retrieve protein features for your dataset',
          executeButtonLabel: 'Predict',
          parameterSelection: buildParameterSelection,
          collectCommand: collectCommand,
          visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
          commandAvailability: availability,
        );
      },
    );
  }

  Widget buildParameterSelection() {
    final BiocentralAPIRepository apiRepository = context.read();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          FutureBuilder(
            future: _metaDataFuture,
            builder: (context, asyncSnapshot) {
              final modelMetadata = asyncSnapshot.data ?? [];
              return buildModelSelection(apiRepository, modelMetadata);
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

  String formatModelName(String modelName) {
    final firstLetter = modelName.characters.first;
    return firstLetter.toUpperCase() + modelName.substring(1);
  }

  Widget buildModelSelection(BiocentralAPIRepository apiRepository, List<ModelMetadata> modelMetadata) {
    if (modelMetadata.isEmpty) {
      return Column(
        children: [
          const Text('Could not receive any model metadata!'),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _metaDataFuture = queryModelMetadata(apiRepository);
              });
            },
            label: const Text('Retry'),
            icon: const Icon(Icons.refresh),
          )
        ],
      );
    }
    return Column(
      children: modelMetadata
          .map<CheckboxListTile>(
            (metadata) => CheckboxListTile(
              title: Text(formatModelName(metadata.name.name)),
              subtitle: Text('${metadata.description}\nEmbedder: ${metadata.embedder}'),
              value: _selectedModels.contains(metadata.name.name),
              onChanged: (bool? value) {
                value ??= false;
                setState(() {
                  if (value!) {
                    _selectedModels.add(metadata.name.name);
                  } else {
                    _selectedModels.remove(metadata.name.name);
                  }
                });
              },
            ),
          )
          .toList(),
    );
  }
}
