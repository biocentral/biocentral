import 'package:biocentral/plugins/embeddings/bloc/embeddings_commands.dart';
import 'package:biocentral/plugins/embeddings/model/projection.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/model/biocentral_config.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_config_selection.dart';
import 'package:biocentral/sdk/util/library_extensions_util.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalculateProjectionCommandDisplay extends StatefulWidget {
  const CalculateProjectionCommandDisplay({super.key});

  @override
  State<CalculateProjectionCommandDisplay> createState() => _CalculateProjectionCommandDisplayState();
}

class _CalculateProjectionCommandDisplayState extends State<CalculateProjectionCommandDisplay> {
  CommonEmbedder? _selectedEmbedder;

  Future<Map<String, BiocentralConfig>>? _configsFuture;
  String? _selectedMethod;
  Map<String, BiocentralConfig> _projectionConfigByMethod = {};

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, BiocentralConfig>> loadConfigs(BiocentralAPIRepository apiRepository) async {
    final projectionConfig = await apiRepository.getBiocentralAPI().projectionConfig();
    if (projectionConfig == null) {
      return {};
    }
    final mappedProjectionConfig = Map<String, List<BiocentralConfigOption>>.fromEntries(
      projectionConfig
          .map(
            (method, options) => MapEntry(
              method,
              List<BiocentralConfigOption>.from(
                options.map((option) => BiocentralConfigOption.deserialize(option?.asMap ?? {})),
              ),
            ),
          )
          .entries,
    );
    final configs = Map.fromEntries(
      mappedProjectionConfig.entries.map(
        (entry) => MapEntry(
          entry.key,
          BiocentralConfig(
            options: entry.value,
            // TODO configHandler: BiocentralGenericConfigHandler(JSONConfigHandlingStrategy()),
          ),
        ),
      ),
    );
    return configs;
  }

  CalculateProjectionsCommand? collectCommand() {
    if (_selectedEmbedder != null && _selectedMethod != null && _projectionConfigByMethod[_selectedMethod] != null) {
      return CalculateProjectionsCommand(
        biocentralProjectRepository: context.read(),
        apiRepository: context.read(),
        biocentralDatabaseRepository: context.read(),
        projectionsRepository: context.read(),
        embedderName: _selectedEmbedder!.wireName,
        projectionMethod: _selectedMethod!,
        projectionConfig: _projectionConfigByMethod[_selectedMethod]!.asStringMap(),
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
        final availability = BiocentralCommandAvailability.fromHealth(currentHealth);
        if (availability.available) {
          _configsFuture = loadConfigs(apiRepository);
        }
        return BiocentralCommandWidget(
          icon: const Icon(Icons.auto_graph),
          name: 'Calculate projection',
          description: 'Use a projection method to visualize your embeddings in space',
          executeButtonLabel: 'Calculate',
          parameterSelection: buildParameterSelection,
          collectCommand: collectCommand,
          visualizeResult: buildProjectionResultDisplay,
          commandAvailability: availability,
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
          buildProjectionConfigSelection(),
        ].withPadding(
          const Padding(
            padding: EdgeInsetsGeometry.all(8.0),
          ),
        ),
      ),
    );
  }

  Widget buildProjectionConfigSelection() {
    return FutureBuilder(
      future: _configsFuture,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (asyncSnapshot.hasData && asyncSnapshot.data != null && _projectionConfigByMethod.isEmpty) {
          _projectionConfigByMethod = asyncSnapshot.data!;
        }
        final maybeSelectedConfig = _projectionConfigByMethod[_selectedMethod];
        return Column(
          children: [
            BiocentralDiscreteSelection(
              title: 'Select Method',
              initialValue: _selectedMethod,
              selectableValues: _projectionConfigByMethod.keys.toList(),
              displayConversion: (method) => method.toUpperCase(),
              onChangedCallback: (String? value) => setState(() {
                _selectedMethod = value;
              }),
            ),
            if (maybeSelectedConfig != null)
              BiocentralConfigSelection(
                label: _selectedMethod,
                config: maybeSelectedConfig,
                onConfigChanged: (BiocentralConfig config) {
                  setState(() {
                    _projectionConfigByMethod[_selectedMethod!] = config;
                  });
                },
              ),
          ],
        );
      },
    );
  }

  Widget buildProjectionResultDisplay(BiocentralCommandLog result) {
    final commandResult = result.result?.result;
    if (commandResult == null || commandResult is! List<Projection>) {
      // TODO ERROR HANDLING
      return BiocentralStatusIndicator(metaData: result.metaData);
    }
    // TODO Handle multiple projections
    final projection = commandResult.first;
    return DataTable(
      columns: [
        const DataColumn(label: Text('Key')),
        const DataColumn(label: Text('Value')),
      ],
      rows: [
        DataRow(cells: [const DataCell(Text('ID')), DataCell(Text(projection.id))]),
        DataRow(
            cells: [const DataCell(Text('# Points')), DataCell(Text(projection.data.coordinates.length.toString()))]),
        ...projection.config.entries
            .map((entry) => DataRow(cells: [DataCell(Text(entry.key)), DataCell(Text(entry.value))])),
      ],
    );
  }
}
