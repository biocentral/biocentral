import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

class BiocentralTaskDisplay extends StatefulWidget {
  final String title;
  final Widget leadingIcon;
  final List<Widget> children;
  final Widget? trailing;

  const BiocentralTaskDisplay({
    required this.title,
    required this.leadingIcon,
    required this.children,
    super.key,
    this.trailing,
  });

  factory BiocentralTaskDisplay.resumable(BiocentralCommandLog commandLog, void Function() onResume) {
    final title = commandLog.commandName;
    final leadingIcon = const Icon(Icons.warning);
    final children = [buildCommandConfigTile(commandLog.commandConfig), buildMetaDataTile(commandLog.metaData)];
    final trailing = IconButton(
      icon: const Icon(Icons.restart_alt_sharp),
      onPressed: () => onResume(),
    );
    return BiocentralTaskDisplay(
      title: title,
      leadingIcon: leadingIcon,
      trailing: trailing,
      children: children,
    );
  }

  // TODO [Refactoring] Copied from BiocentralCommandLogDisplay, should be unified
  static Widget buildCommandConfigTile(Map<String, dynamic> commandConfig) {
    return ExpansionTile(
      title: const Text('Command Config'),
      children: [
        Table(
          children: commandConfig.entries
              .map((entry) => TableRow(children: [Text(entry.key.toString()), Text(entry.value.toString())]))
              .toList(),
        ),
      ],
    );
  }

  static Widget buildMetaDataTile(BiocentralCommandMetaData metaData) {
    return ExpansionTile(
      title: const Text('Meta Data'),
      children: [
        Table(
          children: metaData
              .toMap()
              .entries
              .map((entry) => TableRow(children: [Text(entry.key.toString()), Text(entry.value.toString())]))
              .toList(),
        ),
      ],
    );
  }

  @override
  State<BiocentralTaskDisplay> createState() => _BiocentralTaskDisplayState();
}

class _BiocentralTaskDisplayState extends State<BiocentralTaskDisplay> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig.screenWidth(context) * 0.95,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Theme(
            data: Theme.of(context).copyWith(
              listTileTheme: ListTileTheme.of(context).copyWith(
                dense: true,
              ),
            ),
            child: ExpansionTile(
              leading: widget.leadingIcon,
              title: Text(widget.title),
              trailing: SizedBox(
                width: SizeConfig.screenWidth(context) * 0.35,
                height: 44.0,
                child: widget.trailing,
              ),
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}
