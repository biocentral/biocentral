import 'package:biocentral/biocentral/bloc/biocentral_plugins_bloc.dart';
import 'package:biocentral/biocentral/bloc/wiki_bloc.dart';
import 'package:biocentral/biocentral/presentation/dialogs/server_connection_dialog.dart';
import 'package:biocentral/biocentral/presentation/dialogs/wiki_dialog.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dialogs/info_dialog.dart';
import '../dialogs/plugin_dialog.dart';

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
    BiocentralClientBloc biocentralClientBloc = BlocProvider.of<BiocentralClientBloc>(context);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider.value(
            value: biocentralClientBloc,
            child: const ServerConnectionDialog(),
          );
        });
  }

  void openWikiDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(create: (_) => WikiBloc()..add(WikiLoadEvent()), child: const WikiDialog());
        });
  }

  void openPluginDialog() {
    BiocentralPluginBloc biocentralPluginBloc = BlocProvider.of<BiocentralPluginBloc>(context);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider.value(value: biocentralPluginBloc, child: const PluginDialog());
        });
  }

  void openInfoDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const InfoDialog();
        });
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandBar(
      commands: [
        BiocentralButton(
            label: "Connect to server..", iconData: Icons.cast_connected, onTap: openServerConnectionDialog),
        BiocentralButton(label: "Show wiki..", iconData: Icons.lightbulb, onTap: openWikiDialog),
        BiocentralButton(label: "Show plugins..", iconData: Icons.plumbing, onTap: openPluginDialog),
        BiocentralButton(label: "Show info..", iconData: Icons.info_outline, onTap: openInfoDialog)
      ],
    );
  }
}
