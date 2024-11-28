import 'package:biocentral/plugins/bayesian-optimization/bloc/bayesian_optimization_hub_bloc.dart';
import 'package:biocentral/plugins/bayesian-optimization/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bayesian-optimization/domain/bayesian_optimization_repository.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/views/bayesian_optimization_command_view.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/views/bayesian_optimization_hub_view.dart';
import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';
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
    final bayesianOptimizationHubBloc = BayesianOptimizationHubBloc();
    return [
      BlocProvider<BayesianOptimizationHubBloc>.value(value: bayesianOptimizationHubBloc),
    ];
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const BayesianOptimizationHubView();
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.calculate_outlined);
  }

  @override
  Widget getTab() {
    return Tab(text: "Bayesian Optimization", icon: getIcon());
  }

  @override
  List<ColumnWizardFactory<ColumnWizard>> createColumnWizardFactories() {
    return [EmbeddingsColumnWizardFactory()];
  }
}
