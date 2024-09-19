import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/protein_database_grid_bloc.dart';
import 'bloc/proteins_command_bloc.dart';
import 'data/protein_client.dart';
import 'domain/protein_repository.dart';
import 'presentation/views/protein_database_view.dart';
import 'presentation/views/proteins_command_view.dart';

class ProteinPlugin extends BiocentralPlugin
    with BiocentralClientPluginMixin<ProteinClient>, BiocentralDatabasePluginMixin<ProteinRepository> {
  final GlobalKey<ProteinDatabaseViewState> _proteinDatabaseViewState = GlobalKey<ProteinDatabaseViewState>();

  ProteinPlugin(super.eventBus);

  @override
  String get typeName => "ProteinPlugin";

  @override
  String getShortDescription() {
    return "Work with protein data";
  }

  @override
  ProteinRepository createListeningDatabase() {
    final proteinRepository = ProteinRepository();
    eventBus.on<BiocentralDatabaseSyncEvent>().listen((event) {
      proteinRepository.syncFromDatabase(event.updatedEntities, event.importMode);
    });
    return proteinRepository;
  }

  @override
  Widget getCommandView(BuildContext context) {
    return const ProteinsCommandView();
  }

  @override
  List<BlocProvider> getListeningBlocs(BuildContext context) {
    final proteinCommandBloc = ProteinsCommandBloc(getDatabase(context), getBiocentralClientRepository(context),
        getBiocentralProjectRepository(context), eventBus);
    final proteinDatabaseGridBloc = ProteinDatabaseGridBloc(getDatabase(context))..add(ProteinDatabaseGridLoadEvent());

    eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      proteinDatabaseGridBloc.add(ProteinDatabaseGridLoadEvent());
    });

    eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
      if (event.switchedTab == getTab()) {
        proteinDatabaseGridBloc.add(ProteinDatabaseGridLoadEvent());
      }
    });

    return [
      BlocProvider<ProteinsCommandBloc>.value(value: proteinCommandBloc),
      BlocProvider<ProteinDatabaseGridBloc>.value(value: proteinDatabaseGridBloc)
    ];
  }

  @override
  Widget getScreenView(BuildContext context) {
    return ProteinDatabaseView(
      key: _proteinDatabaseViewState,
      // TODO Protein selection
      onProteinSelected: (protein) => null,
    );
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.list_alt);
  }

  @override
  Widget getTab() {
    return Tab(text: "Proteins", icon: getIcon());
  }

  @override
  BiocentralClientFactory<ProteinClient> createClientFactory() {
    return ProteinClientFactory();
  }
}
