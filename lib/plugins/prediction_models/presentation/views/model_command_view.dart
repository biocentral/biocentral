import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_config_dialog_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_inference_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/inference_dialog_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/load_model_dialog_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/model_hub_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/set_generation_dialog_bloc.dart';
import 'package:biocentral/plugins/prediction_models/domain/prediction_model_repository.dart';
import 'package:biocentral/plugins/prediction_models/presentation/dialogs/biotrainer_config_dialog.dart';
import 'package:biocentral/plugins/prediction_models/presentation/dialogs/inference_dialog_builder.dart';
import 'package:biocentral/plugins/prediction_models/presentation/dialogs/load_model_dialog.dart';
import 'package:biocentral/plugins/prediction_models/presentation/dialogs/set_generation_dialog_builder.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/dialogs/biocentral_config_dialog.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ModelCommandView extends StatefulWidget {
  final EventBus eventBus;

  const ModelCommandView({required this.eventBus, super.key});

  @override
  State<ModelCommandView> createState() => _ModelCommandViewState();
}

class _ModelCommandViewState extends State<ModelCommandView> {
  @override
  void initState() {
    super.initState();
  }

  void openLoadModelDialog() {
    final modelHubBloc = BlocProvider.of<ModelHubBloc>(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => LoadModelDialogBloc(
            context.read<PredictionModelRepository>(),
            context.read<BiocentralProjectRepository>(),
            widget.eventBus,
          ),
          child: LoadModelDialog(
            modelHubBloc: modelHubBloc,
          ),
        );
      },
    );
  }

  void openBiotrainerConfigDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => BiotrainerConfigBloc(
            context.read<BiocentralDatabaseRepository>(),
            context.read<BiocentralAPIRepository>(),
          ),
          child: BiotrainerConfigDialog(eventBus: widget.eventBus),
        );
      },
    );
  }

  void openInferenceDialog() {
    final biotrainerInferenceBloc = BlocProvider.of<BiotrainerInferenceBloc>(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => InferenceDialogBloc(
            context.read<BiocentralDatabaseRepository>(),
            context.read<PredictionModelRepository>(),
          )..add(InferenceDialogLoadEvent()),
          child: BlocBuilder<InferenceDialogBloc, InferenceDialogState>(
            builder: (context, state) {
              return BiocentralConfigDialog<InferenceDialogBloc, InferenceDialogState>(
                configDialogBuilder: InferenceDialogBuilder(
                  onStartInference: (predictionModel, selectedEntityIDs) => biotrainerInferenceBloc
                      .add(BiotrainerInferenceStartInferenceEvent(predictionModel, selectedEntityIDs)),
                ),
                bloc: BlocProvider.of<InferenceDialogBloc>(context),
                state: state,
              );
            },
          ),
        );
      },
    );
  }

  void openGenerateSetsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => SetGenerationDialogBloc(context.read<BiocentralDatabaseRepository>(), widget.eventBus),
          child: BlocBuilder<SetGenerationDialogBloc, SetGenerationDialogState>(
            builder: (context, state) {
              return BiocentralConfigDialog<SetGenerationDialogBloc, SetGenerationDialogState>(
                configDialogBuilder: SetGenerationDialogBuilder(),
                bloc: BlocProvider.of<SetGenerationDialogBloc>(context),
                state: state,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandBar(
      commands: [
        BiocentralTooltip(
          message: 'Load an existing model into biocentral from file',
          child: BiocentralButton(
            label: 'Load a model from files..',
            iconData: Icons.file_open,
            onTap: openLoadModelDialog,
          ),
        ),
        BiocentralTooltip(
          message: 'Train a new model on your dataset',
          child: BiocentralButton(
            label: 'Train a model..',
            iconData: Icons.model_training,
            onTap: openBiotrainerConfigDialog,
          ),
        ),
        BiocentralTooltip(
          message: 'Create predictions from your trained models',
          child: BiocentralButton(
            label: 'Inference predictions..',
            iconData: Icons.online_prediction,
            onTap: openInferenceDialog,
          ),
        ),
        BiocentralTooltip(
          message: 'Generate new dataset splits for cross validation',
          child: BiocentralButton(
            label: 'Generate sets..',
            iconData: Icons.splitscreen_outlined,
            onTap: openGenerateSetsDialog,
          ),
        ),
      ],
    );
  }
}
