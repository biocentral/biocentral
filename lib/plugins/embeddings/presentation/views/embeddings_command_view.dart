import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/bloc/calculate_embeddings_dialog_bloc.dart';
import 'package:biocentral/plugins/embeddings/bloc/calculate_projections_dialog_bloc.dart';
import 'package:biocentral/plugins/embeddings/bloc/embeddings_command_bloc.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/plugins/embeddings/presentation/dialogs/calculate_embeddings_dialog.dart';
import 'package:biocentral/plugins/embeddings/presentation/dialogs/calculate_projections_dialog.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/model/biocentral_config_option.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  void loadEmbeddingsFile(EmbeddingsCommandBloc embeddingsCommandBloc) async {
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowedExtensions: ['h5', 'hdf5'], type: FileType.custom, withData: kIsWeb);

    if (result != null) {
      DatabaseImportMode importMode = DatabaseImportMode.defaultMode;
      if (mounted) {
        importMode = await getImportModeFromDialog(context: context);
      }
      embeddingsCommandBloc
          .add(EmbeddingsCommandLoadEmbeddingsEvent(platformFile: result.files.single, importMode: importMode));
    } else {
      // User canceled the picker
    }
  }

  void openCalculateEmbeddingsDialog(EmbeddingsCommandBloc embeddingsCommandBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => CalculateEmbeddingsDialogBloc(),
          child: CalculateEmbeddingsDialog(
            calculateEmbeddingsCallback:
                (PredefinedEmbedder predefinedEmbedder, EmbeddingType embeddingType, DatabaseImportMode importMode) {
              embeddingsCommandBloc
                  .add(EmbeddingsCommandCalculateEmbeddingsEvent(predefinedEmbedder, embeddingType, importMode));
            },
          ),
        );
      },
    );
  }

  void openCalculateUMAPDialog(EmbeddingsCommandBloc embeddingsCommandBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => CalculateProjectionsDialogBloc(
            context.read<BiocentralClientRepository>(),
            context.read<EmbeddingsRepository>(),
          )..add(CalculateProjectionsDialogGetConfigEvent()),
          child: CalculateProjectionsDialog(
            calculateUMAPCallback: (String embedderName,
                Map<String, PerSequenceEmbedding> embeddings,
                String projectionMethod,
                Map<BiocentralConfigOption, dynamic> projectionConfig,
                DatabaseImportMode importMode) {
              embeddingsCommandBloc.add(
                EmbeddingsCommandCalculateProjectionsEvent(
                  embedderName,
                  embeddings,
                  importMode,
                  projectionMethod,
                  projectionConfig,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final embeddingsCommandBloc = BlocProvider.of<EmbeddingsCommandBloc>(context);
    return BiocentralCommandBar(
      commands: [
        BiocentralTooltip(
          message: 'Load existing representations for your data',
          child: BiocentralButton(
            label: 'Load embeddings..',
            iconData: Icons.file_open,
            onTap: () => loadEmbeddingsFile(embeddingsCommandBloc),
          ),
        ),
        BiocentralTooltip(
          message: 'Get meaningful representations for your data',
          child: BiocentralButton(
            label: 'Calculate embeddings..',
            iconData: Icons.calculate,
            requiredServices: const ['embeddings_service'],
            onTap: () => openCalculateEmbeddingsDialog(embeddingsCommandBloc),
          ),
        ),
        BiocentralTooltip(
          message: 'Perform dimensionality reduction methods on your embeddings',
          child: BiocentralButton(
            label: 'Calculate projections..',
            iconData: Icons.auto_graph,
            requiredServices: const ['embeddings_service'],
            onTap: () => openCalculateUMAPDialog(embeddingsCommandBloc),
          ),
        ),
      ],
    );
  }
}
