import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/bloc/embeddings_hub_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EmbeddingsHubView extends StatefulWidget {
  const EmbeddingsHubView({super.key});

  @override
  State<EmbeddingsHubView> createState() => _EmbeddingsHubViewState();
}

class _EmbeddingsHubViewState extends State<EmbeddingsHubView> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  void handleProtspaceVisualization(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if(state.protspaceURL != null) {
      launchUrlString(state.protspaceURL!);
    } else {
      embeddingsHubBloc.add(EmbeddingsHubVisualizeOnProtspaceEvent(state.projectionData));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final EmbeddingsHubBloc embeddingsHubBloc = BlocProvider.of<EmbeddingsHubBloc>(context);

    return DefaultTabController(
      length: 2,
      child: BlocConsumer<EmbeddingsHubBloc, EmbeddingsHubState>(
        listener: (context, state) {
          if(state.protspaceURL != null) {
            handleProtspaceVisualization(embeddingsHubBloc, state);
          }
        },
        listenWhen: (oldState, newState) => oldState.protspaceURL != newState.protspaceURL,
        builder: (context, state) {
          return Scaffold(
            body: Column(
              children: [
                // Custom AppBar
                Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Embeddings Hub',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildEntityTypeSelection(embeddingsHubBloc),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: buildEmbedderSelection(embeddingsHubBloc, state)),
                          Expanded(child: buildEmbeddingsTypeSelection(embeddingsHubBloc, state)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TabBar(
                        labelColor: Theme.of(context).colorScheme.onSurface,
                        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        tabs: [
                          const Tab(icon: Icon(Icons.zoom_in), text: 'Details'),
                          const Tab(icon: Icon(Icons.visibility), text: 'Visualizations'),
                        ],
                      ),
                    ],
                  ),
                ),
                // TabBarView
                Expanded(
                  child: TabBarView(
                    children: [
                      buildEmbeddingDetailView(embeddingsHubBloc, state),
                      buildProjectionVisualizations(embeddingsHubBloc, state),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildEmbeddingDetailView(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8,),
          Flexible(child: buildEntityIDSelection(embeddingsHubBloc, state)),
          const SizedBox(height: 8,),
          Flexible(child: buildSingleEmbedding(embeddingsHubBloc, state)),
          const SizedBox(height: 8,),
          Flexible(child: buildBasicEmbeddingStats(embeddingsHubBloc, state)),
        ],
      ),
    );
  }

  Widget buildEntityTypeSelection(EmbeddingsHubBloc embeddingsHubBloc) {
    return BiocentralEntityTypeSelection(onChangedCallback: (selectedType) {
      embeddingsHubBloc.add(EmbeddingsHubLoadEvent(selectedType));
    },);
  }

  Widget buildEmbedderSelection(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.embeddingsColumnWizard == null || state.embeddingsColumnWizard!.getAllEmbedderNames().isEmpty) {
      return const Text('Could not find any embeddings!');
    }
    return BiocentralDropdownMenu<String>(
      dropdownMenuEntries: state.embeddingsColumnWizard!
          .getAllEmbedderNames()
          .map((embedderName) => DropdownMenuEntry(value: embedderName, label: embedderName))
          .toList(),
      label: const Text('Select embedder..'),
      onSelected: (String? embedderName) {
        embeddingsHubBloc.add(EmbeddingsHubSelectEmbedderEvent(embedderName));
      },
    );
  }

  Widget buildEmbeddingsTypeSelection(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.embeddingsColumnWizard == null ||
        state.embeddingsColumnWizard!.getAllEmbedderNames().isEmpty ||
        state.selectedEmbedderName == null) {
      return Container();
    }
    return BiocentralDropdownMenu<EmbeddingType>(
      dropdownMenuEntries: state.embeddingsColumnWizard!
          .getAvailableEmbeddingTypesForEmbedder(state.selectedEmbedderName!)
          .map((embeddingType) => DropdownMenuEntry(value: embeddingType, label: embeddingType.name))
          .toList(),
      label: const Text('Select embedding type..'),
      onSelected: (EmbeddingType? embeddingType) {
        embeddingsHubBloc.add(EmbeddingsHubSelectEmbeddingTypeEvent(embeddingType));
      },
    );
  }

  Widget buildEntityIDSelection(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.embeddingsColumnWizard == null ||
        state.selectedEmbedderName == null ||
        state.selectedEmbeddingType == null) {
      return Container();
    }
    return BiocentralDropdownMenu<String>(
      dropdownMenuEntries: state.embeddingsColumnWizard!.valueMap.keys
          .map((entityID) => DropdownMenuEntry(value: entityID, label: entityID))
          .toList(),
      label: const Text('Select embedding to inspect..'),
      onSelected: (String? entityID) {
        embeddingsHubBloc.add(EmbeddingsHubSelectEntityIDEvent(entityID));
      },
    );
  }

  Widget buildSingleEmbedding(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.embeddingsColumnWizard == null ||
        state.selectedEmbedderName == null ||
        state.selectedEmbeddingType == null ||
        state.selectedEntityID == null ||
        state.selectedEntityID!.isEmpty) {
      return Container();
    }
    final List<dynamic>? rawEmbeddingValues = state.embeddingsColumnWizard!.valueMap[state.selectedEntityID!]
        ?.getEmbedding(state.selectedEmbeddingType!, embedderName: state.selectedEmbedderName)
        ?.rawValues();

    // TODO Visualizations based on embedding type
    if (rawEmbeddingValues == null || rawEmbeddingValues is! List<double>) {
      return Text(rawEmbeddingValues.toString());
    }
    return SizedBox(
      width: SizeConfig.screenWidth(context),
      height: SizeConfig.screenHeight(context) * 0.1,
      child: VectorVisualizer(
        vector: rawEmbeddingValues,
        name: '${state.selectedEntityID} - PerSequenceEmbedding',
        // TODO Remove -1 in the future once visualization is improved
        decimalPlaces: Constants.maxDoublePrecision - 1,
      ),
    );
  }

  Widget buildBasicEmbeddingStats(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.embeddingsColumnWizard == null ||
        state.selectedEmbedderName == null ||
        state.selectedEmbeddingType == null) {
      return Container();
    }

    return FutureBuilder(
      future: state.embeddingsColumnWizard!.getEmbeddingStats(state.selectedEmbedderName!, state.selectedEmbeddingType!),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final embeddingStats = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: SizeConfig.screenWidth(context),
                  height: SizeConfig.screenHeight(context) * 0.1,
                  child: VectorVisualizer(
                    vector: embeddingStats.mean.toList(),
                    name: 'Mean over all ${embeddingStats.numberOfEmbeddings} embeddings',
                    // TODO Remove -1 in the future once visualization is improved
                    decimalPlaces: Constants.maxDoublePrecision - 1,
                  ),
                ),
              ),
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget buildProjectionVisualizations(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.projectionData == null) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () => handleProtspaceVisualization(embeddingsHubBloc, state),
            icon: const Icon(Icons.launch),
            label: const Text('View on ProtSpace'),),
          const SizedBox(height: 20),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: state.projectionData!.entries
                  .map(
                    (MapEntry<ProjectionData, List<Map<String, dynamic>>> mapEntry) => SizedBox(
                      width: SizeConfig.screenWidth(context) * 0.4,
                      height: SizeConfig.screenHeight(context) * 0.4,
                      child: ProjectionVisualizer2D(
                        projectionData: mapEntry.key,
                        pointData:
                            mapEntry.value.map((m) => m.map((k, v) => MapEntry(k.toString(), v.toString()))).toList(),
                        pointIdentifierKey: 'id',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class VectorVisualizer extends StatelessWidget {
  final List<double> vector;
  final String name;
  final int decimalPlaces;
  final double cellWidth;
  final double cellHeight;

  const VectorVisualizer({
    required this.vector,
    required this.name,
    super.key,
    this.decimalPlaces = 4,
    this.cellWidth = 60,
    this.cellHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$name (Dimensions: ${vector.length})',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SizedBox(
          height: cellHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                vector.length,
                (index) => VectorElement(
                  index: index,
                  value: vector[index],
                  decimalPlaces: decimalPlaces,
                  width: cellWidth,
                  height: cellHeight,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VectorElement extends StatelessWidget {
  final int index;
  final double value;
  final int decimalPlaces;
  final double width;
  final double height;

  const VectorElement({
    required this.index,
    required this.value,
    required this.decimalPlaces,
    required this.width,
    required this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey.shade100 : Colors.grey.shade300,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '[$index]',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(decimalPlaces),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
