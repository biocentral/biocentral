import 'package:biocentral/biocentral/bloc/biocentral_load_project_bloc.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_load_project_view.dart';
import 'package:biocentral/biocentral/presentation/views/biocentral_main_view.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_command_log_repository.dart';
import 'package:event_bus/event_bus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

class BiocentralStartPageView extends StatefulWidget {
  final List<SingleChildWidget> providers;
  final BiocentralPluginManager pluginManager;
  final EventBus eventBus;

  const BiocentralStartPageView({
    required this.providers,
    required this.pluginManager,
    required this.eventBus,
    super.key,
  });

  @override
  State<BiocentralStartPageView> createState() => _BiocentralStartPageViewState();
}

class _BiocentralStartPageViewState extends State<BiocentralStartPageView> {
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

  void switchToProjectView(String? dirPath) async {
    if (dirPath != null) {
      final BiocentralProjectRepository biocentralProjectRepository = context.read<BiocentralProjectRepository>();
      await biocentralProjectRepository.setProjectDirectoryPath(dirPath);
    }

    if (!mounted) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MultiBlocProvider(providers: widget.providers, child: BiocentralMainView(eventBus: widget.eventBus)),
      ),
    );
  }

  void loadExistingProject() async {
    if (kIsWeb) {
      return;
    }
    final String? dirPath = await FilePicker.platform.getDirectoryPath();
    if (dirPath == null) {
      // User canceled the picker
      return;
    }

    final BiocentralProjectRepository biocentralProjectRepository = context.read<BiocentralProjectRepository>();
    await biocentralProjectRepository.setProjectDirectoryPath(dirPath);

    if (!mounted) {
      return;
    }
    switchToLoadProjectView(dirPath);
  }

  void switchToLoadProjectView(String dirPath) {
    final BiocentralProjectRepository biocentralProjectRepository = context.read<BiocentralProjectRepository>();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => BiocentralLoadProjectBloc(
            biocentralProjectRepository,
            context.read<BiocentralCommandLogRepository>(),
            context.read<BiocentralCommandBloc>(),
            biocentralProjectRepository.getAllPluginDirectories(),
          )..add(BiocentralLoadProjectFromDirectoryEvent(dirPath, context)),
          child: BiocentralLoadProjectView(
            providers: widget.providers,
            pluginManager: widget.pluginManager,
            eventBus: widget.eventBus,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Biocentral - Project Wizard',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 10,
              ),
              ...buildProjectSelection(),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> buildProjectSelection() {
    return [
      ElevatedButton(onPressed: startNewProject, child: const Text('Start new project..')),
      const SizedBox(height: 5),
      ElevatedButton(onPressed: loadExistingProject, child: const Text('Load project..')),
    ];
  }

// WIDGET FUNCTIONS GO HERE
}
