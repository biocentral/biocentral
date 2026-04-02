import 'dart:collection';

import 'package:biocentral/plugins/active_learning/active_learning_plugin.dart';
import 'package:biocentral/plugins/biocentral_core_plugins.dart';
import 'package:biocentral/plugins/custom_models/custom_models_plugin.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:equatable/equatable.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/tutorial_system.dart';

@immutable
class BiocentralPluginManager extends Equatable {
  final EventBus eventBus;
  final List<BiocentralPlugin> activePlugins;
  final Set<BiocentralPlugin> allAvailablePlugins;

  final _BiocentralPluginProperties _biocentralPluginProperties;

  factory BiocentralPluginManager({
    required EventBus eventBus,
    required BiocentralProjectRepository projectRepository,
    required BiocentralPythonCompanion companion,
    BuildContext? context,
    Set<BiocentralPlugin>? availablePlugins,
    Set<BiocentralPlugin>? selectedPlugins,
  }) {
    final allPluginsAndDefaultSelected = _loadCorePlugins(eventBus);

    final Set<BiocentralPlugin> allAvailablePlugins = availablePlugins ?? allPluginsAndDefaultSelected.$1;
    final Set<BiocentralPlugin> allSelectedPlugins = selectedPlugins ?? allPluginsAndDefaultSelected.$2;

    final List<BiocentralPlugin> allAvailablePluginsListForSorting = allAvailablePlugins.toList();
    // SORT BY POSITION IN ALL PLUGINS
    final SplayTreeSet<BiocentralPlugin> activePlugins = SplayTreeSet.from(
      allSelectedPlugins,
      (p1, p2) =>
          allAvailablePluginsListForSorting.indexOf(p1).compareTo(allAvailablePluginsListForSorting.indexOf(p2)),
    );

    final _BiocentralPluginProperties biocentralPluginProperties =
        _BiocentralPluginProperties(activePlugins, context, projectRepository, companion);
    return BiocentralPluginManager._(
        eventBus, List.from(activePlugins), allAvailablePlugins, biocentralPluginProperties);
  }

  const BiocentralPluginManager._(
      this.eventBus, this.activePlugins, this.allAvailablePlugins, this._biocentralPluginProperties);

  static (Set<BiocentralPlugin>, Set<BiocentralPlugin>) _loadCorePlugins(EventBus eventBus) {
    final ProteinPlugin proteinPlugin = ProteinPlugin(eventBus);
    // TODO PPI Plugin and ALPlugin Temporarily disabled
    //final PpiPlugin ppiPlugin = PpiPlugin(eventBus);
    final EmbeddingsPlugin embeddingsPlugin = EmbeddingsPlugin(eventBus);
    final CustomModelsPlugin customModelsPlugin = CustomModelsPlugin(eventBus);
    final ALPlugin alPlugin = ALPlugin(eventBus);
    return (
      {proteinPlugin, embeddingsPlugin, customModelsPlugin, alPlugin}, // All
      {proteinPlugin, embeddingsPlugin, customModelsPlugin, alPlugin}, // Default Selected
    );
  }

  void registerGlobalProperties(
    BiocentralColumnWizardRepository biocentralColumnWizardRepository,
    BiocentralDatabaseRepository biocentralDatabaseRepository,
    TutorialRepository tutorialRepository,
  ) {
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

  Map<BlocProvider, Bloc> getPluginBlocs(BuildContext context) {
    final Map<BlocProvider, Bloc> result = {};
    for (final plugin in activePlugins) {
      result.addAll(plugin.getListeningBlocs(context));
    }
    return result;
  }

  @override
  List<Object?> get props => [activePlugins, allAvailablePlugins];
}

class _BiocentralPluginProperties {
  final List<BiocentralDatabase> availableDatabases;
  final List<RepositoryProvider> pluginRepositories;
  final Map<ColumnWizardFactory, Widget Function(ColumnWizard)?> columnWizardFactories;
  final List<Tutorial> tutorials;

  factory _BiocentralPluginProperties(
    Set<BiocentralPlugin> activePlugins,
    BuildContext? context,
    BiocentralProjectRepository projectRepository,
    BiocentralPythonCompanion companion,
  ) {
    final List<BiocentralDatabase> availableDatabases = [];
    final List<RepositoryProvider> pluginRepositories = [];
    final Map<ColumnWizardFactory, Widget Function(ColumnWizard)?> columnWizardFactories = {};
    final List<Tutorial> tutorials = [];

    for (BiocentralPlugin plugin in activePlugins) {
      if (plugin is BiocentralDatabasePluginMixin) {
        // Database
        dynamic database;
        try {
          if (context != null) {
            database = plugin.getDatabaseIfAvailable(context);
          }
        } finally {
          // TODO [BUG] Create empty database without example data or sync
          database ??= plugin.createListeningDatabase(projectRepository, companion);
        }

        if (database is BiocentralDatabase) {
          availableDatabases.add(database);
        }
        pluginRepositories.add(plugin.createRepositoryProvider(database));

        // Directory
        final pluginDirectories = plugin.getPluginDirectories();
        for (final pluginDirectory in pluginDirectories) {
          projectRepository.registerPluginDirectory(pluginDirectory.saveType, pluginDirectory);
        }
      }
      if (plugin is BiocentralMultiDatabasePluginMixin) {
        // Multiple databases
        List<dynamic> databases = [];
        try {
          if (context != null) {
            databases = plugin.getDatabasesIfAvailable(context) ?? [];
          }
        } finally {
          // TODO [BUG] Create empty database without example data or sync
          databases = plugin.createDatabases(projectRepository, companion);
        }
        for (dynamic database in databases) {
          if (database is BiocentralDatabase) {
            availableDatabases.add(database);
          }
        }
        pluginRepositories.addAll(plugin.createRepositoryProviders(databases));
        // Directory
        final pluginDirectories = plugin.getPluginDirectories();
        for (final pluginDirectory in pluginDirectories) {
          projectRepository.registerPluginDirectory(pluginDirectory.saveType, pluginDirectory);
        }
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
      columnWizardFactories: columnWizardFactories,
      tutorials: tutorials,
    );
  }

  _BiocentralPluginProperties._({
    required this.availableDatabases,
    required this.pluginRepositories,
    required this.columnWizardFactories,
    required this.tutorials,
  });
}
