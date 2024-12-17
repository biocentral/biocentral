import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:biocentral/biocentral/bloc/biocentral_plugins_bloc.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_main_view.dart';
import 'package:biocentral/biocentral/presentation/views/start_page_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/tutorial_system.dart';

void main() async {
  final BiocentralProjectRepository projectRepository =
      await BiocentralProjectRepository.fromLastProjectDirectory();
  final BiocentralPluginManager pluginManager = BiocentralPluginManager();
  final BiocentralPythonCompanion pythonCompanion = BiocentralPythonCompanion.start();

  runApp(
    BiocentralApp(
      projectRepository: projectRepository,
      pluginManager: pluginManager,
      pythonCompanion: pythonCompanion,
    ),
  );
}

@immutable
class BiocentralApp extends StatefulWidget {
  final BiocentralProjectRepository projectRepository;
  final BiocentralPluginManager pluginManager;
  final BiocentralPythonCompanion pythonCompanion;

  const BiocentralApp({
    required this.projectRepository,
    required this.pluginManager,
    required this.pythonCompanion,
    super.key,
  });

  @override
  State<BiocentralApp> createState() => _BiocentralAppState();
}

class _BiocentralAppState extends State<BiocentralApp> {
  final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();
  BiocentralClientRepository? oldClientRepository;

  @override
  void initState() {
    super.initState();
  }

  /// Creates global repositories that are available to all plugins
  List<RepositoryProvider> getGlobalRepositoryProviders(BuildContext context, BiocentralPluginManager pluginManager) {
    final BiocentralClientRepository biocentralClientRepository =
        BiocentralClientRepository.withReload(oldClientRepository);
    oldClientRepository = biocentralClientRepository;

    final BiocentralColumnWizardRepository biocentralColumnWizardRepository =
        BiocentralColumnWizardRepository.withDefaultWizards();
    final BiocentralDatabaseRepository biocentralDatabaseRepository = BiocentralDatabaseRepository();
    final TutorialRepository tutorialRepository = TutorialRepository(globalNavigatorKey);

    pluginManager.registerGlobalProperties(
      biocentralClientRepository,
      biocentralColumnWizardRepository,
      biocentralDatabaseRepository,
      tutorialRepository,
    );

    return [
      RepositoryProvider<BiocentralProjectRepository>.value(value: widget.projectRepository),
      RepositoryProvider<BiocentralPythonCompanion>.value(value: widget.pythonCompanion),
      RepositoryProvider<BiocentralDatabaseRepository>.value(value: biocentralDatabaseRepository),
      RepositoryProvider<BiocentralClientRepository>.value(value: biocentralClientRepository),
      RepositoryProvider<BiocentralColumnWizardRepository>.value(value: biocentralColumnWizardRepository),
      RepositoryProvider<TutorialRepository>.value(value: tutorialRepository),
    ];
  }

  /// Creates global blocs that are available to all plugins
  List<BlocProvider> getGlobalBlocProviders() {
    return [
      BlocProvider<BiocentralClientBloc>(
        create: (context) => BiocentralClientBloc(
          context.read<BiocentralClientRepository>(),
          context.read<BiocentralProjectRepository>(),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BiocentralPluginBloc>(
      create: (context) => BiocentralPluginBloc(widget.pluginManager),
      child: BlocBuilder<BiocentralPluginBloc, BiocentralPluginState>(
        buildWhen: (sOld, sNew) =>
            sOld.status == BiocentralPluginStatus.loading && sNew.status == BiocentralPluginStatus.loaded,
        builder: (context, pluginState) => MultiRepositoryProvider(
          providers: [
            ...getGlobalRepositoryProviders(context, pluginState.pluginManager),
            ...pluginState.pluginManager.getPluginRepositories(),
          ],
          child: MaterialApp(
            navigatorKey: globalNavigatorKey,
            title: 'Biocentral',
            theme: BiocentralStyle.darkTheme,
            home: buildHome(pluginState),
          ),
        ),
      ),
    );
  }

  Widget buildHome(BiocentralPluginState pluginState) {
    return AnimatedSplashScreen(
      backgroundColor: const Color.fromRGBO(0, 19, 58, 1.0),
      duration: 1500,
      splash: 'assets/biocentral_logo/biocentral_logo.png',
      nextScreen: buildScreenAfterSplash(pluginState),
    );
  }

  Widget buildScreenAfterSplash(BiocentralPluginState pluginState) {
    final List<BlocProvider> globalBlocProviders = getGlobalBlocProviders();
    if (kIsWeb || !widget.projectRepository.isDirectoryPathSet()) {
      return StartPageView(
        providers: globalBlocProviders,
        pluginManager: pluginState.pluginManager,
        eventBus: BiocentralPluginManager.eventBus,
      );
    } else {
      return MultiBlocProvider(
        providers: globalBlocProviders,
        child: BiocentralMainView(eventBus: BiocentralPluginManager.eventBus),
      );
    }
  }
}
