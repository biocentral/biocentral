import 'package:biocentral/plugins/plm_eval/data/plm_eval_client.dart';
import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin.dart';
import 'package:bloc/src/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/src/bloc_provider.dart';

import 'bloc/plm_eval_command_bloc.dart';
import 'presentation/views/plm_eval_command_view.dart';
import 'presentation/views/plm_eval_view.dart';

class PLMEvalPlugin extends BiocentralPlugin with BiocentralClientPluginMixin {
  PLMEvalPlugin(super.eventBus);

  @override
  Widget getCommandView(BuildContext context) {
    return PLMEvalCommandView();
  }

  @override
  Widget getIcon() {
    return Icon(Icons.fact_check_outlined);
  }

  @override
  List<BlocProvider<StateStreamableSource<Object?>>> getListeningBlocs(BuildContext context) {
    final plmEvalCommandBloc = PLMEvalCommandBloc();
    return [
      BlocProvider<PLMEvalCommandBloc>.value(value: plmEvalCommandBloc),
    ];
  }

  @override
  Widget getScreenView(BuildContext context) {
    return PLMEvalView();
  }

  @override
  String getShortDescription() {
    return "Evaluate your protein language model against benchmark datasets";
  }

  @override
  Widget getTab() {
    return Tab(text: "pLM Evaluation", icon: getIcon());
  }

  @override
  String get typeName => "PLMEvalPlugin";

  @override
  BiocentralClientFactory<BiocentralClient> createClientFactory() {
    return PLMEvalClientFactory();
  }
}
