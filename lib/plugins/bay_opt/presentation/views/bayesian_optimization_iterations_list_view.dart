import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_training_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/model_hub_bloc.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/plugins/prediction_models/presentation/displays/prediction_model_display.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_task_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BayesianOptimizationIterationsListView extends StatefulWidget {
  const BayesianOptimizationIterationsListView({super.key});

  @override
  State<BayesianOptimizationIterationsListView> createState() => _BayesianOptimizationIterationsListViewState();
}

class _BayesianOptimizationIterationsListViewState extends State<BayesianOptimizationIterationsListView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
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
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  bool get wantKeepAlive => true;
}
