import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/bloc/calculate_projections_dialog_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_config_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalculateProjectionsDialog extends StatefulWidget {
  final void Function(String embedderName, Map<String, PerSequenceEmbedding> embeddings, DatabaseImportMode importMode)
      calculateUMAPCallback;

  const CalculateProjectionsDialog({required this.calculateUMAPCallback, super.key});

  @override
  State<CalculateProjectionsDialog> createState() => _CalculateProjectionsDialogState();
}

class _CalculateProjectionsDialogState extends State<CalculateProjectionsDialog> {
  @override
  void initState() {
    super.initState();
  }

  void doProjections(CalculateProjectionsDialogState state) async {
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
    final CalculateProjectionsDialogBloc calculateUMAPDialogBloc = BlocProvider.of<CalculateProjectionsDialogBloc>(context);

    return BlocBuilder<CalculateProjectionsDialogBloc, CalculateProjectionsDialogState>(
      builder: (context, state) => BiocentralDialog(
        children: [
          Text(
            'Calculate projections for embeddings',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          buildEntityTypeSelection(calculateUMAPDialogBloc),
          buildEmbedderSelection(calculateUMAPDialogBloc, state),
          buildEmbeddingsTypeSelection(calculateUMAPDialogBloc, state),
          buildConfigSelection(state),
          buildImportModeSelection(calculateUMAPDialogBloc),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BiocentralSmallButton(
                label: 'Calculate',
                onTap: () => doProjections(state),
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

  Widget buildEntityTypeSelection(CalculateProjectionsDialogBloc calculateUMAPDialogBloc) {
    return BiocentralEntityTypeSelection(
      onChangedCallback: (selectedType) {
        calculateUMAPDialogBloc.add(CalculateProjectionsDialogSelectEntityTypeEvent(selectedType));
      },
    );
  }

  Widget buildEmbedderSelection(CalculateProjectionsDialogBloc calculateUMAPDialogBloc, CalculateProjectionsDialogState state) {
    if (state.embeddingsColumnWizard == null || state.embeddingsColumnWizard!.getAllEmbedderNames().isEmpty) {
      return const Text('Could not find any embeddings!');
    }
    return BiocentralDiscreteSelection(
      title: 'Embedder: ',
      selectableValues: state.embeddingsColumnWizard!.getAllEmbedderNames().toList(),
      direction: Axis.vertical,
      onChangedCallback: (String? value) {
        calculateUMAPDialogBloc.add(CalculateProjectionsDialogUpdateUIEvent({value}));
      },
    );
  }

  Widget buildEmbeddingsTypeSelection(CalculateProjectionsDialogBloc calculateUMAPDialogBloc, CalculateProjectionsDialogState state) {
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
        calculateUMAPDialogBloc.add(CalculateProjectionsDialogUpdateUIEvent({value}));
      },
    );
  }

  Widget buildConfigSelection(CalculateProjectionsDialogState state) {
    if(state.projectionConfig.isEmpty) {
      return Container();
    }
    return BiocentralConfigSelection(optionMap: state.projectionConfig);
  }

  Widget buildImportModeSelection(CalculateProjectionsDialogBloc calculateUMAPDialogBloc) {
    return BiocentralImportModeSelection(
      onChangedCallback: (DatabaseImportMode? value) {
        calculateUMAPDialogBloc.add(CalculateProjectionsDialogUpdateUIEvent({value}));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
