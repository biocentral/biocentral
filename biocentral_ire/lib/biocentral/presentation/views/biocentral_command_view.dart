import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/biocentral/bloc/biocentral_plugins_bloc.dart';
import 'package:biocentral/biocentral/bloc/wiki_bloc.dart';
import 'package:biocentral/biocentral/presentation/dialogs/close_project_dialog.dart';
import 'package:biocentral/biocentral/presentation/dialogs/info_dialog.dart';
import 'package:biocentral/biocentral/presentation/dialogs/plugin_dialog.dart';
import 'package:biocentral/biocentral/presentation/dialogs/welcome_dialog.dart';
import 'package:biocentral/biocentral/presentation/dialogs/wiki_dialog.dart';
import 'package:biocentral/biocentral/presentation/dialogs/server_config_dialog.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class BiocentralInternalCommandView extends StatefulWidget {
  const BiocentralInternalCommandView({super.key});

  @override
  State<BiocentralInternalCommandView> createState() => _BiocentralInternalCommandViewState();
}

class _BiocentralInternalCommandViewState extends State<BiocentralInternalCommandView> {
  @override
  void initState() {
    super.initState();
  }

  void openWikiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (_) => WikiBloc()..add(WikiLoadEvent()),
          child: const WikiDialog(),
        );
      },
    );
  }

  void openPluginDialog() {
    final BiocentralPluginBloc biocentralPluginBloc = BlocProvider.of<BiocentralPluginBloc>(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: biocentralPluginBloc,
          child: const PluginDialog(),
        );
      },
    );
  }

  void openInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const InfoDialog();
      },
    );
  }

  void openWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const WelcomeDialog();
      },
    );
  }

  void openServerConfigurationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ServerConfigDialog();
      },
    );
  }

  void openCloseProjectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CloseProjectDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandBar(
      commands: [
        BiocentralTooltip(
          message: 'Read documentation and complete tutorials',
          child: BiocentralButton(
            iconData: Icons.lightbulb,
            onTap: openWikiDialog,
          ),
        ),
        BiocentralTooltip(
          message: 'Select the plugins you want to work with',
          child: BiocentralButton(
            iconData: Icons.plumbing,
            onTap: openPluginDialog,
          ),
        ),
        BiocentralTooltip(
          message: 'Show app information',
          child: BiocentralButton(
            iconData: Icons.info_outline,
            onTap: openInfoDialog,
          ),
        ),
        BiocentralTooltip(
          message: 'Show welcome dialog',
          child: BiocentralButton(
            iconData: Icons.help_center,
            onTap: openWelcomeDialog,
          ),
        ),
        BiocentralTooltip(
          message: 'Add server',
          child: BiocentralButton(
            iconData: Icons.dns,
            onTap: openServerConfigurationDialog,
          ),
        ),
        BlocBuilder<BiocentralCommandBloc, BiocentralCommandState>(
          builder: (context, commandState) {
            final bool busy = commandState.isBusy();
            return BiocentralTooltip(
              message: busy ? 'Cannot close the project while a command is running' : 'Close the current project',
              child: BiocentralButton(
                iconData: Icons.logout,
                onTap: busy ? null : openCloseProjectDialog,
              ),
            );
          },
        ),
      ],
    );
  }
}
