import 'package:biocentral/plugins/protein_engineering/bloc/engineering_commands.dart';
import 'package:biocentral/plugins/protein_engineering/bloc/engineering_hub_bloc.dart';
import 'package:biocentral/plugins/protein_engineering/domain/engineering_repository.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/views/engineering_hub_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Plugin for suggesting protein engineering mutations, tracking measurements, and repeating.
class EngineeringPlugin extends BiocentralPlugin with BiocentralDatabasePluginMixin<EngineeringRepository> {
  EngineeringPlugin(super.eventBus);

  @override
  String get typeName => 'EngineeringPlugin';

  @override
  String getShortDescription() {
    return 'Suggest protein engineering mutations, measure them, and feed the results back';
  }

  @override
  EngineeringRepository createListeningDatabase(
    BiocentralProjectRepository projectRepository,
    BiocentralPythonCompanion companion,
  ) {
    return EngineeringRepository(projectRepository);
  }

  // The redesigned hub has its own campaign/section navigation; it doesn't use a generic
  // command list, so there are no widgets to contribute here.
  @override
  List<Widget> getCommandWidgets() => const [];

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final engineeringHubBloc = EngineeringHubBloc(getDatabase(context));

    return {BlocProvider<EngineeringHubBloc>.value(value: engineeringHubBloc): engineeringHubBloc};
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const EngineeringHubView();
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.science_outlined);
  }

  @override
  Widget getTab() {
    return Tab(text: 'Protein Engineering', icon: getIcon());
  }

  @override
  List<BiocentralPluginDirectory> getPluginDirectories() {
    return [
      BiocentralPluginDirectory(
        path: 'protein_engineering',
        saveType: EngineeringCampaign,
        createDirectoryLoadingEvents: (List<XFile> scannedFiles, Map<String, List<XFile>> scannedSubDirectories) {
          final List<void Function(BuildContext)> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.name.contains('engineering_results.') && scannedFile.extension == 'json') {
              void loadingFunction(context) => getBiocentralCommandBloc(context).add(
                BiocentralCommandExecuteEvent(
                  command: LoadEngineeringCampaignCommand.fromFile(
                    repository: getDatabase(context),
                    campaignFile: scannedFile,
                    mode: DatabaseImportMode.overwrite,
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
