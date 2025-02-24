import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/tutorial_system.dart';

import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:biocentral/sdk/domain/biocentral_column_wizard_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/model/column_wizard_abstract.dart';
import 'package:biocentral/sdk/util/size_config.dart';


abstract class BiocentralPlugin with TypeNameMixin {
  final EventBus eventBus;

  BiocentralPlugin(this.eventBus);

  String getShortDescription();

  Set<Type> getDependencies() {
    // No dependencies by default
    return {};
  }

  Widget getIcon();

  Widget getTab();

  Widget getCommandView(BuildContext context);

  Widget getScreenView(BuildContext context);

  List<BlocProvider> getListeningBlocs(BuildContext context);

  BiocentralClientRepository getBiocentralClientRepository(BuildContext context) {
    return context.read<BiocentralClientRepository>();
  }

  BiocentralProjectRepository getBiocentralProjectRepository(BuildContext context) {
    return context.read<BiocentralProjectRepository>();
  }

  BiocentralDatabaseRepository getBiocentralDatabaseRepository(BuildContext context) {
    return context.read<BiocentralDatabaseRepository>();
  }

  BiocentralPythonCompanion getBiocentralPythonCompanion(BuildContext context) {
    return context.read<BiocentralPythonCompanion>();
  }

  BiocentralColumnWizardRepository getBiocentralColumnWizardRepository(BuildContext context) {
    return context.read<BiocentralColumnWizardRepository>();
  }

  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: getListeningBlocs(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          getCommandView(context),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal(context) * 0.75,
                vertical: 1,
              ),
              child: getScreenView(context),
            ),
          ),
        ],
      ),
    );
  }
}

mixin BiocentralClientPluginMixin<T extends BiocentralClient> on BiocentralPlugin {
  BiocentralClientFactory<T> createClientFactory();
}

mixin BiocentralDatabasePluginMixin<T> on BiocentralPlugin {
  T createListeningDatabase();

  RepositoryProvider<T> createRepositoryProvider(T database) {
    return RepositoryProvider<T>.value(value: database);
  }

  T getDatabase(BuildContext context) {
    return RepositoryProvider.of<T>(context);
  }

  T? getDatabaseIfAvailable(BuildContext context) {
    try {
      return RepositoryProvider.of<T>(context);
    } on FlutterError {
      return null;
    }
  }
}

mixin BiocentralColumnWizardPluginMixin on BiocentralPlugin {
  Map<ColumnWizardFactory, Widget Function(ColumnWizard)?> createColumnWizardFactories();
}

mixin BiocentralTutorialPluginMixin on BiocentralPlugin {
  List<Tutorial> getTutorials();
}
