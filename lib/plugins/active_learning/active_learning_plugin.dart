import 'package:biocentral/plugins/active_learning/bloc/al_commands.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/domain/al_repository.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/plugins/active_learning/presentation/commands/add_experimental_data_command_display.dart';
import 'package:biocentral/plugins/active_learning/presentation/commands/al_iteration_command_display.dart';
import 'package:biocentral/plugins/active_learning/presentation/commands/new_al_campaign_command_display.dart';
import 'package:biocentral/plugins/active_learning/presentation/views/al_hub_view.dart';
import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Plugin for integrating Active Learning functionality into the Biocentral platform.
class ALPlugin extends BiocentralPlugin
    with BiocentralDatabasePluginMixin<ALRepository>, BiocentralColumnWizardPluginMixin {
  /// Creates a new [ALPlugin] instance.
  ALPlugin(super.eventBus);

  @override
  String get typeName => 'ALPlugin';

  @override
  String getShortDescription() {
    return 'Perform experiments on sparse data using active learning';
  }

  @override
  ALRepository createListeningDatabase(
      BiocentralProjectRepository projectRepository, BiocentralPythonCompanion companion) {
    final repository = ALRepository(projectRepository);
    return repository;
  }

  @override
  List<Widget> getCommandWidgets() {
    return [
      const NewALCampaignCommandDisplay(),
      const AddExperimentalDataCommandDisplay(),
      const ALIterationCommandDisplay()
    ];
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final alHubBloc = ALHubBloc(
      getBiocentralProjectRepository(context),
      getDatabase(context),
      context.read<ProteinRepository>(),
    );

    return {
      BlocProvider<ALHubBloc>.value(
        value: alHubBloc,
      ): alHubBloc,
    };
  }

  @override
  Widget getScreenView(BuildContext context) {
    return ALHubView(
      commandWidgets: getCommandWidgets(),
    );
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.calculate_outlined);
  }

  @override
  Widget getTab() {
    return Tab(text: 'Active Learning', icon: getIcon());
  }

  @override
  Map<ColumnWizardFactory<ColumnWizard>, Widget Function(ColumnWizard)?> createColumnWizardFactories() {
    return {EmbeddingsColumnWizardFactory(): null};
  }

  @override
  List<BiocentralPluginDirectory> getPluginDirectories() {
    return [
      BiocentralPluginDirectory(
        path: 'active_learning',
        saveType: ALCampaign,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
        ) {
          final List<void Function(BuildContext)> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.name.contains('al_results.') && scannedFile.extension == 'json') {
              void loadingFunction(context) => getBiocentralCommandBloc(context).add(
                    BiocentralCommandExecuteEvent(
                      command: LoadALDatabaseCommand(
                        projectRepository: getBiocentralProjectRepository(context),
                        alRepository: getDatabase(context),
                        alDBFile: scannedFile,
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
