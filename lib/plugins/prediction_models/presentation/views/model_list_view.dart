import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_training_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/model_hub_bloc.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/plugins/prediction_models/presentation/displays/prediction_model_display.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_task_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ModelListView extends StatefulWidget {
  final void Function() onDragStarted;
  final void Function() onDragEnd;

  const ModelListView({required this.onDragStarted, required this.onDragEnd, super.key});

  @override
  State<ModelListView> createState() => _ModelListViewState();
}

class _ModelListViewState extends State<ModelListView> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ModelHubBloc predictionModelsBloc = BlocProvider.of<ModelHubBloc>(context);
    return BlocBuilder<ModelHubBloc, ModelHubState>(
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTrainingModel(predictionModelsBloc),
                ...buildResumablePredictionModels(state),
                ...buildPredictionModels(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTrainingModel(ModelHubBloc predictionModelsBloc) {
    return BlocBuilder<BiotrainerTrainingBloc, BiotrainerTrainingState>(
      builder: (context, state) {
        if (state.isOperating() && state.trainingModel != null) {
          return PredictionModelDisplay(
            predictionModel: state.trainingModel!,
            trainingState: state,
          );
        } else {
          return Container();
        }
      },
    );
  }

  List<Widget> buildResumablePredictionModels(ModelHubState state) {
    final BiotrainerTrainingBloc biotrainerTrainingBloc = BlocProvider.of<BiotrainerTrainingBloc>(context);

    // TODO [Optimization] Disable resumed command
    return state.resumableCommands
        .map(
          (commandLog) => BiocentralTaskDisplay.resumable(
            commandLog,
            () => biotrainerTrainingBloc.add(BiotrainerTrainingResumeTrainingEvent(commandLog)),
          ),
        )
        .toList();
  }

  List<Widget> buildPredictionModels(ModelHubState state) {
    return state.predictionModels
        .map(
          (predictionModel) => BiocentralHoverScaleAnimation(
            child: Draggable<PredictionModel>(
              data: predictionModel,
              onDragStarted: widget.onDragStarted,
              onDragEnd: (_) => widget.onDragEnd(),
              feedback: Opacity(
                opacity: 0.2,
                child: Material(
                  child: PredictionModelDisplay(
                    predictionModel: predictionModel,
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: PredictionModelDisplay(
                  predictionModel: predictionModel,
                ),
              ),
              child: PredictionModelDisplay(
                predictionModel: predictionModel,
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  bool get wantKeepAlive => true;
}
