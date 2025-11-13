import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_hub_bloc.dart';
import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_iteration_bloc.dart';
import 'package:biocentral/plugins/bay_opt/domain/bay_opt_repository.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_training_result.dart';
import 'package:biocentral/plugins/bay_opt/presentation/views/bay_opt_command_view.dart';
import 'package:biocentral/plugins/bay_opt/presentation/views/bay_opt_hub_view.dart';
import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Plugin for integrating Bayesian Optimization functionality into the Biocentral platform.
class BayOptPlugin extends BiocentralPlugin
    with
        BiocentralDatabasePluginMixin<BayOptRepository>,
        BiocentralColumnWizardPluginMixin {
  /// Creates a new [BayOptPlugin] instance.
  BayOptPlugin(super.eventBus);

  @override
  String get typeName => 'BayOptPlugin';

  @override
  String getShortDescription() {
    return 'Optimize models using Bayesian methods';
  }

  @override
  BayOptRepository createListeningDatabase(BiocentralProjectRepository projectRepository) {
    final repository = BayOptRepository(projectRepository);
    return repository;
  }

  @override
  Widget getCommandView(BuildContext context) {
    return const BayOptCommandView();
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final bayOptHubBloc = BayOptHubBloc(
      getDatabase(context),
      getBiocentralProjectRepository(context),
      getBiocentralAPIRepository(context),
      eventBus,
      getBiocentralDatabaseRepository(context),
    );
    final bayOptIterationBloc = BayOptIterationBloc(
      getBiocentralProjectRepository(context),
      getDatabase(context),
      getBiocentralDatabaseRepository(context),
      getBiocentralAPIRepository(context),
      eventBus,
    );

    eventBusSubscriptions.add(eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      bayOptHubBloc.add(BayOptHubLoadEvent());
    }));

    return {
      BlocProvider<BayOptHubBloc>.value(
        value: bayOptHubBloc,
      ): bayOptHubBloc,
      BlocProvider<BayOptIterationBloc>.value(
        value: bayOptIterationBloc,
      ): bayOptIterationBloc,
    };
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const BayOptHubView();
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
        saveType: BayOptTrainingResult,
        commandBlocType: BayOptHubBloc,
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
                    BayOptHubLoadTrainingsFromFileEvent(
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
