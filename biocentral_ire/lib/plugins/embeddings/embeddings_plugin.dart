import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/bloc/embeddings_commands.dart';
import 'package:biocentral/plugins/embeddings/bloc/embeddings_hub_bloc.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/plugins/embeddings/domain/projections_repository.dart';
import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';
import 'package:biocentral/plugins/embeddings/model/projection.dart';
import 'package:biocentral/plugins/embeddings/presentation/commands/calculate_embeddings_command_display.dart';
import 'package:biocentral/plugins/embeddings/presentation/commands/calculate_projection_command_display.dart';
import 'package:biocentral/plugins/embeddings/presentation/commands/load_embeddings_command_display.dart';
import 'package:biocentral/plugins/embeddings/presentation/views/embeddings_hub_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmbeddingsPlugin extends BiocentralPlugin
    with BiocentralMultiDatabasePluginMixin, BiocentralColumnWizardPluginMixin {
  EmbeddingsPlugin(super.eventBus);

  @override
  String get typeName => 'EmbeddingsPlugin';

  @override
  String getShortDescription() {
    return 'Calculate, analyze and visualize embeddings for biological entities';
  }

  @override
  List<dynamic> createDatabases(BiocentralProjectRepository projectRepository, BiocentralPythonCompanion companion) {
    final embeddingsRepository = EmbeddingsRepository(projectRepository, companion);
    final projectionRepository = ProjectionsRepository(projectRepository);
    return [embeddingsRepository, projectionRepository];
  }

  @override
  List<RepositoryProvider<dynamic>> createRepositoryProviders(List<dynamic> databases) {
    final providers = <RepositoryProvider>[];
    for (final database in databases) {
      if (database is EmbeddingsRepository) {
        providers.add(RepositoryProvider<EmbeddingsRepository>.value(value: database));
      }
      if (database is ProjectionsRepository) {
        providers.add(RepositoryProvider<ProjectionsRepository>.value(value: database));
      }
    }
    assert(providers.length == 2);
    return providers;
  }

  @override
  List<dynamic>? getDatabasesIfAvailable(BuildContext context) {
    try {
      final embeddingsRepository = RepositoryProvider.of<EmbeddingsRepository>(context);
      final projectionRepository = RepositoryProvider.of<ProjectionsRepository>(context);
      return [embeddingsRepository, projectionRepository];
    } on FlutterError {
      return null;
    }
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final embeddingsHubBloc = EmbeddingsHubBloc(
      getBiocentralProjectRepository(context),
      getBiocentralColumnWizardRepository(context),
      getBiocentralDatabaseRepository(context),
      getDatabase<EmbeddingsRepository>(context),
      getDatabase<ProjectionsRepository>(context),
    );

    eventBusSubscriptions.add(
      eventBus.on<BiocentralDatabaseSyncEvent>().listen((event) {
        // TODO [Refactoring] This is redundant with the database update event in concept, but necessary because of the
        // TODO way how the blocs fire events in this plugin
        embeddingsHubBloc.add(EmbeddingsHubReloadEvent());
      }),
    );

    eventBusSubscriptions.add(
      eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
        embeddingsHubBloc.add(EmbeddingsHubReloadEvent());
      }),
    );

    eventBusSubscriptions.add(
      eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
        if (event.switchedTab == getTab()) {
          embeddingsHubBloc.add(EmbeddingsHubReloadEvent());
        }
      }),
    );

    return {
      BlocProvider<EmbeddingsHubBloc>.value(value: embeddingsHubBloc): embeddingsHubBloc,
    };
  }

  @override
  List<Widget> getCommandWidgets() {
    return [
      const LoadEmbeddingsCommandDisplay(),
      const CalculateEmbeddingsCommandDisplay(),
      const CalculateProjectionCommandDisplay(),
    ];
  }

  @override
  Widget getScreenView(BuildContext context) {
    return EmbeddingsHubView(commandWidgets: getCommandWidgets());
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.calculate);
  }

  @override
  Widget getTab() {
    return Tab(text: 'Embeddings', icon: getIcon());
  }

  @override
  Map<ColumnWizardFactory<ColumnWizard>, Widget Function(ColumnWizard)?> createColumnWizardFactories() {
    return {EmbeddingsColumnWizardFactory(): null};
  }

  @override
  List<BiocentralPluginDirectory> getPluginDirectories() {
    return [
      BiocentralPluginDirectory(
        path: 'embeddings',
        saveType: EmbeddingsFile,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
        ) {
          final List<void Function(BuildContext)> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.name.contains('embedding_db_info') && scannedFile.extension == 'json') {
              void loadingFunction(context) => getBiocentralCommandBloc(context).add(
                    BiocentralCommandExecuteEvent(
                      command: LoadEmbeddingsDatabaseCommand(
                        projectRepository: getBiocentralProjectRepository(context),
                        embeddingsRepository: getDatabase(context),
                        embeddingsDBInfo: scannedFile,
                      ),
                      visualizeResult: null,
                      autoAccept: true,
                    ),
                  );
              loadingFunctions.add(loadingFunction);
            }
          }
          return loadingFunctions;
        },
      ),
      BiocentralPluginDirectory(
        path: 'projections',
        saveType: Projection,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
        ) {
          final List<void Function(BuildContext context)> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.name.contains('projections_db') && scannedFile.extension == 'json') {
              void loadingFunction(context) => getBiocentralCommandBloc(context).add(
                    BiocentralCommandExecuteEvent(
                      command: LoadProjectionsCommand(
                        projectRepository: getBiocentralProjectRepository(context),
                        projectionsRepository: getDatabase<ProjectionsRepository>(context),
                        xFile: scannedFile,
                        importMode: DatabaseImportMode.overwrite,
                      ),
                      visualizeResult: null,
                      autoAccept: true,
                    ),
                  );
              loadingFunctions.add(loadingFunction);
            }
          }
          return loadingFunctions;
        },
      ),
    ];
  }
}
