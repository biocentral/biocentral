import 'dart:collection';

import 'package:biocentral/plugins/biocentral_core_plugins.dart';
import 'package:biocentral/plugins/plm_eval/plm_eval_plugin.dart';
import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:biocentral/sdk/domain/biocentral_column_wizard_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_database.dart';
import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/model/column_wizard_abstract.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin.dart';
import 'package:equatable/equatable.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/tutorial_system.dart';

@immutable
class BiocentralPluginManager extends Equatable {
  static final EventBus eventBus = EventBus();

  final Set<BiocentralPlugin> activePlugins;
  final Set<BiocentralPlugin> allAvailablePlugins;

  final _BiocentralPluginProperties _biocentralPluginProperties;

  factory BiocentralPluginManager({
    BuildContext? context,
    Set<BiocentralPlugin>? availablePlugins,
    Set<BiocentralPlugin>? selectedPlugins,
  }) {
    final allPluginsAndDefaultSelected = _loadCorePlugins();

    final Set<BiocentralPlugin> allAvailablePlugins = availablePlugins ?? allPluginsAndDefaultSelected.$1;
    final Set<BiocentralPlugin> allSelectedPlugins = selectedPlugins ?? allPluginsAndDefaultSelected.$2;

    final List<BiocentralPlugin> allAvailablePluginsListForSorting = allAvailablePlugins.toList();
    // SORT BY POSITION IN ALL PLUGINS
    final SplayTreeSet<BiocentralPlugin> activePlugins = SplayTreeSet.from(
      allSelectedPlugins,
      (p1, p2) =>
          allAvailablePluginsListForSorting.indexOf(p1).compareTo(allAvailablePluginsListForSorting.indexOf(p2)),
    );

    final _BiocentralPluginProperties biocentralPluginProperties = _BiocentralPluginProperties(activePlugins, context);
    return BiocentralPluginManager._(Set.from(activePlugins), allAvailablePlugins, biocentralPluginProperties);
  }

  const BiocentralPluginManager._(this.activePlugins, this.allAvailablePlugins, this._biocentralPluginProperties);

  static (Set<BiocentralPlugin>, Set<BiocentralPlugin>) _loadCorePlugins() {
    final ProteinPlugin proteinPlugin = ProteinPlugin(eventBus);
    final PpiPlugin ppiPlugin = PpiPlugin(eventBus);
    final EmbeddingsPlugin embeddingsPlugin = EmbeddingsPlugin(eventBus);
    final PredictionModelsPlugin predictionModelsPlugin = PredictionModelsPlugin(eventBus);
    final PLMEvalPlugin plmEvalPlugin = PLMEvalPlugin(eventBus);
    return (
      {proteinPlugin, ppiPlugin, embeddingsPlugin, predictionModelsPlugin, plmEvalPlugin},
      {proteinPlugin, ppiPlugin, embeddingsPlugin, predictionModelsPlugin, plmEvalPlugin},
    );
  }

  void registerGlobalProperties(
    BiocentralClientRepository biocentralClientRepository,
    BiocentralColumnWizardRepository biocentralColumnWizardRepository,
    BiocentralDatabaseRepository biocentralDatabaseRepository,
    TutorialRepository tutorialRepository,
  ) {
    biocentralClientRepository.registerServices(_biocentralPluginProperties.clientFactories);
    biocentralColumnWizardRepository.registerFactories(_biocentralPluginProperties.columnWizardFactories);
    biocentralDatabaseRepository.addDatabases(_biocentralPluginProperties.availableDatabases);

    // TUTORIALS
    final List<BiocentralTutorialPluginMixin> tutorialPlugins =
        activePlugins.whereType<BiocentralTutorialPluginMixin>().toList();
    tutorialRepository.addTutorialContainers(_biocentralPluginProperties.tutorials);

    for (Tutorial tutorial in _biocentralPluginProperties.tutorials) {
      for (BiocentralTutorialPluginMixin tutorialPlugin in tutorialPlugins) {
        tutorialRepository.callRegistrationFunction(tutorialType: tutorial.runtimeType, caller: tutorialPlugin);
      }
    }
  }

  List<RepositoryProvider> getPluginRepositories() {
    return _biocentralPluginProperties.pluginRepositories;
  }

  @override
  List<Object?> get props => [activePlugins, allAvailablePlugins];
}

class _BiocentralPluginProperties {
  final List<BiocentralDatabase> availableDatabases;
  final List<RepositoryProvider> pluginRepositories;
  final List<BiocentralClientFactory> clientFactories;
  final Map<ColumnWizardFactory, Widget Function(ColumnWizard)?> columnWizardFactories;
  final List<Tutorial> tutorials;

  factory _BiocentralPluginProperties(Set<BiocentralPlugin> activePlugins, BuildContext? context) {
    final List<BiocentralDatabase> availableDatabases = [];
    final List<RepositoryProvider> pluginRepositories = [];
    final List<BiocentralClientFactory> clientFactories = [];
    final Map<ColumnWizardFactory, Widget Function(ColumnWizard)?> columnWizardFactories = {};
    final List<Tutorial> tutorials = [];

    for (BiocentralPlugin plugin in activePlugins) {
      if (plugin is BiocentralDatabasePluginMixin) {
        dynamic database;
        try {
          if (context != null) {
            database = plugin.getDatabaseIfAvailable(context);
          }
        } finally {
          // TODO [BUG] Create empty database without example data or sync
          database ??= plugin.createListeningDatabase();
        }

        if (database is BiocentralDatabase) {
          availableDatabases.add(database);
        }
        pluginRepositories.add(plugin.createRepositoryProvider(database));
      }
      if (plugin is BiocentralClientPluginMixin) {
        clientFactories.add(plugin.createClientFactory());
      }
      if (plugin is BiocentralColumnWizardPluginMixin) {
        columnWizardFactories.addAll(plugin.createColumnWizardFactories());
      }
      if (plugin is BiocentralTutorialPluginMixin) {
        tutorials.addAll(plugin.getTutorials());
      }
    }
    return _BiocentralPluginProperties._(
      availableDatabases: availableDatabases,
      pluginRepositories: pluginRepositories,
      clientFactories: clientFactories,
      columnWizardFactories: columnWizardFactories,
      tutorials: tutorials,
    );
  }

  _BiocentralPluginProperties._({
    required this.availableDatabases,
    required this.pluginRepositories,
    required this.clientFactories,
    required this.columnWizardFactories,
    required this.tutorials,
  });
}
