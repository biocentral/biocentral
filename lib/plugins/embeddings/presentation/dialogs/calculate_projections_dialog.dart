import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/bloc/calculate_projections_dialog_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/model/biocentral_config_option.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_config_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalculateProjectionsDialog extends StatefulWidget {
  final void Function(String embedderName, Map<String, PerSequenceEmbedding> embeddings, String projectionMethod,
      Map<BiocentralConfigOption, dynamic> projectionConfig, DatabaseImportMode importMode) calculateUMAPCallback;

  const CalculateProjectionsDialog({required this.calculateUMAPCallback, super.key});

  @override
  State<CalculateProjectionsDialog> createState() => _CalculateProjectionsDialogState();
}

class _CalculateProjectionsDialogState extends State<CalculateProjectionsDialog> {
  String? _selectedMethod;
  dynamic _currentProjectionConfig;

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
      if (embeddings != null && _selectedMethod != null && _currentProjectionConfig != null) {
        closeDialog();
        widget.calculateUMAPCallback(
          state.selectedEmbedderName!,
          embeddings,
          _selectedMethod!,
          _currentProjectionConfig!,
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
    final CalculateProjectionsDialogBloc calculateProjectionsDialogBloc =
        BlocProvider.of<CalculateProjectionsDialogBloc>(context);

    return BlocBuilder<CalculateProjectionsDialogBloc, CalculateProjectionsDialogState>(
      builder: (context, state) => BiocentralDialog(
        children: [
          Text(
            'Calculate projections for embeddings',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          buildEntityTypeSelection(calculateProjectionsDialogBloc),
          buildEmbedderSelection(calculateProjectionsDialogBloc, state),
          buildEmbeddingsTypeSelection(calculateProjectionsDialogBloc, state),
          buildConfigSelection(state),
          buildImportModeSelection(calculateProjectionsDialogBloc),
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

  Widget buildEntityTypeSelection(CalculateProjectionsDialogBloc calculateProjectionsDialogBloc) {
    return BiocentralEntityTypeSelection(
      onChangedCallback: (selectedType) {
        calculateProjectionsDialogBloc.add(CalculateProjectionsDialogSelectEntityTypeEvent(selectedType));
      },
    );
  }

  Widget buildEmbedderSelection(
      CalculateProjectionsDialogBloc calculateProjectionsDialogBloc, CalculateProjectionsDialogState state) {
    if (state.embeddingsColumnWizard == null || state.embeddingsColumnWizard!.getAllEmbedderNames().isEmpty) {
      return const Text('Could not find any embeddings!');
    }
    return BiocentralDiscreteSelection(
      title: 'Embedder: ',
      selectableValues: state.embeddingsColumnWizard!.getAllEmbedderNames().toList(),
      direction: Axis.vertical,
      onChangedCallback: (String? value) {
        calculateProjectionsDialogBloc.add(CalculateProjectionsDialogUpdateUIEvent({value}));
      },
    );
  }

  Widget buildEmbeddingsTypeSelection(
      CalculateProjectionsDialogBloc calculateProjectionsDialogBloc, CalculateProjectionsDialogState state) {
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
        calculateProjectionsDialogBloc.add(CalculateProjectionsDialogUpdateUIEvent({value}));
      },
    );
  }

  Widget buildConfigSelection(CalculateProjectionsDialogState state) {
    if (state.projectionConfig.isEmpty) {
      return Container();
    }
    return BiocentralConfigSelection(
      optionMap: state.projectionConfig,
      onConfigChangedCallback: (String? selectedMethod, Map<String, Map<BiocentralConfigOption, dynamic>>? config) {
        _selectedMethod = selectedMethod;
        _currentProjectionConfig = config?[_selectedMethod];
      },
    );
  }

  Widget buildImportModeSelection(CalculateProjectionsDialogBloc calculateProjectionsDialogBloc) {
    return BiocentralImportModeSelection(
      onChangedCallback: (DatabaseImportMode? value) {
        calculateProjectionsDialogBloc.add(CalculateProjectionsDialogUpdateUIEvent({value}));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
