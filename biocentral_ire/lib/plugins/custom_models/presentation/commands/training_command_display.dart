import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/custom_models/bloc/model_hub_bloc.dart';
import 'package:biocentral/plugins/custom_models/bloc/models_commands.dart';
import 'package:biocentral/plugins/custom_models/data/custom_models_service_api.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/domain/biocentral_database_column.dart';
import 'package:biocentral/sdk/model/biocentral_config.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_config_selection.dart';
import 'package:biocentral/sdk/util/library_extensions_util.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show FpdartOnMap;

class TrainModelCommandDisplay extends StatefulWidget {
  const TrainModelCommandDisplay({super.key});

  @override
  State<TrainModelCommandDisplay> createState() => _TrainModelCommandDisplayState();
}

class _TrainModelCommandDisplayState extends State<TrainModelCommandDisplay> {
  final Map<String, String> _availableSequences = {};
  final Set<BiocentralDatabaseColumn> _availableTargets = {};
  final Set<BiocentralDatabaseColumn> _availableSets = {};

  BiocentralDatabaseColumn? _selectedTargetColumn;
  BiocentralDatabaseColumn? _selectedSetColumn;
  CommonEmbedder? _selectedEmbedder;
  EmbeddingType? _selectedEmbeddingType;
  Protocol? _selectedProtocol;
  BiocentralConfig? _protocolConfig;

  Future<BiocentralConfig?>? _protocolConfigFuture;

  @override
  void initState() {
    super.initState();
    // TODO Generic repository, not robust to concurrent repository updates made during state is alive
    final proteinRepository = context.read<ProteinRepository>();
    final availableSequences = proteinRepository.getSequences();
    final availableTargetColumns = proteinRepository.getTrainableColumns();
    final availableSetColumns = proteinRepository.getSetColumns();
    _availableTargets.clear();
    _availableTargets.addAll(availableTargetColumns);
    _availableSets.clear();
    _availableSets.addAll(availableSetColumns);
    _availableSequences.clear();
    _availableSequences.addAll(availableSequences ?? {});
  }

  TrainModelCommand? collectCommand() {
    if (_selectedTargetColumn != null &&
        _selectedSetColumn != null &&
        _selectedEmbedder != null &&
        _selectedProtocol != null &&
        _protocolConfig != null) {
      final trainingConfiguration = _protocolConfig!.asStringMap();
      trainingConfiguration['protocol'] = _selectedProtocol!.wireName;
      trainingConfiguration['embedder_name'] = _selectedEmbedder!.wireName;
      final filteredConfig = trainingConfiguration.filter((v) => v != 'null');
      return TrainModelCommand(
        apiRepository: context.read(),
        biocentralDatabase: context.read<ProteinRepository>(),
        modelRepository: context.read(),
        targetColumn: _selectedTargetColumn!,
        setColumn: _selectedSetColumn!,
        trainingConfiguration: filteredConfig,
      );
    }
    return null;
  }

  Future<BiocentralConfig?> loadProtocolConfig(BiocentralAPIRepository apiRepository) async {
    if (_selectedProtocol == null) {
      return null;
    }
    final protocolConfig =
        await apiRepository.getBiocentralAPI().getConfigOptionsForProtocol(protocol: _selectedProtocol!.wireName);
    if (protocolConfig == null) {
      return null;
    }
    // TODO Improve biotrainer config options
    final biocentralConfigOptions =
        protocolConfig.map((option) => BiocentralConfigOption.deserialize(option.asMap)).toList();
    final options = filterBiotrainerOptionsForBiocentral(biocentralConfigOptions);
    final config = BiocentralConfig(
      options: options,
      // TODO configHandler: BiocentralGenericConfigHandler(JSONConfigHandlingStrategy()),
    );
    return config;
  }

