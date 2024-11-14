import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/embeddings/bloc/calculate_embeddings_dialog_bloc.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';

class CalculateEmbeddingsDialog extends StatefulWidget {
  final void Function(PredefinedEmbedder predefinedEmbedder, EmbeddingType embeddingType, DatabaseImportMode importMode)
      calculateEmbeddingsCallback;

  const CalculateEmbeddingsDialog({required this.calculateEmbeddingsCallback, super.key});

  @override
  State<CalculateEmbeddingsDialog> createState() => _CalculateEmbeddingsDialogState();
}

class _CalculateEmbeddingsDialogState extends State<CalculateEmbeddingsDialog> {
  @override
  void initState() {
    super.initState();
  }

  void doEmbedding(CalculateEmbeddingsDialogState state) async {
    if (state.selectedEmbedder != null && state.selectedEmbeddingType != null) {
      closeDialog();

      // TODO CUSTOM EMBEDDER
      widget.calculateEmbeddingsCallback(state.selectedEmbedder!, state.selectedEmbeddingType!,
          state.selectedImportMode ?? DatabaseImportMode.defaultMode,);
    }
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final CalculateEmbeddingsDialogBloc calculateEmbeddingsDialogBloc =
        BlocProvider.of<CalculateEmbeddingsDialogBloc>(context);

    return BlocBuilder<CalculateEmbeddingsDialogBloc, CalculateEmbeddingsDialogState>(
      builder: (context, state) => BiocentralDialog(
        children: [
          Text(
            'Calculate embeddings for proteins',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Padding(
              padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal(context) * 2),
              child: buildPredefinedEmbedderDocs(state),),
          buildEmbedderSelection(calculateEmbeddingsDialogBloc),
          SizedBox(
            height: SizeConfig.safeBlockVertical(context) * 2,
          ),
          buildEmbeddingsTypeSelection(calculateEmbeddingsDialogBloc),
          buildImportModeSelection(calculateEmbeddingsDialogBloc),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BiocentralSmallButton(
                label: 'Calculate',
                onTap: () => doEmbedding(state),
              ),
              BiocentralSmallButton(
                label: 'Close',
                onTap: closeDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDocStringBox(String docString) {
    return SizedBox(
        height: SizeConfig.screenHeight(context) * 0.15,
        width: SizeConfig.screenWidth(context) * 0.8,
        child: SingleChildScrollView(
            child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.grey,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(docString),
                ),),),);
  }

  Widget buildPredefinedEmbedderDocs(CalculateEmbeddingsDialogState state) {
    String docString = '';
    if (state.selectedEmbedder != null) {
      docString = '\n${state.selectedEmbedder!.name}:\n\n${state.selectedEmbedder!.docs}\n';
    }
    return buildDocStringBox(docString);
  }

  Widget buildEmbedderSelection(CalculateEmbeddingsDialogBloc calculateEmbeddingsDialogBloc) {
    return BiocentralDiscreteSelection(
        title: 'Embedder: ',
        selectableValues: PredefinedEmbedderContainer.predefinedEmbedders(),
        displayConversion: (embedder) => embedder.name,
        direction: Axis.vertical,
        onChangedCallback: (PredefinedEmbedder? value) {
          calculateEmbeddingsDialogBloc.add(CalculateEmbeddingsDialogUpdateUIEvent({value}));
        },);
  }

  Widget buildEmbeddingsTypeSelection(CalculateEmbeddingsDialogBloc calculateEmbeddingsDialogBloc) {
    return BiocentralDiscreteSelection(
        title: 'Embeddings Type:',
        selectableValues: EmbeddingType.values,
        displayConversion: (type) => type.name,
        onChangedCallback: (EmbeddingType? value) {
          calculateEmbeddingsDialogBloc.add(CalculateEmbeddingsDialogUpdateUIEvent({value}));
        },);
  }

  Widget buildImportModeSelection(CalculateEmbeddingsDialogBloc calculateEmbeddingsDialogBloc) {
    return BiocentralImportModeSelection(onChangedCallback: (DatabaseImportMode? value) {
      calculateEmbeddingsDialogBloc.add(CalculateEmbeddingsDialogUpdateUIEvent({value}));
    },);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
