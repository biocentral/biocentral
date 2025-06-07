import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/bloc/embeddings_command_bloc.dart';
import 'package:biocentral/plugins/embeddings/bloc/embeddings_hub_bloc.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_client.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';
import 'package:biocentral/plugins/embeddings/presentation/views/embeddings_command_view.dart';
import 'package:biocentral/plugins/embeddings/presentation/views/embeddings_hub_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmbeddingsPlugin extends BiocentralPlugin
    with
        BiocentralClientPluginMixin<EmbeddingsClient>,
        BiocentralDatabasePluginMixin<EmbeddingsRepository>,
        BiocentralColumnWizardPluginMixin {
  EmbeddingsPlugin(super.eventBus);

  @override
  String get typeName => 'EmbeddingsPlugin';

  @override
  String getShortDescription() {
    return 'Calculate, analyze and visualize embeddings for biological entities';
  }

  @override
  BiocentralClientFactory<EmbeddingsClient> createClientFactory() {
    return EmbeddingsClientFactory();
  }

  @override
  EmbeddingsRepository createListeningDatabase(BiocentralProjectRepository projectRepository) {
    final embeddingsRepository = EmbeddingsRepository();
    return embeddingsRepository;
  }

  @override
  Widget getCommandView(BuildContext context) {
    return const EmbeddingsCommandView();
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final embeddingsCommandBloc = EmbeddingsCommandBloc(
      getBiocentralDatabaseRepository(context),
      getBiocentralClientRepository(context),
      getBiocentralProjectRepository(context),
      getBiocentralPythonCompanion(context),
      getDatabase(context),
      eventBus,
    );
    final embeddingsHubBloc = EmbeddingsHubBloc(
      getBiocentralProjectRepository(context),
      getBiocentralColumnWizardRepository(context),
      getBiocentralDatabaseRepository(context),
      getDatabase(context),
    );

    eventBusSubscriptions.add(eventBus.on<BiocentralDatabaseSyncEvent>().listen((event) {
      // TODO [Refactoring] This is redundant with the database update event in concept, but necessary because of the
      // TODO way how the blocs fire events in this plugin
      embeddingsHubBloc.add(EmbeddingsHubReloadEvent());
    }));

    eventBusSubscriptions.add(eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      embeddingsHubBloc.add(EmbeddingsHubReloadEvent());
    }));

    eventBusSubscriptions.add(eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
      if (event.switchedTab == getTab()) {
        embeddingsHubBloc.add(EmbeddingsHubReloadEvent());
      }
    }));

    return {
      BlocProvider<EmbeddingsCommandBloc>.value(value: embeddingsCommandBloc): embeddingsCommandBloc,
      BlocProvider<EmbeddingsHubBloc>.value(value: embeddingsHubBloc): embeddingsHubBloc,
    };
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const EmbeddingsHubView();
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
        saveType: Embedding,
        commandBlocType: EmbeddingsCommandBloc,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
          List<BiocentralCommandLog> commandLogs,
          dynamic commandBloc,
        ) {
          final List<void Function()> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.extension == 'h5') {
              void loadingFunction() => commandBloc?.add(
                    EmbeddingsCommandLoadEmbeddingsEvent(xFile: scannedFile, importMode: DatabaseImportMode.overwrite),
                  );
              loadingFunctions.add(loadingFunction);
            }
          }
          return loadingFunctions;
        },
      ),
      BiocentralPluginDirectory(
        path: 'projections',
        saveType: ProjectionData,
        commandBlocType: EmbeddingsCommandBloc,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
          List<BiocentralCommandLog> commandLogs,
          dynamic commandBloc,
        ) {
          // TODO Handle Projection Data loading
          return [];
        },
      )
    ];
  }
}
