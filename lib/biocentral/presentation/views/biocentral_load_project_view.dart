import 'package:biocentral/biocentral/bloc/biocentral_load_project_bloc.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_main_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

class BiocentralLoadProjectView extends StatefulWidget {
  final List<SingleChildWidget> providers;
  final BiocentralPluginManager pluginManager;
  final EventBus eventBus;

  const BiocentralLoadProjectView(
      {required this.providers, required this.pluginManager, required this.eventBus, super.key});

  @override
  State<BiocentralLoadProjectView> createState() => _BiocentralLoadProjectViewState();
}

class _BiocentralLoadProjectViewState extends State<BiocentralLoadProjectView> {
  @override
  void initState() {
    super.initState();
  }

  void switchToProjectView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MultiBlocProvider(providers: widget.providers, child: BiocentralMainView(eventBus: widget.eventBus)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<BiocentralLoadProjectBloc, BiocentralLoadProjectState>(
        listener: (context, state) {
          if (state.isFinished()) {
            switchToProjectView();
          }
        },
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading project..',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: SizeConfig.screenWidth(context) * 0.2,
                      height: SizeConfig.screenHeight(context) * 0.2,
                      child: BiocentralStatusIndicator(state: state, center: true,)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
