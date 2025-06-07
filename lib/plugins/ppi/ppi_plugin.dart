import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/biocentral_core_plugins.dart';
import 'package:biocentral/plugins/ppi/bloc/ppi_command_bloc.dart';
import 'package:biocentral/plugins/ppi/bloc/ppi_database_grid_bloc.dart';
import 'package:biocentral/plugins/ppi/bloc/ppi_database_tests_bloc.dart';
import 'package:biocentral/plugins/ppi/bloc/ppi_properties_bloc.dart';
import 'package:biocentral/plugins/ppi/data/ppi_client.dart';
import 'package:biocentral/plugins/ppi/domain/ppi_repository.dart';
import 'package:biocentral/plugins/ppi/model/load_example_ppi_dataset_tutorial.dart';
import 'package:biocentral/plugins/ppi/presentation/views/ppi_command_view.dart';
import 'package:biocentral/plugins/ppi/presentation/views/ppi_hub_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/tutorial_system.dart';

class PpiPlugin extends BiocentralPlugin
    with
        BiocentralClientPluginMixin<PPIClient>,
        BiocentralDatabasePluginMixin<PPIRepository>,
        BiocentralTutorialPluginMixin {
  final GlobalKey ppiTabKey = GlobalKey();

  PpiPlugin(super.eventBus);

  @override
  String get typeName => 'PpiPlugin';

  @override
  String getShortDescription() {
    return 'Work with protein-protein interactions';
  }

  @override
  Set<Type> getDependencies() {
    return {ProteinPlugin};
  }

  @override
  Widget getCommandView(BuildContext context) {
    return const PPICommandView();
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const PPIHubView();
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.wifi_protected_setup);
  }

  @override
  Widget getTab() {
    return Tab(key: ppiTabKey, text: 'Interactions', icon: getIcon());
  }

  @override
  PPIRepository createListeningDatabase(BiocentralProjectRepository projectRepository) {
    final PPIRepository ppiRepository = PPIRepository(projectRepository);
    eventBus.on<BiocentralDatabaseSyncEvent>().listen((event) {
      ppiRepository.syncFromDatabase(event.updatedEntities, event.importMode);
    });
    return ppiRepository;
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final ppiCommandBloc = PPICommandBloc(
      getDatabase(context),
      getBiocentralClientRepository(context),
      getBiocentralProjectRepository(context),
      eventBus,
    );
    final ppiPropertiesBloc = PPIPropertiesBloc(getDatabase(context))..add(PPIPropertiesCalculateEvent());
    final ppiDatabaseGridBloc = PPIDatabaseGridBloc(getDatabase(context))..add(PPIDatabaseGridLoadEvent());
    final ppiDatabaseTestsBloc = PPIDatabaseTestsBloc(getDatabase(context));
    final ppiColumnWizardBloc = ColumnWizardBloc(getDatabase(context), getBiocentralColumnWizardRepository(context))
      ..add(ColumnWizardLoadEvent());

    eventBusSubscriptions.add(eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      ppiDatabaseGridBloc.add(PPIDatabaseGridLoadEvent());
      ppiPropertiesBloc.add(PPIPropertiesCalculateEvent());
      ppiDatabaseTestsBloc.add(PPIDatabaseTestsLoadTestsEvent());
      ppiColumnWizardBloc.add(ColumnWizardLoadEvent());
    }));

    eventBusSubscriptions.add(eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
      if (event.switchedTab == getTab()) {
        ppiDatabaseGridBloc.add(PPIDatabaseGridLoadEvent());
      }
    }));

    return {
      BlocProvider<PPICommandBloc>.value(value: ppiCommandBloc): ppiCommandBloc,
      BlocProvider<PPIPropertiesBloc>.value(value: ppiPropertiesBloc): ppiPropertiesBloc,
      BlocProvider<PPIDatabaseGridBloc>.value(value: ppiDatabaseGridBloc): ppiDatabaseGridBloc,
      BlocProvider<PPIDatabaseTestsBloc>.value(value: ppiDatabaseTestsBloc): ppiDatabaseTestsBloc,
      BlocProvider<ColumnWizardBloc>.value(value: ppiColumnWizardBloc): ppiColumnWizardBloc,
    };
  }

  @override
  BiocentralClientFactory<PPIClient> createClientFactory() {
    return PPIClientFactory();
  }

  @override
  List<Tutorial> getTutorials() {
    return [LoadExampleInteractionDatasetTutorialContainer()];
  }

  @override
  List<BiocentralPluginDirectory> getPluginDirectories() {
    return [
      BiocentralPluginDirectory(
        path: 'ppi',
        saveType: ProteinProteinInteraction,
        commandBlocType: PPICommandBloc,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
          List<BiocentralCommandLog> commandLogs,
          dynamic commandBloc,
        ) {
          final List<void Function()> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.name.contains('proteinproteininteraction.') && scannedFile.extension == 'fasta') {
              void loadingFunction() => commandBloc
                  ?.add(PPICommandLoadFromFileEvent(xFile: scannedFile, importMode: DatabaseImportMode.overwrite));
              loadingFunctions.add(loadingFunction);
            }
          }
          return loadingFunctions;
        },
      ),
    ];
  }
}
