import 'package:biocentral/plugins/embeddings/embeddings_plugin.dart';
import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_command_bloc.dart';
import 'package:biocentral/plugins/plm_eval/bloc/plm_eval_leaderboard_bloc.dart';
import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
import 'package:biocentral/plugins/plm_eval/presentation/views/plm_eval_command_view.dart';
import 'package:biocentral/plugins/plm_eval/presentation/views/plm_eval_view.dart';
import 'package:biocentral/plugins/prediction_models/prediction_models_plugin.dart';
import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PLMEvalPlugin extends BiocentralPlugin with BiocentralClientPluginMixin {
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
  List<BlocProvider<StateStreamableSource<Object?>>> getListeningBlocs(BuildContext context) {
    final plmEvalCommandBloc = PLMEvalCommandBloc(getBiocentralClientRepository(context));
    final plmEvalLeaderboardBloc = PLMEvalLeaderboardBloc(getBiocentralClientRepository(context))
      ..add(PLMEvalLeaderboardLoadEvent());

    return [
      BlocProvider<PLMEvalCommandBloc>.value(value: plmEvalCommandBloc),
      BlocProvider<PLMEvalLeaderboardBloc>.value(value: plmEvalLeaderboardBloc),
    ];
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const PLMEvalView();
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

}
