import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/biotrainer_training_bloc.dart';
import '../../bloc/model_hub_bloc.dart';
import '../displays/prediction_model_display.dart';
import 'training_model_view.dart';

class ModelHubView extends StatefulWidget {
  const ModelHubView({super.key});

  @override
  State<ModelHubView> createState() => _ModelHubViewState();
}

class _ModelHubViewState extends State<ModelHubView> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ModelHubBloc predictionModelsBloc = BlocProvider.of<ModelHubBloc>(context);
    return BlocBuilder<ModelHubBloc, ModelHubState>(
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [buildTrainingModel(predictionModelsBloc), ...buildPredictionModels(state)],
            ),
          ),
        );
      },
    );
  }

  Widget buildTrainingModel(ModelHubBloc predictionModelsBloc) {
    return BlocBuilder<BiotrainerTrainingBloc, BiotrainerTrainingState>(builder: (context, state) {
      if (state.isOperating()) {
        return const TrainingModelView();
      } else {
        return Container();
      }
    });
  }

  List<Widget> buildPredictionModels(ModelHubState state) {
    return state.predictionModels
        .map((predictionModel) => BiocentralHoverScaleAnimation(
                child: PredictionModelDisplay(
              predictionModel: predictionModel,
            )))
        .toList();
  }
}
