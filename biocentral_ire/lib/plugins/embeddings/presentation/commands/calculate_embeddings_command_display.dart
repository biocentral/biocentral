import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/bloc/embeddings_commands.dart';
import 'package:biocentral/plugins/embeddings/presentation/displays/embeddings_file_display.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/util/library_extensions_util.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalculateEmbeddingsCommandDisplay extends StatefulWidget {
  const CalculateEmbeddingsCommandDisplay({super.key});

  @override
  State<CalculateEmbeddingsCommandDisplay> createState() => _CalculateEmbeddingsCommandDisplayState();
}

class _CalculateEmbeddingsCommandDisplayState extends State<CalculateEmbeddingsCommandDisplay> {
  CommonEmbedder? _selectedEmbedder;
  EmbeddingType _selectedEmbeddingType = EmbeddingType.perSequence; // TODO Default
  DatabaseImportMode _importMode = DatabaseImportMode.defaultMode;

  CalculateEmbeddingsCommand? collectCommand() {
    if (_selectedEmbedder != null) {
      return CalculateEmbeddingsCommand(
        biocentralProjectRepository: context.read(),
        apiRepository: context.read(),
        biocentralDatabase: context.read<ProteinRepository>(),
        // TODO Generic
        pythonCompanion: context.read(),
        embeddingsRepository: context.read(),
        embeddingType: _selectedEmbeddingType,
        embedderName: _selectedEmbedder!.wireName,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final BiocentralAPIRepository apiRepository = context.read();

    return StreamBuilder(
      initialData: apiRepository.currentHealth,
      stream: apiRepository.healthStatusStream,
      builder: (context, asyncSnapshot) {
        final currentHealth = asyncSnapshot.data ?? [];
        return BiocentralCommandWidget(
          icon: const Icon(Icons.calculate),
          name: 'Calculate embeddings',
          description: 'Get meaningful representations for your data',
          executeButtonLabel: 'Calculate',
          parameterSelection: buildParameterSelection,
          collectCommand: collectCommand,
          visualizeResult: EmbeddingsFileDisplay.visualizeEmbeddingsFileResult,
          commandAvailability: BiocentralCommandAvailability.fromHealth(currentHealth),
        );
      },
    );
  }

  Widget buildParameterSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          BiocentralDiscreteSelection(
            title: 'Select Embedder Model',
            initialValue: _selectedEmbedder,
            selectableValues: CommonEmbedder.values.toList(),
            displayConversion: (embedder) => embedder.displayName(),
            onChangedCallback: (embedder) {
              setState(() {
                _selectedEmbedder = embedder ?? _selectedEmbedder;
              });
            },
          ),
          BiocentralDiscreteSelection(
            title: 'Select Mode (per-Residue or per-Sequence)',
            initialValue: _selectedEmbeddingType,
            selectableValues: EmbeddingType.values,
            displayConversion: (embdType) => embdType.displayName(),
            onChangedCallback: (embdType) {
              setState(() {
                _selectedEmbeddingType = embdType ?? _selectedEmbeddingType;
              });
            },
          ),
          BiocentralImportModeSelection(
            onChangedCallback: (importMode) => setState(() {
              _importMode = importMode ?? DatabaseImportMode.defaultMode;
            }),
          ),
        ].withPadding(
          const Padding(
            padding: EdgeInsetsGeometry.all(8.0),
          ),
        ),
      ),
    );
  }
}
