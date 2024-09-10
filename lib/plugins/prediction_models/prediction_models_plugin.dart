import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/biotrainer_training_bloc.dart';
import 'bloc/model_hub_bloc.dart';
import 'bloc/prediction_model_events.dart';
import 'data/prediction_models_client.dart';
import 'domain/prediction_model_repository.dart';
import 'presentation/views/model_command_view.dart';
import 'presentation/views/model_hub_view.dart';

class PredictionModelsPlugin extends BiocentralPlugin
    with BiocentralClientPluginMixin<PredictionModelsClient>, BiocentralDatabasePluginMixin<PredictionModelRepository> {
  PredictionModelsPlugin(super.eventBus);

  @override
  String getShortDescription() {
    return "Train models on your data and use them for new predictions";
  }

  @override
  PredictionModelRepository createListeningDatabase() {
    return PredictionModelRepository();
  }

  @override
  Widget getCommandView(BuildContext context) {
    return ModelCommandView(eventBus: eventBus);
  }

  @override
  List<BlocProvider> getListeningBlocs(BuildContext context) {
    final biotrainerTrainingBloc = BiotrainerTrainingBloc(getDatabase(context), getBiocentralClientRepository(context),
        getBiocentralDatabaseRepository(context), getBiocentralProjectRepository(context), eventBus);
    final modelHubBloc = ModelHubBloc(getDatabase(context));

    eventBus.on<BiotrainerStartTrainingEvent>().listen((event) {
      biotrainerTrainingBloc.add(BiotrainerTrainingStartTrainingEvent(event.databaseType, event.trainingConfiguration));
    });

    eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      modelHubBloc.add(ModelHubLoadEvent());
    });

    eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
      if (event.switchedTab == getTab()) {
        modelHubBloc.add(ModelHubLoadEvent());
      }
    });

    return [
      BlocProvider<BiotrainerTrainingBloc>.value(value: biotrainerTrainingBloc),
      BlocProvider<ModelHubBloc>.value(value: modelHubBloc)
    ];
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const ModelHubView();
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.model_training);
  }

  @override
  Widget getTab() {
    return Tab(text: "Models", icon: getIcon());
  }

  @override
  BiocentralClientFactory<PredictionModelsClient> createClientFactory() {
    return PredictionModelsClientFactory();
  }
}
