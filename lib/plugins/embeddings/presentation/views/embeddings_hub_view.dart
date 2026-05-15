import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/bloc/embeddings_hub_bloc.dart';
import 'package:biocentral/plugins/embeddings/data/protspace_api.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class EmbeddingsHubView extends StatefulWidget {
  final List<Widget> commandWidgets;

  const EmbeddingsHubView({required this.commandWidgets, super.key});

  @override
  State<EmbeddingsHubView> createState() => _EmbeddingsHubViewState();
}

class _EmbeddingsHubViewState extends State<EmbeddingsHubView> with AutomaticKeepAliveClientMixin {
  final WidgetsToImageController projectionImageController = WidgetsToImageController();

  String? _selectedEmbedder;
  EmbeddingType _selectedType = EmbeddingType.perSequence;
  String? _selectedKey;

  @override
  bool get wantKeepAlive => true;

  Future<void> handleProtspaceVisualization(
      BiocentralProjectRepository projectRepository, EmbeddingsHubState state) async {
    final features = Map.fromEntries(state.getPointData().map((data) => MapEntry(data['id'] ?? 'idx-error', data)));
    final saveEither = await projectRepository.handleProjectInternalSave(
      fileName: 'protspace.html',
      type: ProjectionData,
      contentFunction: () async =>
          ProtspaceFileHandler.createProtspaceHTML(projections: state.projections, features: features),
    );
    saveEither.match((saveError) {}, (fullPath) {
      final url = 'file://$fullPath';
      launchUrlString(url);
    });
  }

