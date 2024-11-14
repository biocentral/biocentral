import 'package:biocentral/biocentral/bloc/biocentral_plugins_bloc.dart';
import 'package:biocentral/biocentral/bloc/wiki_bloc.dart';
import 'package:biocentral/biocentral/presentation/dialogs/server_connection_dialog.dart';
import 'package:biocentral/biocentral/presentation/dialogs/wiki_dialog.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/biocentral/presentation/dialogs/info_dialog.dart';
import 'package:biocentral/biocentral/presentation/dialogs/plugin_dialog.dart';
import 'package:biocentral/biocentral/presentation/dialogs/welcome_dialog.dart';

class BiocentralCommandView extends StatefulWidget {
  const BiocentralCommandView({super.key});

  @override
  State<BiocentralCommandView> createState() => _BiocentralCommandViewState();
}

class _BiocentralCommandViewState extends State<BiocentralCommandView> {
  @override
  void initState() {
    super.initState();
  }

  void openServerConnectionDialog() {
    final BiocentralClientBloc biocentralClientBloc = BlocProvider.of<BiocentralClientBloc>(context);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider.value(
            value: biocentralClientBloc,
            child: const ServerConnectionDialog(),
          );
        },);
  }

  void openWikiDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(create: (_) => WikiBloc()..add(WikiLoadEvent()), child: const WikiDialog());
        },);
  }

  void openPluginDialog() {
    final BiocentralPluginBloc biocentralPluginBloc = BlocProvider.of<BiocentralPluginBloc>(context);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider.value(value: biocentralPluginBloc, child: const PluginDialog());
        },);
  }

  void openInfoDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const InfoDialog();
        },);
  }

  void openWelcomeDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const WelcomeDialog();
        },);
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandBar(
      commands: [
        BiocentralTooltip(
          message: 'Connect to a server app for high-performance calculations',
          child: BiocentralButton(
              label: 'Connect to server..', iconData: Icons.cast_connected, onTap: openServerConnectionDialog,),
        ),
        BiocentralTooltip(message: 'Read documentation and complete tutorials', child: BiocentralButton(label: 'Show wiki..', iconData: Icons.lightbulb, onTap: openWikiDialog)),
        BiocentralTooltip(message: 'Select the plugins you want to work with', child: BiocentralButton(label: 'Show plugins..', iconData: Icons.plumbing, onTap: openPluginDialog)),
        BiocentralTooltip(message: 'Show app information', child: BiocentralButton(label: 'Show app info..', iconData: Icons.info_outline, onTap: openInfoDialog)),
        BiocentralTooltip(message: 'Show welcome dialog', child: BiocentralButton(label: 'Show welcome dialog..', iconData: Icons.help_center, onTap: openWelcomeDialog)),
      ],
    );
  }
}
