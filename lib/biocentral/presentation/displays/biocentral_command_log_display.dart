import 'package:biocentral/biocentral/bloc/biocentral_command_log_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiocentralCommandLogDisplay extends StatefulWidget {
  const BiocentralCommandLogDisplay({super.key});

  @override
  State<BiocentralCommandLogDisplay> createState() => _BiocentralCommandLogDisplayState();
}

class _BiocentralCommandLogDisplayState extends State<BiocentralCommandLogDisplay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiocentralCommandLogBloc, BiocentralCommandLogState>(
      builder: (context, state) {
        return BiocentralLogContainer(
            title: 'Executed Commands',
            logsWidget: ListView.builder(
              itemCount: state.commandLogs.length,
              itemBuilder: (context, index) {
                final BiocentralCommandLog log = state.commandLogs[index];
                return Column(
                  children: [
                    buildCommandLogDisplay(log),
                    if (index < state.commandLogs.length - 1) const Icon(Icons.arrow_downward, color: Colors.white),
                  ],
                );
              },
            ),);
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
            buildResultTile(log.resultData),
          ],),),
    );
  }

  Widget getIconByCommandType(BiocentralCommandLog log) {
    if(log.commandStatus == BiocentralCommandStatus.operating) {
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
          children: commandConfig
              .entries
              .map((entry) => TableRow(children: [Text(entry.key.toString()), Text(entry.value.toString())]))
              .toList(),
        ),
      ],
    );
  }

  Widget buildMetaDataTile(BiocentralCommandMetaData metaData) {
    return ExpansionTile(
      title: Text('Meta Data', style: Theme.of(context).textTheme.displaySmall),
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

  Widget buildResultTile(BiocentralCommandResultData? resultData) {
    if(resultData == null) {
      return Container();
    }
    return ExpansionTile(
      title: Text('Result Data', style: Theme.of(context).textTheme.displaySmall),
      children: [
        Table(
          children: resultData.resultMap.entries
              .map((entry) => TableRow(children: [Text(entry.key.toString()), Text(entry.value.toString())]))
              .toList(),
        ),
      ],
    );
  }
}
