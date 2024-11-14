import 'package:biocentral/biocentral/presentation/views/biocentral_main_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

class StartPageView extends StatefulWidget {
  final List<SingleChildWidget> providers;
  final BiocentralPluginManager pluginManager;
  final EventBus eventBus;

  const StartPageView({required this.providers, required this.pluginManager, required this.eventBus, super.key});

  @override
  State<StartPageView> createState() => _StartPageViewState();
}

class _StartPageViewState extends State<StartPageView> {
  @override
  void initState() {
    super.initState();
  }

  void startNewProject() async {
    if (!kIsWeb) {
      final String? dirPath = await FilePicker.platform.getDirectoryPath();
      if (dirPath != null) {
        switchToProjectView(dirPath);
      } else {
        // User canceled the picker
      }
    } else {
      switchToProjectView(null); // Web does not need to set a project directory
    }
  }

  Future<void> saveLastProjectRepository() async {}

  void switchToProjectView(String? dirPath) {
    if (dirPath != null) {
      final BiocentralProjectRepository biocentralProjectRepository = context.read<BiocentralProjectRepository>();
      biocentralProjectRepository.setDirectoryPath(dirPath);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              MultiBlocProvider(providers: widget.providers, child: BiocentralMainView(eventBus: widget.eventBus)),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Biocentral - Project Wizard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 10,
            ),
            ...buildProjectSelection(),
          ],),
        ],
      ),
    );
  }

  List<Widget> buildProjectSelection() {
    return [
      ElevatedButton(onPressed: startNewProject, child: const Text('Start new project..')),
      const SizedBox(height: 5),
      ElevatedButton(onPressed: startNewProject, child: const Text('Load project..')),
    ];
  }

// WIDGET FUNCTIONS GO HERE
}
