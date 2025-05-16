import 'package:biocentral/plugins/bayesian-optimization/bloc/bayesian_optimization_bloc.dart';
import 'package:biocentral/plugins/bayesian-optimization/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bayesian-optimization/domain/bayesian_optimization_repository.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/views/bayesian_optimization_command_view.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/views/bayesian_optimization_hub_view.dart';
import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Plugin for integrating Bayesian Optimization functionality into the Biocentral platform.
class BayesianOptimizationPlugin extends BiocentralPlugin
    with
        BiocentralClientPluginMixin<BayesianOptimizationClient>,
        BiocentralDatabasePluginMixin<BayesianOptimizationRepository>,
        BiocentralColumnWizardPluginMixin {
  /// Creates a new [BayesianOptimizationPlugin] instance.
  BayesianOptimizationPlugin(super.eventBus);

  @override
  String get typeName => 'BayesianOptimizationPlugin';

  @override
  String getShortDescription() {
    return 'Optimize models using Bayesian methods';
  }

  @override
  BiocentralClientFactory<BayesianOptimizationClient> createClientFactory() {
    return BayesianOptimizationClientFactory();
  }

  @override
  BayesianOptimizationRepository createListeningDatabase(BiocentralProjectRepository projectRepository) {
    final repository = BayesianOptimizationRepository(projectRepository);
    return repository;
  }

  @override
  Widget getCommandView(BuildContext context) {
    return const BayesianOptimizationCommandView();
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    final bayesianOptimizationHubBloc = BayesianOptimizationBloc(
      getDatabase(context),
      getBiocentralProjectRepository(context),
      getBiocentralClientRepository(context),
      eventBus,
      getBiocentralDatabaseRepository(context),
    );
    return {
      BlocProvider<BayesianOptimizationBloc>.value(
        value: bayesianOptimizationHubBloc,
      ): bayesianOptimizationHubBloc,
    };
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
    return Tab(text: 'Bayesian Optimization', icon: getIcon());
  }

  @override
  Map<ColumnWizardFactory<ColumnWizard>, Widget Function(ColumnWizard)?> createColumnWizardFactories() {
    return {EmbeddingsColumnWizardFactory(): null};
  }

  @override
  List<BiocentralPluginDirectory> getPluginDirectories() {
    // TODO: Implement directory structure
    return [];
  }
}
