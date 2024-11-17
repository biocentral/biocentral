import 'package:biocentral/plugins/bayesian-optimization/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bayesian-optimization/domain/bayesian_optimization_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BayesianOptimizationPlugin extends BiocentralPlugin
    with
        BiocentralClientPluginMixin<BayesianOptimizationClient>,
        BiocentralDatabasePluginMixin<BayesianOptimizationRepository>,
        BiocentralColumnWizardPluginMixin {
  BayesianOptimizationPlugin(super.eventBus);

  @override
  String get typeName => "BayesianOptimizationPlugin";

  @override
  String getShortDescription() {
    return "Optimize models using Bayesian methods";
  }

  @override
  BiocentralClientFactory<BayesianOptimizationClient> createClientFactory() {
    return BayesianOptimizationClientFactory();
  }

  @override
  BayesianOptimizationRepository createListeningDatabase() {
    final repository = BayesianOptimizationRepository();
    return repository;
  }

  @override
  Widget getCommandView(BuildContext context) {
    return const BayesianOptimizationCommandView();
  }

  @override
  List<BlocProvider> getListeningBlocs(BuildContext context) {
    final commandBloc = BayesianOptimizationCommandBloc(
        getBiocentralDatabaseRepository(context),
        getBiocentralClientRepository(context),
        getBiocentralProjectRepository(context),
        getDatabase(context),
        eventBus);
    final hubBloc = BayesianOptimizationHubBloc(
        getBiocentralColumnWizardRepository(context), getBiocentralDatabaseRepository(context), getDatabase(context));
    eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      hubBloc.add(BayesianOptimizationHubReloadEvent());
    });
    eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
      if (event.switchedTab == getTab()) {
        hubBloc.add(BayesianOptimizationHubReloadEvent());
      }
    });
    return [
      BlocProvider<BayesianOptimizationCommandBloc>.value(value: commandBloc),
      BlocProvider<BayesianOptimizationHubBloc>.value(value: hubBloc)
    ];
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const BayesianOptimizationHubView();
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.optimization);
  }

  @override
  Widget getTab() {
    return Tab(text: "Bayesian Optimization", icon: getIcon());
  }

  @override
  List<ColumnWizardFactory<ColumnWizard>> createColumnWizardFactories() {
    return [BayesianOptimizationColumnWizardFactory()];
  }
}