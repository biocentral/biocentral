import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/proteins/bloc/protein_database_grid_bloc.dart';
import 'package:biocentral/plugins/proteins/bloc/proteins_commands.dart';
import 'package:biocentral/plugins/proteins/data/asset_protein_datasets.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/plugins/proteins/model/analyze_example_dataset_tutorial.dart';
import 'package:biocentral/plugins/proteins/model/sequence_column_wizard.dart';
import 'package:biocentral/plugins/proteins/presentation/commands/protein_export_command_display.dart';
import 'package:biocentral/plugins/proteins/presentation/commands/protein_load_asset_dataset_command_display.dart';
import 'package:biocentral/plugins/proteins/presentation/commands/protein_load_commands_display.dart';
import 'package:biocentral/plugins/proteins/presentation/commands/protein_predict_command_display.dart';
import 'package:biocentral/plugins/proteins/presentation/commands/protein_taxonomy_command_display.dart';
import 'package:biocentral/plugins/proteins/presentation/displays/sequence_column_wizard_display.dart';
import 'package:biocentral/plugins/proteins/presentation/views/protein_hub_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/data/tutorial.dart';

class ProteinPlugin extends BiocentralPlugin
    with
        BiocentralDatabasePluginMixin<ProteinRepository>,
        BiocentralColumnWizardPluginMixin,
        BiocentralTutorialPluginMixin {
  final GlobalKey proteinTabKey = GlobalKey();

  ProteinPlugin(super.eventBus);

  @override
  String get typeName => 'ProteinPlugin';

  @override
  String getShortDescription() {
    return 'Work with protein data';
  }

  @override
  ProteinRepository createListeningDatabase(
      BiocentralProjectRepository projectRepository, BiocentralPythonCompanion companion) {
    final proteinRepository = ProteinRepository(projectRepository);
    eventBus.on<BiocentralDatabaseSyncEvent>().listen((event) {
      proteinRepository.syncFromDatabase(event.updatedEntities, event.importMode);
    });
    return proteinRepository;
  }

  @override
  List<Widget> getCommandWidgets() {
    return [
      const ProteinLoadCommandDisplay(),
      const ProteinTaxonomyCommandDisplay(),
      const ProteinPredictCommandDisplay(),
      const ProteinExportCommandDisplay(),
      ProteinLoadAssetDatasetCommandDisplay(assetDatasets: AssetProteinDatasetContainer.assetProteinDatasets()),
    ];
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final proteinDatabaseGridBloc = ProteinDatabaseGridBloc(getDatabase(context))..add(ProteinDatabaseGridLoadEvent());
    final proteinColumnWizardBloc =
        ColumnWizardBloc(getDatabase(context), getBiocentralColumnWizardRepository(context));

    return {
      BlocProvider<ProteinDatabaseGridBloc>.value(value: proteinDatabaseGridBloc): proteinDatabaseGridBloc,
      BlocProvider<ColumnWizardBloc>.value(value: proteinColumnWizardBloc): proteinColumnWizardBloc,
    };
  }

  @override
  Widget getScreenView(BuildContext context) {
    return ProteinHubView(
      commandWidgets: getCommandWidgets(),
    );
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.list_alt);
  }

  @override
  Widget getTab() {
    return Tab(key: proteinTabKey, text: 'Proteins', icon: getIcon());
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
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
        ) {
          final List<void Function(BuildContext context)> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.name.contains('protein.') && scannedFile.extension == 'fasta') {
              void loadingFunction(context) => getBiocentralCommandBloc(context).add(
                    BiocentralCommandExecuteEvent(
                      command: LoadProteinsFromFileCommand(
                        biocentralProjectRepository: getBiocentralProjectRepository(context),
                        proteinRepository: getDatabase(context),
                        xFile: scannedFile,
                        assetDataset: null,
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

  @override
  List<Tutorial> getTutorials() {
    return [AnalyzeExampleDatasetTutorial()];
  }
}
