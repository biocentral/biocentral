import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_training_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/model_hub_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/prediction_model_events.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_output_dir_handler.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_client.dart';
import 'package:biocentral/plugins/prediction_models/domain/prediction_model_repository.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/plugins/prediction_models/presentation/views/model_command_view.dart';
import 'package:biocentral/plugins/prediction_models/presentation/views/model_hub_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PredictionModelsPlugin extends BiocentralPlugin
    with BiocentralClientPluginMixin<PredictionModelsClient>, BiocentralDatabasePluginMixin<PredictionModelRepository> {
  PredictionModelsPlugin(super.eventBus);

  @override
  String get typeName => 'PredictionModelsPlugin';

  @override
  String getShortDescription() {
    return 'Train models on your data and use them for new predictions';
  }

  @override
  PredictionModelRepository createListeningDatabase(BiocentralProjectRepository projectRepository) {
    return PredictionModelRepository(projectRepository);
  }

  @override
  Widget getCommandView(BuildContext context) {
    return ModelCommandView(eventBus: eventBus);
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final biotrainerTrainingBloc = BiotrainerTrainingBloc(
      getDatabase(context),
      getBiocentralClientRepository(context),
      getBiocentralDatabaseRepository(context),
      getBiocentralProjectRepository(context),
      eventBus,
    );
    final modelHubBloc = ModelHubBloc(getBiocentralProjectRepository(context), getDatabase(context));

    // TODO This should probably be directly injected into the bloc, not via event bus
    eventBusSubscriptions.add(eventBus.on<BiotrainerStartTrainingEvent>().listen((event) {
      biotrainerTrainingBloc.add(BiotrainerTrainingStartTrainingEvent(event.databaseType, event.trainingConfiguration));
    }));

    eventBusSubscriptions.add(eventBus.on<BiocentralResumableCommandFinishedEvent>().listen((event) {
      modelHubBloc.add(ModelHubRemoveResumableCommandEvent(event.finishedCommand));
    }));

    eventBusSubscriptions.add(eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      modelHubBloc.add(ModelHubLoadEvent());
    }));

    eventBusSubscriptions.add(eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
      if (event.switchedTab == getTab()) {
        modelHubBloc.add(ModelHubLoadEvent());
      }
    }));

    return {
      BlocProvider<BiotrainerTrainingBloc>.value(value: biotrainerTrainingBloc): biotrainerTrainingBloc,
      BlocProvider<ModelHubBloc>.value(value: modelHubBloc): modelHubBloc,
    };
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const ModelHubView();
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.model_training);
  }

  @override
  Widget getTab() {
    return Tab(text: 'Models', icon: getIcon());
  }

  @override
  BiocentralClientFactory<PredictionModelsClient> createClientFactory() {
    return PredictionModelsClientFactory();
  }

  @override
  List<BiocentralPluginDirectory> getPluginDirectories() {
    return [
      BiocentralPluginDirectory(
        path: 'models',
        saveType: PredictionModel,
        commandBlocType: ModelHubBloc,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
          List<BiocentralCommandLog> commandLogs,
          dynamic commandBloc,
        ) {
          final List<void Function()> loadingFunctions = [];
          for (final subDir in scannedSubDirectories.entries) {
            final (configFile, outputFile, loggingFile, checkpointFile) =
                BiotrainerOutputDirHandler.scanDirectoryFiles(subDir.value);
            void loadingFunction() => commandBloc?.add(
                  ModelHubLoadModelEvent(
                    configFile: configFile,
                    outputFile: outputFile,
                    loggingFile: loggingFile,
                    checkpointFile: checkpointFile,
                    importMode: DatabaseImportMode.overwrite,
                  ),
                );
            loadingFunctions.add(loadingFunction);
          }
          void loadResumableCommandFunction() => commandBloc?.add(ModelHubAddResumableCommandsEvent(commandLogs));
          loadingFunctions.add(loadResumableCommandFunction);
          return loadingFunctions;
        },
      ),
    ];
  }
}
