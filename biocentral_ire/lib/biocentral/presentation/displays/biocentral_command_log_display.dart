import 'package:biocentral/biocentral/bloc/biocentral_command_log_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiocentralCommandLogView extends StatefulWidget {
  const BiocentralCommandLogView({super.key});

  @override
  State<BiocentralCommandLogView> createState() => _BiocentralCommandLogViewState();
}

class _BiocentralCommandLogViewState extends State<BiocentralCommandLogView> {
  final logScrollController = ScrollController();

  bool _hasOperatingLog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logScrollController.jumpTo(logScrollController.position.maxScrollExtent);
    });
  }

  void onNewLogAdded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (logScrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 75), () {
          if (logScrollController.hasClients) {
            logScrollController.animateTo(
              logScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiocentralCommandBloc, BiocentralCommandState>(
      builder: (context, commandState) {
        final newOperatingLog = commandState.currentCommandLog != null;
        if (!_hasOperatingLog && newOperatingLog) {
          onNewLogAdded();
        }
        _hasOperatingLog = newOperatingLog;
        return BlocBuilder<BiocentralCommandLogBloc, BiocentralCommandLogState>(
          builder: (context, logState) {
            final length = logState.commandLogs.length + (_hasOperatingLog ? 1 : 0);
            return BiocentralLogContainer(
              title: 'Executed Commands',
              logsWidget: Flexible(
                child: SingleChildScrollView(
                  controller: logScrollController,
                  child: Column(
                    children: List.generate(length, (index) {
                      final buildArrow = index < length - 1;
                      if (index < logState.commandLogs.length) {
                        final BiocentralCommandLog log = logState.commandLogs[index];
                        return Column(
                          children: [
                            buildCommandLogDisplay(log),
                            if (buildArrow) const Icon(Icons.arrow_downward_rounded, color: Colors.white),
                          ],
                        );
                      } else {
                        return buildOperatingCommandLogDisplay(context.read<BiocentralCommandBloc>(), commandState);
                      }
                    }),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildCommandLogDisplay(BiocentralCommandLog log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Card(
        child: ExpansionTile(
          leading: getIconByCommandType(log),
          title: Text(log.commandName, style: Theme.of(context).textTheme.displaySmall),
          children: [
            buildCommandConfigTile(log.commandConfig),
            buildMetaDataTile(log.metaData),
            buildResultTile(log.result),
          ],
        ),
      ),
    );
  }

  Widget buildOperatingCommandLogDisplay(BiocentralCommandBloc commandBloc, BiocentralCommandState commandState) {
    if (commandState.currentCommandLog == null) {
      return Container();
    }
    if (commandState.visualizeResult == null) {
      print('Warning: Missing visualize function!');
      return Container();
    }
    final log = commandState.currentCommandLog!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: FadeScaleOnce(
        key: ValueKey(log.toString().hashCode), // Unique key ensures animation plays for each new log
        child: Card(
          child: ExpansionTile(
            leading: buildOperatingIcon(log),
            initiallyExpanded: true,
            title: Text(log.commandName, style: Theme.of(context).textTheme.displaySmall),
            children: [
              buildCommandConfigTile(log.commandConfig),
              buildMetaDataTile(log.metaData),
              buildResultVisualization(commandState),
              buildResultDecision(commandBloc, log),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOperatingIcon(BiocentralCommandLog log) {
    if (log.commandStatus == BiocentralCommandStatus.operating) {
      return const CircularProgressIndicator();
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          const CircularProgressIndicator(value: 1.0),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
      );
    }
  }

  Widget getIconByCommandType(BiocentralCommandLog log) {
    if (log.commandStatus == BiocentralCommandStatus.operating) {
      return const CircularProgressIndicator();
    }
    final commandName = log.commandName.toLowerCase();
    if (commandName.contains('load') || commandName.contains('file')) {
      return const Icon(Icons.file_open);
    }
    if (commandName.contains('train')) {
      return const Icon(Icons.model_training);
    }
    if (commandName.contains('calculate')) {
      return const Icon(Icons.calculate_outlined);
    }
    if (commandName.contains('retrieve')) {
      return const Icon(Icons.nature_people_rounded);
    }
    if (commandName.contains('remove')) {
      return const Icon(Icons.remove_circle);
    }
    return const Icon(Icons.add);
  }

  Widget buildCommandConfigTile(Map<String, dynamic> commandConfig) {
    return ExpansionTile(
      title: Text('Command Config', style: Theme.of(context).textTheme.displaySmall),
      children: [
        Table(
          children: commandConfig.entries
              .map((entry) => TableRow(children: [Text(entry.key.toString()), Text(entry.value.toString())]))
              .toList(),
        ),
      ],
    );
  }

  Widget buildMetaDataTile(BiocentralCommandMetaData metaData) {
    final List<Widget> progressItems = [];

    // Build progress steps dynamically from progressLog
    if (metaData.progressLog.isNotEmpty) {
      for (final progressEntry in metaData.progressLog) {
        final percentage = (progressEntry.progress() ?? 0.0) * 100;
        final message = progressEntry.information;

        IconData? icon;
        Color? iconColor;

        // Determine icon based on percentage
        final percentageValue = percentage.toInt();
        if (percentageValue == 0) {
          icon = Icons.play_arrow;
          iconColor = Colors.green;
        } else if (percentageValue == 100) {
          icon = Icons.check_circle;
          iconColor = Colors.green;
        }

        progressItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 8),
                ] else
                  const SizedBox(width: 24),
                SizedBox(
                  width: 60,
                  child: Text('$percentageValue%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text(message),
              ],
            ),
          ),
        );
      }
    }

    final additionalMetadataEntries = <MapEntry<String, String>>[];
    additionalMetadataEntries.add(MapEntry('start_time', metaData.startTime.toString()));

    if (metaData.endTime != null) {
      additionalMetadataEntries.add(MapEntry('end_time', metaData.endTime.toString()));
    }
    final timeToExecute = metaData.timeToExecute();
    if (timeToExecute != null) {
      additionalMetadataEntries.add(MapEntry('duration', timeToExecute.dynamicTimeDisplay()));
    }

    final additionalMetadata = additionalMetadataEntries
        .map((entry) => TableRow(children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(entry.key),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(entry.value),
              ),
            ]))
        .toList();

    return ExpansionTile(
      title: Text('Meta Data', style: Theme.of(context).textTheme.displaySmall),
      children: [
        if (additionalMetadata.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(children: additionalMetadata),
          ),
        if (additionalMetadata.isNotEmpty) const Divider(),
        if (progressItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Command Progress:'),
                const SizedBox(
                  height: 8,
                ),
                ...progressItems
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget buildResultTile(BiocentralCommandResult? result) {
    if (result == null) {
      return Container();
    }
    return ExpansionTile(
      title: Text('Result Data', style: Theme.of(context).textTheme.displaySmall),
      children: [
        Table(
          children: result
              .info()
              .entries
              .map((entry) => TableRow(children: [Text(entry.key.toString()), Text(entry.value.toString())]))
              .toList(),
        ),
      ],
    );
  }

  Widget buildResultVisualization(BiocentralCommandState commandState) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Inspect Result',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: commandState.visualizeResult!(commandState.currentCommandLog!),
      ),
    );
  }

  Widget buildResultDecision(BiocentralCommandBloc commandBloc, BiocentralCommandLog log) {
    final discardButton = BiocentralTooltip(
      message: 'Discard result (nothing has changed in your database)',
      child: ElevatedButton.icon(
        onPressed: () {
          commandBloc.add(BiocentralCommandDiscardResultEvent());
          setState(() {
            _hasOperatingLog = false;
          });
        },
        icon: const Icon(Icons.not_interested, color: Colors.white),
        label: const Text('Discard'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
    if (log.metaData.error != null) {
      return discardButton;
    }

    if (log.result == null) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BiocentralTooltip(
          message: 'Accept result and sync to database',
          child: ElevatedButton.icon(
            onPressed: () => commandBloc.add(BiocentralCommandAcceptResultEvent()),
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        discardButton,
      ],
    );
  }
}

class FadeScaleOnce extends StatefulWidget {
  final Widget child;

  const FadeScaleOnce({required this.child, super.key});

  @override
  State<FadeScaleOnce> createState() => _FadeScaleOnceState();
}

class _FadeScaleOnceState extends State<FadeScaleOnce> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
