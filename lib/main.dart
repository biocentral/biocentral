import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:biocentral/biocentral/bloc/biocentral_load_project_bloc.dart';
import 'package:biocentral/biocentral/bloc/biocentral_plugins_bloc.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_load_project_view.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_start_page_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/theme/theme_event.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/bloc/theme/theme_bloc.dart';
import 'package:biocentral/sdk/bloc/theme/theme_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/tutorial_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final BiocentralProjectRepository projectRepository = await BiocentralProjectRepository.fromLastProjectDirectory();
  final BiocentralPluginManager pluginManager = BiocentralPluginManager(projectRepository: projectRepository);
  final BiocentralPythonCompanion pythonCompanion = await BiocentralPythonCompanion.startCompanion();

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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BiocentralPluginBloc>(
          create: (context) => BiocentralPluginBloc(widget.pluginManager),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(InitializeThemeEvent()),
        ),
      ],
      child: BlocBuilder<BiocentralPluginBloc, BiocentralPluginState>(
        buildWhen: (sOld, sNew) =>
            sOld.status == BiocentralPluginStatus.loading && sNew.status == BiocentralPluginStatus.loaded,
        builder: (context, pluginState) => MultiRepositoryProvider(
          providers: [
            ...getGlobalRepositoryProviders(context, pluginState.pluginManager),
            ...pluginState.pluginManager.getPluginRepositories(),
          ],
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp(
                navigatorKey: globalNavigatorKey,
                title: 'Biocentral',
                theme: themeState.isDarkMode ? BiocentralStyle.darkTheme : BiocentralStyle.lightTheme,
                home: BiocentralAppHome(isDirectoryPathSet: widget.projectRepository.isProjectDirectoryPathSet()),
              );
            },
          ),
        ),
      ),
    );
  }
}

class BiocentralAppHome extends StatelessWidget {
  final bool isDirectoryPathSet;

  const BiocentralAppHome({required this.isDirectoryPathSet, super.key});

  /// Creates global blocs that are available to all plugins
  Map<BlocProvider, Bloc> getGlobalBlocProviders(BuildContext context) {
    final biocentralClientBloc = BiocentralClientBloc(
      context.read<BiocentralClientRepository>(),
      context.read<BiocentralProjectRepository>(),
    );
    return {
      BlocProvider<BiocentralClientBloc>.value(
        value: biocentralClientBloc,
      ): biocentralClientBloc,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiocentralPluginBloc, BiocentralPluginState>(
      builder: (context, pluginState) => AnimatedSplashScreen(
        backgroundColor: const Color.fromRGBO(0, 19, 58, 1.0),
        duration: 1500,
        splash: 'assets/biocentral_logo/biocentral_logo.png',
        nextScreen: buildScreenAfterSplash(pluginState, context),
      ),
    );
  }

  Widget buildScreenAfterSplash(BiocentralPluginState pluginState, BuildContext context) {
    final Map<BlocProvider, Bloc> globalBlocProviders = getGlobalBlocProviders(context);
    final Map<BlocProvider, Bloc> pluginBlocProviders = pluginState.pluginManager.getPluginBlocs(context);
    final Map<BlocProvider, Bloc> allBlocProviders = {...globalBlocProviders, ...pluginBlocProviders};

    final projectRepository = context.read<BiocentralProjectRepository>();
    if (kIsWeb || !isDirectoryPathSet) {
      return BiocentralStartPageView(
        providers: allBlocProviders.keys.toList(),
        pluginManager: pluginState.pluginManager,
        eventBus: BiocentralPluginManager.eventBus,
      );
    } else {
      return BlocProvider(
        create: (context) => BiocentralLoadProjectBloc(
          projectRepository,
          allBlocProviders.values.toList(),
          projectRepository.getAllPluginDirectories(),
        )..add(
            BiocentralLoadProjectFromDirectoryEvent(
              projectRepository.getProjectDirectoryPath(),
            ),
          ),
        child: BiocentralLoadProjectView(
          providers: allBlocProviders.keys.toList(),
          pluginManager: pluginState.pluginManager,
          eventBus: BiocentralPluginManager.eventBus,
        ),
      );
    }
  }
}
