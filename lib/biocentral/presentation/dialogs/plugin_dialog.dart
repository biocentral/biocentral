import 'package:biocentral/biocentral/bloc/biocentral_plugins_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PluginDialog extends StatefulWidget {
  const PluginDialog({super.key});

  @override
  State<PluginDialog> createState() => _PluginDialogState();
}

class _PluginDialogState extends State<PluginDialog> {
  final Set<BiocentralPlugin> _selectedPlugins = {};

  final Map<Type, String> _pluginTypeNames = {};

  @override
  void initState() {
    super.initState();
    final BiocentralPluginBloc biocentralPluginBloc = BlocProvider.of<BiocentralPluginBloc>(context);
    _selectedPlugins.addAll(biocentralPluginBloc.state.pluginManager.activePlugins);
    _pluginTypeNames.addEntries(biocentralPluginBloc.state.pluginManager.allAvailablePlugins
        .map((plugin) => MapEntry(plugin.runtimeType, plugin.typeName)),);
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  Set<BiocentralPlugin> getPluginsNecessaryForSelection(BiocentralPlugin selected, Set<BiocentralPlugin> allPlugins) {
    final Set<BiocentralPlugin> result = {};
    final Set<Type> pluginDependencies = selected.getDependencies();
    for (Type dependencyType in pluginDependencies) {
      for (BiocentralPlugin plugin in allPlugins) {
        if (plugin.runtimeType == dependencyType) {
          result.add(plugin);
        }
      }
    }
    return result;
  }

  Set<BiocentralPlugin> getPluginsDependentOnSelection(BiocentralPlugin selected, Set<BiocentralPlugin> allPlugins) {
    final Set<BiocentralPlugin> result = {};
    for (BiocentralPlugin plugin in allPlugins) {
      final Set<Type> pluginDependencies = plugin.getDependencies();
      for (Type dependencyType in pluginDependencies) {
        if (selected.runtimeType == dependencyType) {
          result.add(plugin);
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final BiocentralPluginBloc biocentralPluginBloc = BlocProvider.of<BiocentralPluginBloc>(context);
    return BlocBuilder<BiocentralPluginBloc, BiocentralPluginState>(
      builder: (context, state) {
        if (state.status == BiocentralPluginStatus.loading) {
          return const AbsorbPointer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Saving and applying plugin changes..'),
                CircularProgressIndicator(),
              ],
            ),
          );
        }
        return BiocentralDialog(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Biocentral Plugins',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                buildPluginSelection(biocentralPluginBloc, state),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BiocentralSmallButton(
                        onTap: () => biocentralPluginBloc.add(BiocentralPluginReloadEvent(_selectedPlugins, context)),
                        label: 'Apply changes',),
                    BiocentralSmallButton(onTap: closeDialog, label: 'Close'),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildPluginSelection(BiocentralPluginBloc biocentralPluginBloc, BiocentralPluginState state) {
    return Column(
      children: [
        ...state.pluginManager.allAvailablePlugins.map((plugin) => CheckboxListTile(
            title: Text(plugin.typeName),
            subtitle:
                Text('${plugin.getShortDescription()}\nDependencies: ${_formatDependencies(plugin.getDependencies())}'),
            isThreeLine: true,
            controlAffinity: ListTileControlAffinity.leading,
            secondary: plugin.getIcon(),
            value: _selectedPlugins.contains(plugin),
            onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  if (value) {
                    final Set<BiocentralPlugin> necessaryPlugins =
                        getPluginsNecessaryForSelection(plugin, state.pluginManager.allAvailablePlugins);
                    _selectedPlugins.addAll(necessaryPlugins);
                    _selectedPlugins.add(plugin);
                  } else {
                    final Set<BiocentralPlugin> dependentPlugins =
                        getPluginsDependentOnSelection(plugin, state.pluginManager.allAvailablePlugins);
                    _selectedPlugins.removeAll(dependentPlugins);
                    _selectedPlugins.remove(plugin);
                  }
                });
              }
            },),),
      ],
    );
  }

  String _formatDependencies(Set<Type> dependencies) {
    if (dependencies.isEmpty) {
      return 'None';
    }
    return dependencies
        .map((dependency) => _pluginTypeNames[dependency])
        .toString()
        .replaceAll('(', '')
        .replaceAll(')', '');
  }

  @override
  void dispose() {
    super.dispose();
  }
}
