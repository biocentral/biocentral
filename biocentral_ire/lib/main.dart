import 'dart:ui';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:biocentral/biocentral/bloc/biocentral_load_project_bloc.dart';
import 'package:biocentral/biocentral/bloc/biocentral_plugins_bloc.dart';
import 'package:biocentral/biocentral/bloc/biocentral_sidebar_bloc.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_load_project_view.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_start_page_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_api_health_service.dart';
import 'package:biocentral/sdk/bloc/theme/theme_bloc.dart';
import 'package:biocentral/sdk/bloc/theme/theme_event.dart';
import 'package:biocentral/sdk/bloc/theme/theme_state.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/domain/biocentral_command_log_repository.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/tutorial_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final BiocentralAPI biocentralAPI = await BiocentralAPI.createWithHealthCheck(localOnly: false);
  final BiocentralAPIRepository apiRepository = await BiocentralAPIRepository.create(biocentralAPI);
  final BiocentralAPIHealthService healthService = BiocentralAPIHealthService(apiRepository);
  healthService.startMonitoring();
  final BiocentralPythonCompanion pythonCompanion = await BiocentralPythonCompanion.startCompanion();

  runApp(
    BiocentralProcessRoot(
      apiRepository: apiRepository,
      pythonCompanion: pythonCompanion,
    ),
  );
}

/// Owns everything that must survive a "close project": the Python companion process,
/// the remote API repository/health monitoring, and the app-exit hook that terminates
/// the companion. Everything project-specific lives below [_projectKey] in
/// [BiocentralProjectShell] and is torn down and rebuilt from scratch on every close.
@immutable
class BiocentralProcessRoot extends StatefulWidget {
  final BiocentralAPIRepository apiRepository;
  final BiocentralPythonCompanion pythonCompanion;

  const BiocentralProcessRoot({
    required this.apiRepository,
    required this.pythonCompanion,
    super.key,
  });

  @override
  State<BiocentralProcessRoot> createState() => _BiocentralProcessRootState();
}

class _BiocentralProcessRootState extends State<BiocentralProcessRoot> {
  Key _projectKey = UniqueKey();

  late final AppLifecycleListener _exitListener;

  @override
  void initState() {
    super.initState();
    _exitListener = AppLifecycleListener(
      onExitRequested: () async {
        await widget.pythonCompanion.terminate();
        return AppExitResponse.exit;
      },
    );
  }

  @override
  void dispose() {
    _exitListener.dispose();
    super.dispose();
  }

  Future<void> _closeProject() async {
    await BiocentralProjectRepository.clearLastProjectDirectory();
    if (!mounted) {
      return;
    }
    setState(() {
      _projectKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BiocentralAPIRepository>.value(value: widget.apiRepository),
        RepositoryProvider<BiocentralPythonCompanion>.value(value: widget.pythonCompanion),
        RepositoryProvider<CloseProjectController>.value(value: CloseProjectController(_closeProject)),
      ],
      child: BiocentralProjectShell(key: _projectKey),
    );
  }
}

/// Everything scoped to a single project directory.
/// Recreated from scratch (fresh [EventBus], [BiocentralProjectRepository],
/// [BiocentralCommandLogRepository], [BiocentralPluginManager] and all plugin state)
/// every time [BiocentralProcessRoot] swaps its key
class BiocentralProjectShell extends StatefulWidget {
  const BiocentralProjectShell({super.key});

  @override
  State<BiocentralProjectShell> createState() => _BiocentralProjectShellState();
}

class _BiocentralProjectShellState extends State<BiocentralProjectShell> {
  final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

  EventBus? _eventBus;
  BiocentralProjectRepository? _projectRepository;
  BiocentralCommandLogRepository? _commandLogRepository;
  BiocentralPluginManager? _pluginManager;

  @override
  void initState() {
    super.initState();
    _initializeProject();
  }

