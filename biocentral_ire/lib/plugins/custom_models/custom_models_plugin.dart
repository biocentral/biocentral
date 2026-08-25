import 'package:biocentral/plugins/custom_models/bloc/model_hub_bloc.dart';
import 'package:biocentral/plugins/custom_models/bloc/models_commands.dart';
import 'package:biocentral/plugins/custom_models/domain/prediction_model_repository.dart';
import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/plugins/custom_models/presentation/commands/inference_command_display.dart';
import 'package:biocentral/plugins/custom_models/presentation/commands/load_model_command_display.dart';
import 'package:biocentral/plugins/custom_models/presentation/commands/split_data_command_display.dart';
import 'package:biocentral/plugins/custom_models/presentation/commands/training_command_display.dart';
import 'package:biocentral/plugins/custom_models/presentation/views/model_hub_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomModelsPlugin extends BiocentralPlugin with BiocentralDatabasePluginMixin<CustomModelRepository> {
  CustomModelsPlugin(super.eventBus);

  @override
  String get typeName => 'CustomModelsPlugin';

  @override
  String getShortDescription() {
    return 'Train models on your data and use them for new predictions';
  }

  @override
  CustomModelRepository createListeningDatabase(
      BiocentralProjectRepository projectRepository, BiocentralPythonCompanion companion) {
    return CustomModelRepository(projectRepository);
  }

  @override
  List<Widget> getCommandWidgets() {
    return [
      const LoadModelCommandDisplay(),
      const SplitDataCommandDisplay(),
      const TrainModelCommandDisplay(),
      const InferenceCommandDisplay(),
    ];
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final modelHubBloc = ModelHubBloc(getBiocentralProjectRepository(context), getDatabase(context));

    return {
      BlocProvider<ModelHubBloc>.value(value: modelHubBloc): modelHubBloc,
    };
  }

  @override
  Widget getScreenView(BuildContext context) {
    return ModelHubView(
      commandWidgets: getCommandWidgets(),
    );
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
  List<BiocentralPluginDirectory> getPluginDirectories() {
    return [
      BiocentralPluginDirectory(
        path: 'models',
        saveType: PredictionModel,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
        ) {
          final List<void Function(BuildContext context)> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.name.contains('model_db') && scannedFile.extension == 'json') {
              void loadingFunction(context) => getBiocentralCommandBloc(context).add(
                    BiocentralCommandExecuteEvent(
                      command: LoadModelDatabaseCommand(
                        projectRepository: getBiocentralProjectRepository(context),
                        modelRepository: getDatabase(context),
                        modelDBFile: scannedFile,
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