  Set<Protocol> getPotentialProtocols() {
    if (_selectedTargetColumn == null) {
      return {};
    }
    final potentialProtocols = _selectedTargetColumn!.detectPotentialTrainingProtocols(sequences: _availableSequences);
    if (_selectedEmbeddingType == EmbeddingType.perSequence) {
      potentialProtocols.remove(Protocol.residuesToValue);
      potentialProtocols.remove(Protocol.residuesToClass);
    } else if (_selectedEmbeddingType == EmbeddingType.perResidue) {
      potentialProtocols.remove(Protocol.sequenceToClass);
      potentialProtocols.remove(Protocol.sequenceToValue);
    }
    return potentialProtocols;
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
          icon: const Icon(Icons.auto_graph),
          name: 'Train a new model',
          description: 'Train a new supervised model via biotrainer',
          executeButtonLabel: 'Train',
          parameterSelection: buildParameterSelection,
          collectCommand: collectCommand,
          visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
          commandAvailability: availability,
        );
      },
    );
  }

  Widget buildParameterSelection() {
    return BlocBuilder<ModelHubBloc, ModelHubState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              withCondition(condition: true, childFunction: () => buildTargetSelection()),
              withCondition(condition: _selectedTargetColumn != null, childFunction: () => buildSetSelection()),
              withCondition(condition: _selectedSetColumn != null, childFunction: () => buildEmbedderSelection()),
              withCondition(condition: _selectedEmbedder != null, childFunction: () => buildEmbeddingTypeSelection()),
              withCondition(condition: _selectedEmbeddingType != null, childFunction: () => buildProtocolSelection()),
              withCondition(condition: _selectedProtocol != null, childFunction: () => buildProtocolConfigSelection()),
            ].withPadding(
              const Padding(
                padding: EdgeInsetsGeometry.all(8.0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTargetSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('What do you want to predict?'),
        Flexible(
          child: BiocentralDropdownMenu<BiocentralDatabaseColumn>(
            label: const Text('Choose targets..'),
            initialSelection: _selectedTargetColumn,
            dropdownMenuEntries: _availableTargets
                .map(
                  (target) => DropdownMenuEntry<BiocentralDatabaseColumn>(
                    value: target,
                    label: target.name,
                    labelWidget: BiocentralTooltip(
                        message: 'Available values: ${target.numberNotNull}/${target.length}',
                        child: Text(target.name)),
                  ),
                )
                .toList(),
            onSelected: (BiocentralDatabaseColumn? value) {
              setState(() {
                _selectedTargetColumn = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildSetSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('What data split do you want to use?'),
        Flexible(
          child: BiocentralDropdownMenu<BiocentralDatabaseColumn>(
            label: const Text('Choose sets..'),
            initialSelection: _selectedSetColumn,
            dropdownMenuEntries: _availableSets
                .map(
                  (set) => DropdownMenuEntry<BiocentralDatabaseColumn>(
                    value: set,
                    label: set.name,
                    labelWidget: BiocentralTooltip(
                      message: set.formatAsSplitSets(),
                      child: Text(set.name),
                    ),
                  ),
                )
                .toList(),
            onSelected: (BiocentralDatabaseColumn? value) {
              setState(() {
                _selectedSetColumn = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildEmbedderSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Which embedder model do you want to use?'),
        Flexible(
          child: BiocentralDiscreteSelection(
            title: 'Select Embedder Model',
            initialValue: _selectedEmbedder,
            selectableValues: CommonEmbedder.values.toList(),
            displayConversion: (embedder) => embedder.displayName(),
            onChangedCallback: (embedder) {
              setState(() {
                _selectedEmbedder = embedder;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildEmbeddingTypeSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Which type of embeddings do you want to use?'),
        const SizedBox(
          height: 20,
        ),
        Flexible(
          child: BiocentralDiscreteSelection(
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
        ),
      ],
    );
  }

  Widget buildProtocolSelection() {
    final apiRepository = context.read<BiocentralAPIRepository>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('What protocol do you want to use?'),
        const SizedBox(
          height: 8,
        ),
        Flexible(
          child: BiocentralDiscreteSelection(
            title: 'Prediction Protocol',
            initialValue: _selectedProtocol,
            selectableValues: getPotentialProtocols().toList(),
            displayConversion: (protocol) => protocol.trainingType(),
            onChangedCallback: (protocol) {
              setState(() {
                _selectedProtocol = protocol;
                _protocolConfigFuture = loadProtocolConfig(apiRepository);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildProtocolConfigSelection() {
    return FutureBuilder(
      future: _protocolConfigFuture,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final protocolConfig = asyncSnapshot.data;
        if (protocolConfig == null || _selectedProtocol == null) {
          // TODO ERROR HANDLING
          return const Text("ERROR: COULD NOT RETRIEVE CONFIG!");
        }
        _protocolConfig = protocolConfig;
        return Column(
          children: [
            const Text('Adjust training configuration'),
            BiocentralConfigSelection(
              label: _selectedProtocol?.trainingType(),
              config: protocolConfig,
              clusterByCategories: true,
              onConfigChanged: (BiocentralConfig config) {
                setState(() {
                  _protocolConfig = config;
                });
              },
            ),
          ],
        );
      },
    );
  }
}
