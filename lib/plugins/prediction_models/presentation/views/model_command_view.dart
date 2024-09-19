import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/biotrainer_config_dialog_bloc.dart';
import '../../bloc/load_model_dialog_bloc.dart';
import '../../bloc/set_generation_dialog_bloc.dart';
import '../../data/prediction_models_client.dart';
import '../../domain/prediction_model_repository.dart';
import '../dialogs/biotrainer_config_dialog.dart';
import '../dialogs/load_model_dialog.dart';
import '../dialogs/set_generation_dialog.dart';

class ModelCommandView extends StatefulWidget {
  final EventBus eventBus;

  const ModelCommandView({super.key, required this.eventBus});

  @override
  State<ModelCommandView> createState() => _ModelCommandViewState();
}

class _ModelCommandViewState extends State<ModelCommandView> {
  @override
  void initState() {
    super.initState();
  }

  void openLoadModelDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => LoadModelDialogBloc(context.read<PredictionModelRepository>(),
                context.read<BiocentralProjectRepository>(), widget.eventBus),
            child: const LoadModelDialog(),
          );
        });
  }

  void openBiotrainerConfigDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => BiotrainerConfigBloc(context.read<BiocentralDatabaseRepository>(),
                context.read<BiocentralClientRepository>().getServiceClient<PredictionModelsClient>()),
            child: BiotrainerConfigDialog(eventBus: widget.eventBus),
          );
        });
  }

  void openGenerateSetsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => SetGenerationDialogBloc(context.read<BiocentralDatabaseRepository>(), widget.eventBus),
            child: const SetGenerationDialog(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandBar(
      commands: [
        BiocentralTooltip(
          message: "Load an existing model into biocentral from file",
          child: BiocentralButton(
              label: "Load a model from files..",
              iconData: Icons.file_open,
              requiredServices: const [],
              onTap: openLoadModelDialog),
        ),
        BiocentralTooltip(
          message: "Train a new model on your dataset",
          child: BiocentralButton(
              label: "Train a model..",
              iconData: Icons.model_training,
              requiredServices: const ["prediction_models_service"],
              onTap: openBiotrainerConfigDialog),
        ),
        BiocentralTooltip(
          message: "Generate new dataset splits for cross validation",
          child: BiocentralButton(
              label: "Generate sets..",
              iconData: Icons.splitscreen_outlined,
              requiredServices: const [],
              onTap: openGenerateSetsDialog),
        ),
      ],
    );
  }
}
