import 'package:biocentral/plugins/embeddings/embeddings_plugin.dart';
import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_evaluation_bloc.dart';
import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_hub_bloc.dart';
import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_leaderboard_bloc.dart';
import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
import 'package:biocentral/plugins/plm_eval/domain/plm_eval_repository.dart';
import 'package:biocentral/plugins/plm_eval/model/plm_eval_persistent_result.dart';
import 'package:biocentral/plugins/plm_eval/presentation/views/plm_eval_command_view.dart';
import 'package:biocentral/plugins/plm_eval/presentation/views/plm_eval_hub_view.dart';
import 'package:biocentral/plugins/prediction_models/prediction_models_plugin.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PLMEvalPlugin extends BiocentralPlugin
    with BiocentralClientPluginMixin, BiocentralDatabasePluginMixin<PLMEvalRepository> {
  PLMEvalPlugin(super.eventBus);

  @override
  Widget getCommandView(BuildContext context) {
    return const PLMEvalCommandView();
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.fact_check_outlined);
  }

  @override
  Map<BlocProvider, Bloc> getListeningBlocs(BuildContext context) {
    cancelSubscriptions();

    final plmEvalCommandBloc = PLMEvalEvaluationBloc(
      getBiocentralProjectRepository(context),
      getBiocentralClientRepository(context),
      getDatabase(context),
      eventBus,
    );


    final plmEvalLeaderboardBloc = PLMEvalLeaderboardBloc(getBiocentralClientRepository(context), getDatabase(context))
      ..add(PLMEvalLeaderboardDownloadEvent());

    final plmEvalHubBloc = PLMEvalHubBloc(getBiocentralProjectRepository(context), getDatabase(context), eventBus);

    eventBusSubscriptions.add(eventBus.on<BiocentralResumableCommandFinishedEvent>().listen((event) {
      plmEvalHubBloc.add(PLMEvalHubRemoveResumableCommandEvent(event.finishedCommand));
    }));

    eventBusSubscriptions.add(eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      plmEvalHubBloc.add(PLMEvalHubLoadEvent());
      plmEvalLeaderboardBloc.add(PLMEvalLeaderboardLoadLocalEvent());
    }));

    return {
      BlocProvider<PLMEvalEvaluationBloc>.value(value: plmEvalCommandBloc): plmEvalCommandBloc,
      BlocProvider<PLMEvalHubBloc>.value(value: plmEvalHubBloc): plmEvalHubBloc,
      BlocProvider<PLMEvalLeaderboardBloc>.value(value: plmEvalLeaderboardBloc): plmEvalLeaderboardBloc,
    };
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const PLMEvalHubView();
  }

  @override
  String getShortDescription() {
    return 'Evaluate your protein language model against benchmark datasets';
  }

  @override
  Widget getTab() {
    return Tab(text: 'pLM Evaluation', icon: getIcon());
  }

  @override
  String get typeName => 'PLMEvalPlugin';

  @override
  BiocentralClientFactory<BiocentralClient> createClientFactory() {
    return PLMEvalClientFactory();
  }

  @override
  Set<Type> getDependencies() {
    return {PredictionModelsPlugin, EmbeddingsPlugin};
  }

  @override
  PLMEvalRepository createListeningDatabase(BiocentralProjectRepository projectRepository) {
    return PLMEvalRepository(projectRepository);
  }

  @override
  List<BiocentralPluginDirectory> getPluginDirectories() {
    return [
      BiocentralPluginDirectory(
        path: 'plm_eval',
        saveType: PLMEvalPersistentResult,
        commandBlocType: PLMEvalHubBloc,
        createDirectoryLoadingEvents: (
          List<XFile> scannedFiles,
          Map<String, List<XFile>> scannedSubDirectories,
          List<BiocentralCommandLog> commandLogs,
          dynamic commandBloc,
        ) {
          final List<void Function()> loadingFunctions = [];
          for (final scannedFile in scannedFiles) {
            if (scannedFile.name.contains('plm_eval_results.') && scannedFile.extension == 'json') {
              void loadingFunction() => commandBloc?.add(
                    PLMEvalHubLoadPersistentResultsEvent(scannedFile),
                  );
              loadingFunctions.add(loadingFunction);
            }
          }
          void loadResumableCommandFunction() => commandBloc?.add(PLMEvalHubAddResumableCommandsEvent(commandLogs));
          loadingFunctions.add(loadResumableCommandFunction);
          return loadingFunctions;
        },
      ),
    ];
  }
}
