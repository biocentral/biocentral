import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/bloc/calculate_umap_dialog_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalculateUMAPDialog extends StatefulWidget {
  final void Function(String embedderName, Map<String, PerSequenceEmbedding> embeddings, DatabaseImportMode importMode)
      calculateUMAPCallback;

  const CalculateUMAPDialog({required this.calculateUMAPCallback, super.key});

  @override
  State<CalculateUMAPDialog> createState() => _CalculateUMAPDialogState();
}

class _CalculateUMAPDialogState extends State<CalculateUMAPDialog> {
  @override
  void initState() {
    super.initState();
  }

  void doUMAP(CalculateUMAPDialogState state) async {
    if (state.selectedEmbedderName != null &&
        state.selectedEmbeddingType != null &&
        state.embeddingsColumnWizard != null) {
      final Map<String, PerSequenceEmbedding>? embeddings =
          state.embeddingsColumnWizard!.perSequenceByEmbedderName(state.selectedEmbedderName);
      if (embeddings != null) {
        closeDialog();
        widget.calculateUMAPCallback(
          state.selectedEmbedderName!,
          embeddings,
          state.selectedImportMode ?? DatabaseImportMode.defaultMode,
        );
      }
    }
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final CalculateUMAPDialogBloc calculateUMAPDialogBloc = BlocProvider.of<CalculateUMAPDialogBloc>(context);

    return BlocBuilder<CalculateUMAPDialogBloc, CalculateUMAPDialogState>(
      builder: (context, state) => BiocentralDialog(
        children: [
          Text(
            'Calculate UMAPs for embeddings',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          buildEntityTypeSelection(calculateUMAPDialogBloc),
          buildEmbedderSelection(calculateUMAPDialogBloc, state),
          buildEmbeddingsTypeSelection(calculateUMAPDialogBloc, state),
          buildImportModeSelection(calculateUMAPDialogBloc),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BiocentralSmallButton(
                label: 'Calculate',
                onTap: () => doUMAP(state),
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

  Widget buildEntityTypeSelection(CalculateUMAPDialogBloc calculateUMAPDialogBloc) {
    return BiocentralEntityTypeSelection(
      onChangedCallback: (selectedType) {
        calculateUMAPDialogBloc.add(CalculateUMAPDialogSelectEntityTypeEvent(selectedType));
      },
    );
  }

  Widget buildEmbedderSelection(CalculateUMAPDialogBloc calculateUMAPDialogBloc, CalculateUMAPDialogState state) {
    if (state.embeddingsColumnWizard == null || state.embeddingsColumnWizard!.getAllEmbedderNames().isEmpty) {
      return const Text('Could not find any embeddings!');
    }
    return BiocentralDiscreteSelection(
      title: 'Embedder: ',
      selectableValues: state.embeddingsColumnWizard!.getAllEmbedderNames().toList(),
      direction: Axis.vertical,
      onChangedCallback: (String? value) {
        calculateUMAPDialogBloc.add(CalculateUMAPDialogUpdateUIEvent({value}));
      },
    );
  }

  Widget buildEmbeddingsTypeSelection(CalculateUMAPDialogBloc calculateUMAPDialogBloc, CalculateUMAPDialogState state) {
    if (state.embeddingsColumnWizard == null ||
        state.embeddingsColumnWizard!.getAllEmbedderNames().isEmpty ||
        state.selectedEmbedderName == null) {
      return Container();
    }
    return BiocentralDiscreteSelection(
      title: 'Embeddings Type:',
      selectableValues: const [EmbeddingType.perSequence], // TODO Only perSequence at the moment
      displayConversion: (type) => type.name,
      onChangedCallback: (EmbeddingType? value) {
        calculateUMAPDialogBloc.add(CalculateUMAPDialogUpdateUIEvent({value}));
      },
    );
  }

  Widget buildImportModeSelection(CalculateUMAPDialogBloc calculateUMAPDialogBloc) {
    return BiocentralImportModeSelection(
      onChangedCallback: (DatabaseImportMode? value) {
        calculateUMAPDialogBloc.add(CalculateUMAPDialogUpdateUIEvent({value}));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
