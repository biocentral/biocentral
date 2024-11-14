import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/embeddings/bloc/embeddings_command_bloc.dart';
import 'package:biocentral/plugins/embeddings/bloc/embeddings_hub_bloc.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_client.dart';
import 'package:biocentral/plugins/embeddings/domain/embeddings_repository.dart';
import 'package:biocentral/plugins/embeddings/model/embeddings_column_wizard.dart';
import 'package:biocentral/plugins/embeddings/presentation/views/embeddings_command_view.dart';
import 'package:biocentral/plugins/embeddings/presentation/views/embeddings_hub_view.dart';

class EmbeddingsPlugin extends BiocentralPlugin
    with
        BiocentralClientPluginMixin<EmbeddingsClient>,
        BiocentralDatabasePluginMixin<EmbeddingsRepository>,
        BiocentralColumnWizardPluginMixin {
  EmbeddingsPlugin(super.eventBus);

  @override
  String get typeName => 'EmbeddingsPlugin';

  @override
  String getShortDescription() {
    return 'Calculate, analyze and visualize embeddings for biological entities';
  }

  @override
  BiocentralClientFactory<EmbeddingsClient> createClientFactory() {
    return EmbeddingsClientFactory();
  }

  @override
  EmbeddingsRepository createListeningDatabase() {
    final embeddingsRepository = EmbeddingsRepository();
    return embeddingsRepository;
  }

  @override
  Widget getCommandView(BuildContext context) {
    return const EmbeddingsCommandView();
  }

  @override
  List<BlocProvider> getListeningBlocs(BuildContext context) {
    final embeddingsCommandBloc = EmbeddingsCommandBloc(
        getBiocentralDatabaseRepository(context),
        getBiocentralClientRepository(context),
        getBiocentralProjectRepository(context),
        getDatabase(context),
        eventBus,);
    final embeddingsHubBloc = EmbeddingsHubBloc(
        getBiocentralColumnWizardRepository(context), getBiocentralDatabaseRepository(context), getDatabase(context),);

    eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      embeddingsHubBloc.add(EmbeddingsHubReloadEvent());
    });

    eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
      if (event.switchedTab == getTab()) {
        embeddingsHubBloc.add(EmbeddingsHubReloadEvent());
      }
    });

    return [
      BlocProvider<EmbeddingsCommandBloc>.value(value: embeddingsCommandBloc),
      BlocProvider<EmbeddingsHubBloc>.value(value: embeddingsHubBloc),
    ];
  }

  @override
  Widget getScreenView(BuildContext context) {
    return const EmbeddingsHubView();
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.calculate);
  }

  @override
  Widget getTab() {
    return Tab(text: 'Embeddings', icon: getIcon());
  }

  @override
  List<ColumnWizardFactory<ColumnWizard>> createColumnWizardFactories() {
    return [EmbeddingsColumnWizardFactory()];
  }
}