  Future<void> _initializeProject() async {
    final BiocentralPythonCompanion companion = context.read<BiocentralPythonCompanion>();
    final EventBus eventBus = EventBus();
    final BiocentralProjectRepository projectRepository = await BiocentralProjectRepository.fromLastProjectDirectory();
    final BiocentralCommandLogRepository commandLogRepository = BiocentralCommandLogRepository(projectRepository);
    final BiocentralPluginManager pluginManager = BiocentralPluginManager(
      eventBus: eventBus,
      projectRepository: projectRepository,
      companion: companion,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _eventBus = eventBus;
      _projectRepository = projectRepository;
      _commandLogRepository = commandLogRepository;
      _pluginManager = pluginManager;
    });
  }

  /// Creates project-scoped global repositories that are available to all plugins
  List<RepositoryProvider> getGlobalRepositoryProviders(BuildContext context, BiocentralPluginManager pluginManager) {
    final BiocentralColumnWizardRepository biocentralColumnWizardRepository =
        BiocentralColumnWizardRepository.withDefaultWizards();
    final BiocentralDatabaseRepository biocentralDatabaseRepository = BiocentralDatabaseRepository();
    final TutorialRepository tutorialRepository = TutorialRepository(globalNavigatorKey);

    pluginManager.registerGlobalProperties(
      biocentralColumnWizardRepository,
      biocentralDatabaseRepository,
      tutorialRepository,
    );

    return [
      RepositoryProvider<BiocentralProjectRepository>.value(value: _projectRepository!),
      RepositoryProvider<BiocentralCommandLogRepository>.value(value: _commandLogRepository!),
      RepositoryProvider<BiocentralDatabaseRepository>.value(value: biocentralDatabaseRepository),
      // TODO Check if this works with reloading plugins
      RepositoryProvider<BiocentralColumnWizardRepository>.value(value: biocentralColumnWizardRepository),
      RepositoryProvider<TutorialRepository>.value(value: tutorialRepository),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final EventBus? eventBus = _eventBus;
    final BiocentralCommandLogRepository? commandLogRepository = _commandLogRepository;
    final BiocentralPluginManager? pluginManager = _pluginManager;
    final BiocentralProjectRepository? projectRepository = _projectRepository;

    if (eventBus == null || commandLogRepository == null || pluginManager == null || projectRepository == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<BiocentralCommandBloc>(
          create: (context) => BiocentralCommandBloc(eventBus, commandLogRepository),
        ),
        BlocProvider<BiocentralPluginBloc>(
          create: (context) => BiocentralPluginBloc(eventBus, pluginManager),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(InitializeThemeEvent()),
        ),
        BlocProvider<BiocentralSideBarBloc>(
          create: (context) => BiocentralSideBarBloc(),
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
                home: BiocentralAppHome(
                  eventBus: eventBus,
                  isDirectoryPathSet: projectRepository.isProjectDirectoryPathSet(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class BiocentralAppHome extends StatelessWidget {
  final EventBus eventBus;
  final bool isDirectoryPathSet;

  const BiocentralAppHome({required this.eventBus, required this.isDirectoryPathSet, super.key});

  /// Creates global blocs that are available to all plugins
  Map<BlocProvider, Bloc> getGlobalBlocProviders(BuildContext context) {
    return {};
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
    // TODO [Refactoring] Handling the blocs here is dangerous, because rebuilding triggers side effects in event bus
    final Map<BlocProvider, Bloc> globalBlocProviders = getGlobalBlocProviders(context);
    final Map<BlocProvider, Bloc> pluginBlocProviders = pluginState.pluginManager.getPluginBlocs(context);
    final Map<BlocProvider, Bloc> allBlocProviders = {...globalBlocProviders, ...pluginBlocProviders};

    final projectRepository = context.read<BiocentralProjectRepository>();
    if (kIsWeb || !isDirectoryPathSet) {
      return BiocentralStartPageView(
        providers: allBlocProviders.keys.toList(),
        pluginManager: pluginState.pluginManager,
        eventBus: eventBus,
      );
    } else {
      return BlocProvider(
        create: (context) => BiocentralLoadProjectBloc(
          projectRepository,
          context.read<BiocentralCommandLogRepository>(),
          context.read<BiocentralCommandBloc>(),
          projectRepository.getAllPluginDirectories(),
        )..add(
            BiocentralLoadProjectFromDirectoryEvent(
              projectRepository.getProjectDirectoryPath(),
              context,
            ),
          ),
        child: BiocentralLoadProjectView(
          providers: allBlocProviders.keys.toList(),
          pluginManager: pluginState.pluginManager,
          eventBus: eventBus,
        ),
      );
    }
  }
}
