import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/proteins/bloc/protein_database_grid_bloc.dart';
import 'package:biocentral/plugins/proteins/bloc/proteins_command_bloc.dart';
import 'package:biocentral/plugins/proteins/data/protein_client.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/plugins/proteins/model/sequence_column_wizard.dart';
import 'package:biocentral/plugins/proteins/presentation/displays/sequence_column_wizard_display.dart';
import 'package:biocentral/plugins/proteins/presentation/views/protein_hub_view.dart';
import 'package:biocentral/plugins/proteins/presentation/views/proteins_command_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProteinPlugin extends BiocentralPlugin
    with
        BiocentralClientPluginMixin<ProteinClient>,
        BiocentralDatabasePluginMixin<ProteinRepository>,
        BiocentralColumnWizardPluginMixin {
  ProteinPlugin(super.eventBus);

  @override
  String get typeName => 'ProteinPlugin';

  @override
  String getShortDescription() {
    return 'Work with protein data';
  }

  @override
  ProteinRepository createListeningDatabase(BiocentralProjectRepository projectRepository) {
    final proteinRepository = ProteinRepository(projectRepository);
    eventBus.on<BiocentralDatabaseSyncEvent>().listen((event) {
      proteinRepository.syncFromDatabase(event.updatedEntities, event.importMode);
    });
    return proteinRepository;
  }

  @override
  Widget getCommandView(BuildContext context) {
    return const ProteinsCommandView();
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final proteinCommandBloc = ProteinsCommandBloc(
      getDatabase(context),
      getBiocentralClientRepository(context),
      getBiocentralProjectRepository(context),
      eventBus,
    );
    final proteinDatabaseGridBloc = ProteinDatabaseGridBloc(getDatabase(context))..add(ProteinDatabaseGridLoadEvent());
    final proteinColumnWizardBloc = ColumnWizardBloc(getDatabase(context), getBiocentralColumnWizardRepository(context))
      ..add(ColumnWizardLoadEvent());

    eventBusSubscriptions.add(eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      proteinDatabaseGridBloc.add(ProteinDatabaseGridLoadEvent());
      proteinColumnWizardBloc.add(ColumnWizardLoadEvent());
    }));

    eventBusSubscriptions.add(eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
      if (event.switchedTab == getTab()) {
        proteinDatabaseGridBloc.add(ProteinDatabaseGridLoadEvent());
      }
    }));

    return {
      BlocProvider<ProteinsCommandBloc>.value(value: proteinCommandBloc): proteinCommandBloc,
      BlocProvider<ProteinDatabaseGridBloc>.value(value: proteinDatabaseGridBloc): proteinDatabaseGridBloc,
      BlocProvider<ColumnWizardBloc>.value(value: proteinColumnWizardBloc): proteinColumnWizardBloc,
    };
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const ProteinHubView();
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.list_alt);
  }

  @override
  Widget getTab() {
    return Tab(text: 'Proteins', icon: getIcon());
  }

  @override
  BiocentralClientFactory<ProteinClient> createClientFactory() {
    return ProteinClientFactory();
  }

  @override
  Map<ColumnWizardFactory<ColumnWizard>, Widget Function(ColumnWizard)?> createColumnWizardFactories() {
    return {
      SequenceColumnWizardFactory(): (seqColumnWizard) =>
          SequenceColumnWizardDisplay(columnWizard: seqColumnWizard as SequenceColumnWizard),
    };
  }

  @override
  List<BiocentralPluginDirectory> getPluginDirectories() {
    return [
      BiocentralPluginDirectory(
        path: 'proteins',
        saveType: Protein,
        commandBlocType: ProteinsCommandBloc,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
          List<BiocentralCommandLog> commandLogs,
          dynamic commandBloc,
        ) {
          final List<void Function()> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.name.contains('protein.') && scannedFile.extension == 'fasta') {
              void loadingFunction() => commandBloc?.add(
                    ProteinsCommandLoadProteinsFromFileEvent(
                      xFile: scannedFile,
                      importMode: DatabaseImportMode.overwrite,
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
