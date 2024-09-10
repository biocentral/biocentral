import 'package:biocentral/plugins/biocentral_core_plugins.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/tutorial_system.dart';

import 'bloc/ppi_command_bloc.dart';
import 'bloc/ppi_database_grid_bloc.dart';
import 'bloc/ppi_database_tests_bloc.dart';
import 'bloc/ppi_properties_bloc.dart';
import 'data/ppi_client.dart';
import 'domain/ppi_repository.dart';
import 'model/load_example_ppi_dataset_tutorial.dart';
import 'presentation/displays/ppi_database_badges.dart';
import 'presentation/views/ppi_command_view.dart';
import 'presentation/views/ppi_database_tests_view.dart';
import 'presentation/views/ppi_database_view.dart';

class PpiPlugin extends BiocentralPlugin
    with
        BiocentralClientPluginMixin<PPIClient>,
        BiocentralDatabasePluginMixin<PPIRepository>,
        BiocentralTutorialPluginMixin {
  // TODO Check if this key handling works
  final GlobalKey<PPIDatabaseViewState> _ppiDatabaseViewState = GlobalKey<PPIDatabaseViewState>();
  final GlobalKey ppiTabKey = GlobalKey();

  PpiPlugin(super.eventBus);

  @override
  String getShortDescription() {
    return "Work with protein-protein interactions";
  }

  @override
  Set<Type> getDependencies() {
    return {ProteinPlugin};
  }

  @override
  Widget getCommandView(BuildContext context) {
    return const PPICommandView();
  }

  @override
  Widget getScreenView(BuildContext context) {
    return Column(
      children: [
        const Flexible(flex: 2, child: PPIDatabaseTestsView()),
        SizedBox(height: SizeConfig.safeBlockVertical(context)),
        const Flexible(flex: 1, child: PPIDatabaseBadges()),
        SizedBox(height: SizeConfig.safeBlockVertical(context)),
        Flexible(
          flex: 10,
          child: PPIDatabaseView(
            key: _ppiDatabaseViewState,
            // TODO Handle selection
            onInteractionSelected: (interaction) => null,
          ),
        ),
      ],
    );
  }

  @override
  Widget getIcon() {
    return const Icon(Icons.wifi_protected_setup);
  }

  @override
  Widget getTab() {
    return Tab(key: ppiTabKey, text: "Interactions", icon: getIcon());
  }

  @override
  PPIRepository createListeningDatabase() {
    PPIRepository ppiRepository = PPIRepository();
    eventBus.on<BiocentralDatabaseSyncEvent>().listen((event) {
      ppiRepository.syncFromDatabase(event.updatedEntities, event.importMode);
    });
    return ppiRepository;
  }

  @override
  List<BlocProvider> getListeningBlocs(BuildContext context) {
    final ppiCommandBloc = PPICommandBloc(getDatabase(context), getBiocentralClientRepository(context),
        getBiocentralProjectRepository(context), eventBus);
    final ppiPropertiesBloc = PPIPropertiesBloc(getDatabase(context))..add(PPIPropertiesCalculateEvent());
    final ppiDatabaseGridBloc = PPIDatabaseGridBloc(getDatabase(context))..add(PPIDatabaseGridLoadEvent());
    final ppiDatabaseTestsBloc = PPIDatabaseTestsBloc(getDatabase(context));

    eventBus.on<BiocentralDatabaseUpdatedEvent>().listen((event) {
      ppiDatabaseGridBloc.add(PPIDatabaseGridLoadEvent());
      ppiPropertiesBloc.add(PPIPropertiesCalculateEvent());
      ppiDatabaseTestsBloc.add(PPIDatabaseTestsLoadTestsEvent());
    });

    eventBus.on<BiocentralPluginTabSwitchedEvent>().listen((event) {
      if (event.switchedTab == getTab()) {
        ppiDatabaseGridBloc.add(PPIDatabaseGridLoadEvent());
      }
    });

    return [
      BlocProvider<PPICommandBloc>.value(value: ppiCommandBloc),
      BlocProvider<PPIPropertiesBloc>.value(value: ppiPropertiesBloc),
      BlocProvider<PPIDatabaseGridBloc>.value(value: ppiDatabaseGridBloc),
      BlocProvider<PPIDatabaseTestsBloc>.value(value: ppiDatabaseTestsBloc)
    ];
  }

  @override
  BiocentralClientFactory<PPIClient> createClientFactory() {
    return PPIClientFactory();
  }

  @override
  List<Tutorial> getTutorials() {
    return [LoadExampleInteractionDatasetTutorialContainer()];
  }
}
