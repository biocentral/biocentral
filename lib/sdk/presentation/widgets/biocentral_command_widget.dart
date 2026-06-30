import 'package:biocentral/biocentral/bloc/biocentral_sidebar_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/displays/biocentral_database_update_display.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiocentralCommandWidget extends StatefulWidget {
  final Icon icon;
  final String name;
  final String description;
  final String executeButtonLabel;
  final Widget Function() parameterSelection; // Lazy building parameter selection
  final BiocentralCommand? Function()
      collectCommand; // Callback to be executed directly after command widget was pressed
  final Widget Function(BiocentralCommandLog) visualizeResult;

  final BiocentralCommandAvailability commandAvailability;

  final bool alwaysAutoAccept;

  const BiocentralCommandWidget({
    required this.icon,
    required this.name,
    required this.description,
    required this.executeButtonLabel,
    required this.parameterSelection,
    required this.collectCommand,
    required this.visualizeResult,
    required this.commandAvailability,
    this.alwaysAutoAccept = false,
    super.key,
  });

  // Default visualization functions
  static Widget visualizeDatabaseResult(BiocentralCommandLog result) {
    final commandResult = result.result?.result;
    if (commandResult == null || commandResult is! BiocentralDatabaseUpdate) {
      // TODO ERROR HANDLING
      return BiocentralStatusIndicator(metaData: result.metaData);
    }
    final databaseUpdate = commandResult;
    return Column(
      children: [
        BiocentralStatusIndicator(metaData: result.metaData),
        BiocentralDatabaseUpdateDisplay(update: databaseUpdate),
      ],
    );
  }

  @override
  State<BiocentralCommandWidget> createState() => _BiocentralCommandWidgetState();
}

class _BiocentralCommandWidgetState extends State<BiocentralCommandWidget> {
  bool _selected = false;
  bool _autoAccept = false;

  void executeCommand() {
    final BiocentralCommandBloc commandBloc = context.read<BiocentralCommandBloc>();
    final BiocentralSideBarBloc sideBarBloc = context.read<BiocentralSideBarBloc>();
    final command = widget.collectCommand();
    if (command != null) {
      sideBarBloc.add(
        BiocentralSideBarChangeVisibilityEvent(displayMode: BiocentralSideBarDisplayMode.commandLog, force: true),
      );
      commandBloc.add(
        BiocentralCommandExecuteEvent(
          command: command,
          visualizeResult: widget.visualizeResult,
          autoAccept: widget.alwaysAutoAccept || _autoAccept,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unselectedWidget = InkWell(
      onTap: widget.commandAvailability.available
          ? () => setState(() {
                _selected = true;
              })
          : null,
      child: Card(
        color: widget.commandAvailability.available ? null : Colors.grey[300],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton.filled(
                onPressed: widget.commandAvailability.available
                    ? () => setState(() {
                          _selected = true;
                        })
                    : null,
                icon: widget.icon,
              ),
              const SizedBox(width: 8),
              Text(
                widget.name,
                style: TextStyle(
                  color: widget.commandAvailability.available ? null : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!_selected) {
      if (!widget.commandAvailability.available) {
        return BiocentralTooltip(
          message: widget.commandAvailability.unavailableMessage ?? 'Command currently not available',
          child: unselectedWidget,
        );
      }
      return BiocentralTooltip(message: widget.description, child: unselectedWidget);
    }

    return ExpansionTile(
      title: Text(widget.name),
      leading: widget.icon,
      initiallyExpanded: true,
      showTrailingIcon: false,
      onExpansionChanged: (v) => setState(() {
        _selected = false;
      }),
      children: [
        Text(widget.description),
        const Divider(),
        const Text('Select Parameters:'),
        widget.parameterSelection(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: widget.alwaysAutoAccept || _autoAccept,
              onChanged: widget.alwaysAutoAccept
                  ? null
                  : (bool? value) {
                      setState(() {
                        _autoAccept = value ?? false;
                      });
                    },
            ),
            const Text('Automatically accept result'),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: executeCommand,
              icon: const Icon(Icons.play_circle_outline),
              label: Text(widget.executeButtonLabel.toUpperCase()),
            ),
          ],
        ),
      ].withPadding(const Padding(padding: EdgeInsets.all(4.0))),
    );
  }
}
