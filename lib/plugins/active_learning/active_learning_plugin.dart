import 'package:biocentral/plugins/active_learning/bloc/al_hub_bloc.dart';
import 'package:biocentral/plugins/active_learning/bloc/al_iteration_bloc.dart';
import 'package:biocentral/plugins/active_learning/domain/al_repository.dart';
import 'package:biocentral/plugins/active_learning/model/al_training_result.dart';
import 'package:biocentral/plugins/active_learning/presentation/views/al_command_view.dart';
import 'package:biocentral/plugins/active_learning/presentation/views/al_hub_view.dart';
import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Plugin for integrating Active Learning functionality into the Biocentral platform.
class ALPlugin extends BiocentralPlugin
    with
        BiocentralDatabasePluginMixin<ALRepository>,
        BiocentralColumnWizardPluginMixin {
  /// Creates a new [ALPlugin] instance.
  ALPlugin(super.eventBus);

  @override
  String get typeName => 'ALPlugin';

  @override
  String getShortDescription() {
    return 'Perform experiments on sparse data using active learning';
  }

  @override
  ALRepository createListeningDatabase(BiocentralProjectRepository projectRepository) {
    final repository = ALRepository(projectRepository);
    return repository;
  }

  @override
  Widget getCommandView(BuildContext context) {
    return const ALCommandView();
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final alHubBloc = ALHubBloc(
      getDatabase(context),
      getBiocentralProjectRepository(context),
      getBiocentralAPIRepository(context),
      eventBus,
      getBiocentralDatabaseRepository(context),
    );
    final alIterationBloc = ALIterationBloc(
      getBiocentralProjectRepository(context),
      getDatabase(context),
      getBiocentralDatabaseRepository(context),
      getBiocentralAPIRepository(context),
      eventBus,
    );

    eventBusSubscriptions.add(eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      alHubBloc.add(ALHubLoadEvent());
    }),);

    return {
      BlocProvider<ALHubBloc>.value(
        value: alHubBloc,
      ): alHubBloc,
      BlocProvider<ALIterationBloc>.value(
        value: alIterationBloc,
      ): alIterationBloc,
    };
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const ALHubView();
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
        saveType: ALTrainingResult,
        commandBlocType: ALHubBloc,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
          List<BiocentralCommandLog> commandLogs,
          dynamic commandBloc,
        ) {
          final List<void Function()> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.name.contains('al_results.') && scannedFile.extension == 'json') {
              void loadingFunction() => commandBloc?.add(
                    ALHubLoadTrainingsFromFileEvent(
                      xFile: scannedFile,
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
