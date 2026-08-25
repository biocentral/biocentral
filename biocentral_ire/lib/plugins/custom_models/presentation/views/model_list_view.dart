import 'package:biocentral/plugins/custom_models/bloc/model_hub_bloc.dart';
import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/plugins/custom_models/presentation/displays/prediction_model_display.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
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
        if (state.predictionModels.isEmpty) {
          return const Center(
            child: Text('No models available yet!'),
          );
        }
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...buildPredictionModels(state),
              ],
            ),
          ),
        );
      },
    );
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
