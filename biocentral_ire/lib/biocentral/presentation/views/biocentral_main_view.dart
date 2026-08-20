import 'dart:async';
import 'dart:ui';

import 'package:biocentral/biocentral/bloc/biocentral_command_log_bloc.dart';
import 'package:biocentral/biocentral/bloc/biocentral_plugins_bloc.dart';
import 'package:biocentral/biocentral/bloc/biocentral_sidebar_bloc.dart';
import 'package:biocentral/biocentral/presentation/dialogs/welcome_dialog.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_side_bar.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_tab_view.dart';
import 'package:biocentral/biocentral/presentation/widgets/biocentral_api_connectivity_widget.dart';
import 'package:biocentral/biocentral/presentation/widgets/biocentral_explainable_widget.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/theme/theme_bloc.dart';
import 'package:biocentral/sdk/bloc/theme/theme_event.dart';
import 'package:biocentral/sdk/bloc/theme/theme_state.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:biocentral/sdk/domain/biocentral_command_log_repository.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class BiocentralMainView extends StatefulWidget {
  final EventBus eventBus;

  const BiocentralMainView({required this.eventBus, super.key});

  @override
  State<BiocentralMainView> createState() => _BiocentralMainViewState();
}

class _BiocentralMainViewState extends State<BiocentralMainView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Widget _biocentralTab = const Tab(
    text: 'Biocentral',
    icon: Icon(Icons.center_focus_weak_outlined),
  );

  final List<Widget> _tabs = [];

  late final BiocentralCommandLogBloc biocentralCommandLogBloc; // TODO Move to main?

  late final AppLifecycleListener _exitListener;

  StreamSubscription<String>? _serverFallbackSubscription; // for notification

  late TabController _tabController;

  BiocentralPluginState? cachedPluginState;

  @override
  void initState() {
    super.initState();

    // Initialize TabController here with a default length
    _tabController = TabController(length: 1, vsync: this);
    // BLOCS
    createBlocs();

    // HANDLE APP EXIT
    _exitListener = AppLifecycleListener(
      onExitRequested: () async {
        await terminatePythonCompanion();
        return AppExitResponse.exit;
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      openWelcomeDialog();
    });

    // Sidebar Key Handler
    ServicesBinding.instance.keyboard.addHandler(_handleSideBarKeyEvent);

    // Notify on server fallback
    _serverFallbackSubscription = context.read<BiocentralAPIRepository>().serverFallbackMessages.listen((message) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pluginState = context.read<BiocentralPluginBloc>().state;
    if (_checkForUpdatedPlugins(cachedPluginState, pluginState)) {
      updateTabs();
    }
  }

  bool _checkForUpdatedPlugins(BiocentralPluginState? oldState, BiocentralPluginState newState) {
    if (oldState == null) {
      return true;
    }

    if (oldState.pluginManager.activePlugins.length != newState.pluginManager.activePlugins.length) {
      return true;
    }
    return !newState.pluginManager.activePlugins
        .every((plugin) => oldState.pluginManager.activePlugins.contains(plugin));
  }

  @override
  void dispose() {
    _exitListener.dispose();
    _tabController.dispose();
    ServicesBinding.instance.keyboard.removeHandler(_handleSideBarKeyEvent);
    _serverFallbackSubscription?.cancel();
    super.dispose();
  }

  Future<void> terminatePythonCompanion() async {
    final pythonCompanion = context.read<BiocentralPythonCompanion>();
    final terminated = await pythonCompanion.terminate();
  }

  void createBlocs() {
    final BiocentralProjectRepository biocentralProjectRepository = context.read<BiocentralProjectRepository>();

    biocentralCommandLogBloc = BiocentralCommandLogBloc(context.read<BiocentralCommandLogRepository>());
    // TODO ENSURE LOADED?

    // TODO REFACTOR SYNC
    //widget.eventBus.on<BiocentralCommandStateChangedEvent>().listen((event) {
    //  biocentralCommandLogBloc.add(BiocentralCommandLogLoadEvent());
    //});
  }

  void addTabListeners() {
    _tabController.addListener(() {
      // Without checking for index changing, the event is fired twice
      if (!_tabController.indexIsChanging) {
        widget.eventBus.fire(BiocentralPluginTabSwitchedEvent(_tabs[_tabController.index]));
      }
    });
  }

  void updateTabs() {
    final pluginState = context.read<BiocentralPluginBloc>().state;
    cachedPluginState = pluginState;
    _tabs.clear();
    _tabs.addAll(
      pluginState.pluginManager.activePlugins.map((plugin) => plugin.getTab()),
    );
    _tabs.add(_biocentralTab);

    // Instead of creating new controller, update the existing one
    if (_tabController.length != _tabs.length) {
      _tabController.dispose(); // Dispose old controller
      _tabController = TabController(length: _tabs.length, vsync: this);
      addTabListeners();
    }
    // Force a rebuild when tabs change
    setState(() {});
  }

  void openWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const WelcomeDialog();
      },
    );
  }

  bool _handleSideBarKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyT) {
      // Check if a BiocentralExplainableWidget has focus
      final focusedContext = FocusManager.instance.primaryFocus?.context;
      if (focusedContext != null && _hasExplainableAncestor(focusedContext)) {
        // Let the widget handle it
        return false;
      }

      // No explainable widget focused, handle globally
      _toggleSideBar(BiocentralSideBarDisplayMode.help);
      return false;
    }
    return false;
  }

  void _toggleSideBar(BiocentralSideBarDisplayMode displayMode) {
    final sideBarBloc = BlocProvider.of<BiocentralSideBarBloc>(context);
    sideBarBloc.add(BiocentralSideBarChangeVisibilityEvent(displayMode: displayMode));
  }

  bool _hasExplainableAncestor(BuildContext context) {
    bool found = false;
    context.visitAncestorElements((element) {
      if (element.widget is BiocentralExplainableWidget) {
        found = true;
        return false; // Stop visiting
      }
      return true; // Continue visiting
    });
    return found;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: biocentralCommandLogBloc)],
      child: BlocBuilder<BiocentralPluginBloc, BiocentralPluginState>(
        builder: (context, pluginState) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final useDrawer = constraints.maxWidth < 775;
              return Scaffold(
                key: _scaffoldKey,
                appBar: _buildAppBar(useDrawer, context),
                drawer: useDrawer ? _buildDrawer(context) : null,
                body: Row(
                  children: [
                    Expanded(child: _buildBody(pluginState, context)),
                    const BiocentralSideBar(),
                    BlocBuilder<BiocentralSideBarBloc, BiocentralSideBarState>(
                      builder: (context, sideBarState) {
                        return NavigationRail(
                          destinations: [
                            NavigationRailDestination(
                              icon: BiocentralTooltip(
                                message: 'Help',
                                child: IconButton(
                                  icon: const Icon(Icons.help),
                                  onPressed: () => _toggleSideBar(BiocentralSideBarDisplayMode.help),
                                ),
                              ),
                              label: const Text('Help'),
                            ),
                            NavigationRailDestination(
                              icon: BiocentralTooltip(
                                message: 'Show command log',
                                child: IconButton(
                                  icon: const Icon(Icons.insert_drive_file_sharp),
                                  onPressed: () => _toggleSideBar(BiocentralSideBarDisplayMode.commandLog),
                                ),
                              ),
                              label: const Text('Command Log'),
                            ),
                          ],
                          selectedIndex: sideBarState.selectionIndex(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  PreferredSize _buildAppBar(bool useDrawer, BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(
        useDrawer ? SizeConfig.screenHeight(context) * 0.05 : SizeConfig.screenHeight(context) * 0.15,
      ),
      child: AppBar(
        leading: useDrawer
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              )
            : null,
        title: _buildAppBarTitle(),
        backgroundColor: Colors.transparent,
        bottom: useDrawer
            ? null
            : BiocentralCommandTabBar(
                controller: _tabController,
                tabs: _tabs,
              ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        // App Name and Version
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Biocentral IRE - v${snapshot.data?.version}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ),
        const Spacer(),
        const BiocentralAPIConnectivityWidget(),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildAppBarTitle(),
                ..._buildDrawerItems(context),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              trailing: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return Switch(
                    value: state.isDarkMode,
                    activeThumbColor: Theme.of(context).secondaryHeaderColor,
                    onChanged: (value) {
                      context.read<ThemeBloc>().add(ToggleThemeEvent(value));
                    },
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Icon(
                            Icons.dark_mode,
                            size: 16,
                            color: Theme.of(context).colorScheme.tertiary,
                          );
                        }
                        return Icon(
                          Icons.light_mode,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    return List.generate(
      _tabs.length,
      (i) => ListTile(
        title: _tabs[i],
        selected: i == _tabController.index,
        onTap: () {
          setState(() => _tabController.animateTo(i));
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBody(BiocentralPluginState pluginState, BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 50,
          child: buildTabBarView(pluginState),
        ),
        Expanded(flex: 4, child: buildStatusBar()),
      ],
    );
  }

  Widget buildTabBarView(BiocentralPluginState pluginState) {
    final tabBarView = TabBarView(
      controller: _tabController,
      children: buildTabBarViews(pluginState),
    );
    return tabBarView;
  }

  List<Widget> buildTabBarViews(BiocentralPluginState pluginState) {
    final List<Widget> tabBarViews = [];
    tabBarViews.addAll(
      pluginState.pluginManager.activePlugins.map((plugin) => plugin.getScreenView(context)),
    );
    tabBarViews.add(
      const BiocentralTabView(),
    );

    return tabBarViews;
  }

  Widget buildStatusBar() {
    return const BiocentralStatusBar();
  }

  @override
  bool get wantKeepAlive => true;
}
