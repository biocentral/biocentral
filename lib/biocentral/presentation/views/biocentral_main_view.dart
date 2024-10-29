import 'dart:ui';

import 'package:biocentral/biocentral/bloc/biocentral_command_log_bloc.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_tab_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../bloc/biocentral_plugins_bloc.dart';
import '../dialogs/welcome_dialog.dart';

class BiocentralMainView extends StatefulWidget {
  final EventBus eventBus;

  const BiocentralMainView({super.key, required this.eventBus});

  @override
  State<BiocentralMainView> createState() => _BiocentralMainViewState();
}

class _BiocentralMainViewState extends State<BiocentralMainView> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final BiocentralCommandLogBloc biocentralCommandLogBloc;

  late final AppLifecycleListener _exitListener;

  late TabController _tabController;

  final Widget _biocentralTab = const Tab(text: "Biocentral", icon: Icon(Icons.center_focus_weak_outlined));

  final List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();
    // BLOCS
    createBlocs();

    // HANDLE APP EXIT
    _exitListener = AppLifecycleListener(onExitRequested: () async {
      await killServer();
      return AppExitResponse.exit;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      openWelcomeDialog();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _exitListener.dispose();
    super.dispose();
  }

  Future<void> killServer() async {
    final localServerInstance = BiocentralLocalServer();
    if (localServerInstance.isRunning()) {
      await BiocentralLocalServer().stop();
    }
  }

  void createBlocs() {
    BiocentralProjectRepository biocentralProjectRepository = context.read<BiocentralProjectRepository>();

    biocentralCommandLogBloc = BiocentralCommandLogBloc(biocentralProjectRepository)
      ..add(BiocentralCommandLogLoadEvent());
    widget.eventBus.on<BiocentralCommandExecutedEvent>().listen((event) {
      biocentralCommandLogBloc.add(BiocentralCommandLogLoadEvent());
    });
  }

  void addTabListeners() {
    _tabController.addListener(() {
      // Without checking for index changing, the event is fired twice
      if (!_tabController.indexIsChanging) {
        widget.eventBus.fire(BiocentralPluginTabSwitchedEvent(_tabs[_tabController.index]));
      }
    });
  }

  void openWelcomeDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const WelcomeDialog();
        });
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiocentralPluginBloc, BiocentralPluginState>(builder: (context, pluginState) {
      // TABS
      _tabs.clear();
      _tabs.addAll(pluginState.pluginManager.activePlugins.map((plugin) => plugin.getTab()));
      _tabs.add(_biocentralTab);
      _tabController = TabController(initialIndex: 0, length: _tabs.length, vsync: this);
      addTabListeners();
      return Scaffold(key: _scaffoldKey, body: buildTabBar(pluginState));
    });
  }

  Widget buildTabBar(BiocentralPluginState pluginState) {
    List<Widget> tabBarViews = [];

    tabBarViews.addAll(pluginState.pluginManager.activePlugins.map((plugin) => plugin.build(context)));

    tabBarViews.add(MultiBlocProvider(
        providers: [BlocProvider.value(value: biocentralCommandLogBloc)], child: const BiocentralTabView()));

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(SizeConfig.screenHeight(context) * 0.125),
          child: AppBar(
            title: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                  if(snapshot.hasData && snapshot.data != null) {
                    return Align(
                        alignment: Alignment.centerRight,
                        child: Text("Biocentral - develop - Alpha v${snapshot.data?.version}", style: Theme
                            .of(context)
                            .textTheme
                            .labelSmall));
                  }
                  return const CircularProgressIndicator();
              }
            ),
            backgroundColor: Colors.transparent,
            bottom: BiocentralCommandTabBar(
              controller: _tabController,
              tabs: _tabs,
            ),
          ),
        ),
        body: Column(
          children: [
            Flexible(flex: 20, child: TabBarView(controller: _tabController, children: tabBarViews)),
            SizedBox(width: SizeConfig.safeBlockVertical(context) * 2),
            Flexible(flex: 2, child: buildStatusBar())
          ],
        ),
      ),
    );
  }

  Widget buildStatusBar() {
    return BiocentralStatusBar(eventBus: widget.eventBus);
  }
}
