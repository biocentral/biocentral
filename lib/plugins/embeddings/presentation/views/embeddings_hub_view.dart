import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/embeddings_hub_bloc.dart';
import '../../model/embeddings_column_wizard.dart';

class EmbeddingsHubView extends StatefulWidget {
  const EmbeddingsHubView({super.key});

  @override
  State<EmbeddingsHubView> createState() => _EmbeddingsHubViewState();
}

class _EmbeddingsHubViewState extends State<EmbeddingsHubView> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    EmbeddingsHubBloc embeddingsHubBloc = BlocProvider.of<EmbeddingsHubBloc>(context);

    return BlocConsumer<EmbeddingsHubBloc, EmbeddingsHubState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              const Flexible(child: Center(child: Text("Embeddings Hub"))),
              Flexible(flex: 5, child: buildEntityTypeSelection(embeddingsHubBloc)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(flex: 1, child: buildEmbedderSelection(embeddingsHubBloc, state)),
                  Flexible(flex: 1, child: buildEmbeddingsTypeSelection(embeddingsHubBloc, state))
                ],
              ),
              const Spacer(),
              Flexible(flex: 1, child: buildEntityIDSelection(embeddingsHubBloc, state)),
              const Spacer(),
              Flexible(flex: 1, child: buildSingleEmbedding(embeddingsHubBloc, state)),
              const Spacer(),
              Flexible(flex: 3, child: buildBasicEmbeddingStats(embeddingsHubBloc, state)),
              const Spacer(),
              Flexible(flex: 3, child: buildUMAPs(state))
            ],
          ),
        );
      },
    );
  }

  Widget buildEntityTypeSelection(EmbeddingsHubBloc embeddingsHubBloc) {
    return BiocentralEntityTypeSelection(onChangedCallback: (selectedType) {
      embeddingsHubBloc.add(EmbeddingsHubLoadEvent(selectedType));
    });
  }

  Widget buildEmbedderSelection(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.embeddingsColumnWizard == null || state.embeddingsColumnWizard!.getAllEmbedderNames().isEmpty) {
      return const Text("Could not find any embeddings!");
    }
    return BiocentralDropdownMenu<String>(
        dropdownMenuEntries: state.embeddingsColumnWizard!
            .getAllEmbedderNames()
            .map((embedderName) => DropdownMenuEntry(value: embedderName, label: embedderName))
            .toList(),
        label: const Text("Select embedder.."),
        onSelected: (String? embedderName) {
          embeddingsHubBloc.add(EmbeddingsHubSelectEmbedderEvent(embedderName));
        });
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
        label: const Text("Select embedding type.."),
        onSelected: (EmbeddingType? embeddingType) {
          embeddingsHubBloc.add(EmbeddingsHubSelectEmbeddingTypeEvent(embeddingType));
        });
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
        label: const Text("Select embedding to inspect.."),
        onSelected: (String? entityID) {
          embeddingsHubBloc.add(EmbeddingsHubSelectEntityIDEvent(entityID));
        });
  }

  Widget buildSingleEmbedding(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.embeddingsColumnWizard == null ||
        state.selectedEmbedderName == null ||
        state.selectedEmbeddingType == null ||
        state.selectedEntityID == null ||
        state.selectedEntityID!.isEmpty) {
      return Container();
    }
    List<dynamic>? rawEmbeddingValues = state.embeddingsColumnWizard!.valueMap[state.selectedEntityID!]
        ?.getEmbedding(state.selectedEmbeddingType!, embedderName: state.selectedEmbedderName)
        ?.rawValues();

    // TODO Visualizations based on embedding type
    if (rawEmbeddingValues == null || rawEmbeddingValues is! List<double>) {
      return Text(rawEmbeddingValues.toString());
    }
    return SizedBox(
        width: SizeConfig.screenWidth(context) * 0.9,
        height: SizeConfig.screenHeight(context) * 0.2,
        child: VectorVisualizer(
          vector: rawEmbeddingValues,
          name: "${state.selectedEntityID} - PerSequenceEmbedding",
          decimalPlaces: Constants.maxDoublePrecision,
        ));
  }

  Widget buildBasicEmbeddingStats(EmbeddingsHubBloc embeddingsHubBloc, EmbeddingsHubState state) {
    if (state.embeddingsColumnWizard == null ||
        state.selectedEmbedderName == null ||
        state.selectedEmbeddingType == null) {
      return Container();
    }
    EmbeddingStats embeddingStats =
        state.embeddingsColumnWizard!.getEmbeddingStats(state.selectedEmbedderName!, state.selectedEmbeddingType!);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
              width: SizeConfig.screenWidth(context) * 0.9,
              height: SizeConfig.screenHeight(context) * 0.2,
              child: VectorVisualizer(
                vector: embeddingStats.mean.toList(),
                name: "Mean",
                decimalPlaces: Constants.maxDoublePrecision,
              )),
        )
      ],
    );
  }

  Widget buildUMAPs(EmbeddingsHubState state) {
    if (state.umapData == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: state.umapData!.entries
                .map((MapEntry<UMAPData, List<Map<String, String>>> mapEntry) => SizedBox(
                    width: SizeConfig.screenWidth(context) * 0.4,
                    height: SizeConfig.screenHeight(context) * 0.4,
                    child: UmapVisualizer(
                      umapData: mapEntry.key,
                      pointData: mapEntry.value,
                      pointIdentifierKey: "id",
                    )))
                .toList(),
          )),
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
    super.key,
    required this.vector,
    required this.name,
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
            '$name (N: ${vector.length})',
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
    super.key,
    required this.index,
    required this.value,
    required this.decimalPlaces,
    required this.width,
    required this.height,
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
