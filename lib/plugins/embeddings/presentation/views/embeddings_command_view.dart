import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/calculate_embeddings_dialog_bloc.dart';
import '../../bloc/calculate_umap_dialog_bloc.dart';
import '../../bloc/embeddings_command_bloc.dart';
import '../../data/predefined_embedders.dart';
import '../../domain/embeddings_repository.dart';
import '../dialogs/calculate_embeddings_dialog.dart';
import '../dialogs/calculate_umap_dialog.dart';

class EmbeddingsCommandView extends StatefulWidget {
  const EmbeddingsCommandView({super.key});

  @override
  State<EmbeddingsCommandView> createState() => _EmbeddingsCommandViewState();
}

class _EmbeddingsCommandViewState extends State<EmbeddingsCommandView> {
  @override
  void initState() {
    super.initState();
  }

  void openCalculateEmbeddingsDialog(EmbeddingsCommandBloc embeddingsCommandBloc) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => CalculateEmbeddingsDialogBloc(),
            child: CalculateEmbeddingsDialog(calculateEmbeddingsCallback:
                (PredefinedEmbedder predefinedEmbedder, EmbeddingType embeddingType, DatabaseImportMode importMode) {
              embeddingsCommandBloc
                  .add(EmbeddingsCommandCalculateEmbeddingsEvent(predefinedEmbedder, embeddingType, importMode));
            }),
          );
        });
  }

  void openCalculateUMAPDialog(EmbeddingsCommandBloc embeddingsCommandBloc) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => CalculateUMAPDialogBloc(context.read<EmbeddingsRepository>()),
            child: CalculateUMAPDialog(calculateUMAPCallback:
                (String embedderName, List<PerSequenceEmbedding> embeddings, DatabaseImportMode importMode) {
              embeddingsCommandBloc.add(EmbeddingsCommandCalculateUMAPEvent(embedderName, embeddings, importMode));
            }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final embeddingsCommandBloc = BlocProvider.of<EmbeddingsCommandBloc>(context);
    return BiocentralCommandBar(
      commands: [
        BiocentralButton(
            label: "Calculate embeddings..",
            iconData: Icons.calculate,
            requiredServices: const ["embeddings_service"],
            onTap: () => openCalculateEmbeddingsDialog(embeddingsCommandBloc)),
        BiocentralButton(
            label: "Calculate UMAP..",
            iconData: Icons.auto_graph,
            requiredServices: const ["embeddings_service"],
            onTap: () => openCalculateUMAPDialog(embeddingsCommandBloc)),
      ],
    );
  }
}