  void handleProjectionImageSave(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) async {
    if (state.projections.isNotEmpty) {
      final imageBytes = await projectionImageController.capturePng(pixelRatio: 3.0);
      embeddingsHubBloc.add(EmbeddingsHubSaveProjectionPlotEvent(imageBytes));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final EmbeddingsHubBloc embeddingsHubBloc = BlocProvider.of<EmbeddingsHubBloc>(context);

    return DefaultTabController(
      length: 3,
      child: BlocConsumer<EmbeddingsHubBloc, EmbeddingsHubState>(
        listener: (context, state) {
          final availableEmbedders = state.dto?.getAvailableEmbedders() ?? [];
          if (_selectedEmbedder == null && availableEmbedders.isNotEmpty) {
            setState(() {
              _selectedEmbedder = availableEmbedders.first;
            });
          }
          final availableTypes = state.dto?.getAvailableTypesByEmbedder(_selectedEmbedder) ?? {};
          if (availableTypes.length == 1) {
            setState(() {
              _selectedType = availableTypes.first;
            });
          }
        },
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
                          const Tab(icon: Icon(Icons.visibility), text: 'Visualizations'),
                          const Tab(icon: Icon(Icons.zoom_in), text: 'Details'),
                          const Tab(icon: Icon(Icons.insert_chart), text: 'Commands'),
                        ],
                      ),
                    ],
                  ),
                ),
                // TabBarView
                Expanded(
                  child: TabBarView(
                    children: [
                      buildProjectionVisualizations(embeddingsHubBloc, state),
                      buildEmbeddingDetailView(embeddingsHubBloc, state),
                      BiocentralCommandView(commandWidgets: widget.commandWidgets),
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
    final selected = state.dto?.byType(_selectedType)[_selectedEmbedder]?[_selectedKey];
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 8,
          ),
          Flexible(child: buildKeySelection(embeddingsHubBloc, state)),
          const SizedBox(
            height: 8,
          ),
          buildEmbeddingMetaDataDisplay(selected?.metaData),
          Flexible(child: buildSingleEmbedding(selected)),
          const SizedBox(
            height: 8,
          ),
          //Flexible(child: buildBasicEmbeddingStats(embeddingsHubBloc, state)),
        ],
      ),
    );
  }

  Widget buildEntityTypeSelection(EmbeddingsHubBloc embeddingsHubBloc) {
    return BiocentralEntityTypeSelection(
      onChangedCallback: (selectedType) {
        embeddingsHubBloc.add(EmbeddingsHubSelectEntityTypeEvent(selectedType));
      },
    );
  }

  Widget buildEmbedderSelection(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.dto == null || state.dto!.isEmpty()) {
      return const Text('Could not find any embeddings!');
    }
    final availableEmbedders = state.dto?.getAvailableEmbedders() ?? [];
    return BiocentralDropdownMenu<String>(
      initialSelection: _selectedEmbedder,
      dropdownMenuEntries: availableEmbedders
          .map((embedderName) => DropdownMenuEntry(value: embedderName, label: embedderName))
          .toList(),
      label: const Text('Select embedder..'),
      onSelected: (String? embedderName) {
        setState(() {
          _selectedEmbedder = embedderName;
        });
      },
    );
  }

  Widget buildEmbeddingsTypeSelection(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.dto == null || _selectedEmbedder == null) {
      return Container();
    }
    final availableTypes = state.dto?.getAvailableTypesByEmbedder(_selectedEmbedder) ?? {};
    return BiocentralDropdownMenu<EmbeddingType>(
      dropdownMenuEntries: availableTypes
          .map((embeddingType) => DropdownMenuEntry(value: embeddingType, label: embeddingType.name))
          .toList(),
      label: const Text('Select embedding type..'),
      onSelected: (EmbeddingType? embeddingType) {
        setState(() {
          _selectedType = embeddingType ?? _selectedType;
        });
      },
    );
  }

  Widget buildKeySelection(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.dto == null || _selectedEmbedder == null) {
      return Container();
    }
    final availableKeys = state.dto?.byType(_selectedType)[_selectedEmbedder]?.keys ?? [];
    return BiocentralDropdownMenu<String>(
      initialSelection: _selectedKey,
      dropdownMenuEntries: availableKeys.map((key) => DropdownMenuEntry(value: key, label: key)).toList(),
      label: const Text('Select embedding to inspect..'),
      onSelected: (String? key) {
        setState(() {
          _selectedKey = key;
        });
      },
    );
  }

  Widget buildEmbeddingMetaDataDisplay(EmbeddingMetadata? metaData) {
    if (metaData == null) {
      return Container();
    }
    final columns = [
      const DataColumn(label: Text('Property')),
      const DataColumn(label: Text('Value')),
    ];
    final attributesRows = metaData.attributes.isEmpty
        ? [
            DataRow(
              cells: [
                const DataCell(Text('Attributes')),
                DataCell(Text(metaData.attributes.toString())),
              ],
            ),
          ]
        : metaData.attributes.entries
            .map((entry) => DataRow(cells: [DataCell(Text(entry.key)), DataCell(Text(entry.value.toString()))]));
    final rows = [
      DataRow(
        cells: [
          const DataCell(Text('Embedding Type')),
          DataCell(Text(metaData.embeddingType.name)),
        ],
      ),
      DataRow(
        cells: [
          const DataCell(Text('Dimension')),
          DataCell(Text(metaData.dimension.toString())),
        ],
      ),
      if (metaData.embeddingType == EmbeddingType.perResidue)
        DataRow(
          cells: [
            const DataCell(Text('Length')),
            DataCell(Text(metaData.length.toString())),
          ],
        ),
      ...attributesRows,
    ];

    return DataTable(columns: columns, rows: rows);
  }

  Widget buildSingleEmbedding(LazyEmbedding? embedding) {
    if (embedding == null) {
      return Container();
    }

    return SizedBox(
      width: SizeConfig.screenWidth(context),
      height: SizeConfig.screenHeight(context) * 0.1,
      child: FutureBuilder(
        future: embedding.getEmbedding(),
        builder: (context, asyncSnapshot) {
          if(asyncSnapshot.data == null) {
            return const CircularProgressIndicator();
          }
          final rawEmbeddingValues = asyncSnapshot.data?.rawValues();
          // TODO Visualizations based on embedding type / Error Handling
          if (rawEmbeddingValues == null || rawEmbeddingValues is! List<double>) {
            return Text(rawEmbeddingValues.toString());
          }
          return VectorVisualizer(
            vector: rawEmbeddingValues,
            name: '${embedding.key} - ${embedding.metaData.embeddingType.name}',
            // TODO Remove -1 in the future once visualization is improved
            decimalPlaces: Constants.maxDoublePrecision - 1,
          );
        },
      ),
    );
  }

  /*
  Widget buildBasicEmbeddingStats(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.embeddingsColumnWizard == null ||
        state.selectedEmbedderName == null ||
        state.selectedEmbeddingType == null) {
      return Container();
    }

    return FutureBuilder(
      future:
          state.embeddingsColumnWizard!.getEmbeddingStats(state.selectedEmbedderName!, state.selectedEmbeddingType!),
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
   */

  Widget buildProjectionVisualizations(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.projections.isEmpty) {
      return const Text('No projections available yet!');
    }

    final PageController pageController = PageController();
    final ValueNotifier<int> currentPage = ValueNotifier<int>(0);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header with total count
            Text(
              '${state.projections.length} Projection${state.projections.length > 1 ? 's' : ''} Available',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Action buttons - Fixed height
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => handleProtspaceVisualization(context.read(), state),
                  icon: const Icon(Icons.launch),
                  label: const Text('View on ProtSpace'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => handleProjectionImageSave(embeddingsHubBloc, state),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Image'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Navigation Controls - Compact
            ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (context, page, _) {
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        state.projections.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: page == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: page == index ? Colors.blue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Navigation Arrows
                    if (state.projections.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            onPressed: page > 0
                                ? () {
                                    pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                          ),
                          Text(
                            '${page + 1} / ${state.projections.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: page < state.projections.length - 1
                                ? () {
                                    pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Carousel - Takes up most of the screen
            SizedBox(
              height: SizeConfig.screenHeight(context) * 0.75, // Explicit height for the carousel
              child: PageView.builder(
                controller: pageController,
                itemCount: state.projections.length,
                onPageChanged: (index) {
                  currentPage.value = index;
                },
                itemBuilder: (context, index) {
                  final projection = state.projections[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Projection Title - Fixed height
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.analytics, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                projection.data.identifier,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Visualization - Takes remaining space
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: WidgetsToImage(
                                controller: projectionImageController,
                                child: ProjectionVisualizer2D(
                                  projectionData: projection.data,
                                  pointData: state.getPointData(),
                                  pointIdentifierKey: 'id',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
