import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_hub_bloc.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_iteration_bloc.dart';
import 'package:biocentral/plugins/bay_opt/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bay_opt/domain/bayesian_optimization_repository.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_training_result.dart';
import 'package:biocentral/plugins/bay_opt/presentation/views/bayesian_optimization_command_view.dart';
import 'package:biocentral/plugins/bay_opt/presentation/views/bayesian_optimization_hub_view.dart';
import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
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
    cancelSubscriptions();

    final bayesianOptimizationHubBloc = BayesianOptimizationHubBloc(
      getDatabase(context),
      getBiocentralProjectRepository(context),
      getBiocentralClientRepository(context),
      eventBus,
      getBiocentralDatabaseRepository(context),
    );
    final bayesianOptimizationIterationBloc = BayesianOptimizationIterationBloc(
      getBiocentralProjectRepository(context),
      getDatabase(context),
      getBiocentralDatabaseRepository(context),
      getBiocentralClientRepository(context),
      eventBus,
    );

    eventBusSubscriptions.add(eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      bayesianOptimizationHubBloc.add(BayesianOptimizationHubLoadEvent());
    }));

    return {
      BlocProvider<BayesianOptimizationHubBloc>.value(
        value: bayesianOptimizationHubBloc,
      ): bayesianOptimizationHubBloc,
      BlocProvider<BayesianOptimizationIterationBloc>.value(
        value: bayesianOptimizationIterationBloc,
      ): bayesianOptimizationIterationBloc,
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
    return [
      BiocentralPluginDirectory(
        path: 'bay_opt',
        saveType: BayesianOptimizationTrainingResult,
        commandBlocType: BayesianOptimizationHubBloc,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
          List<BiocentralCommandLog> commandLogs,
          dynamic commandBloc,
        ) {
          final List<void Function()> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.name.contains('bo_results.') && scannedFile.extension == 'json') {
              void loadingFunction() => commandBloc?.add(
                    BayesianOptimizationHubLoadTrainingsFromFileEvent(
                      xFile: scannedFile,
                    ),
                  );
              loadingFunctions.add(loadingFunction);
            }
          }
          return loadingFunctions;
        },
      )
    ];
  }
}
