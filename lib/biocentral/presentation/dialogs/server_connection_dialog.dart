import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_icons/simple_icons.dart';

class ServerConnectionDialog extends StatefulWidget {
  const ServerConnectionDialog({super.key});

  @override
  State<ServerConnectionDialog> createState() => _ServerConnectionDialogState();
}

class _ServerConnectionDialogState extends State<ServerConnectionDialog> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<BiocentralClientBloc>(context).add(BiocentralClientLoadDataEvent());
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final BiocentralClientBloc biocentralClientBloc = BlocProvider.of<BiocentralClientBloc>(context);
    return BlocBuilder<BiocentralClientBloc, BiocentralClientState>(builder: (context, state) {
      return BiocentralDialog(
        children: [
          SizedBox(
              width: SizeConfig.screenWidth(context) * 0.75,
              height: SizeConfig.screenHeight(context) * 0.6,
              child: buildServerConnection(biocentralClientBloc, state),),
          BiocentralStatusIndicator(state: state, center: true),
          BiocentralSmallButton(
            label: 'Close',
            onTap: closeDialog,
          ),
        ],
      );
    },);
  }

  Widget buildServerConnection(BiocentralClientBloc biocentralClientBloc, BiocentralClientState state) {
    Widget serverList = const Text('No servers available!');
    if(state.availableServersToConnect.isNotEmpty) {
      serverList = Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: state.availableServersToConnect.length,
          itemBuilder: (context, index) {
            final BiocentralServerData serverData = state.availableServersToConnect.toList()[index];
            final bool connectedToThisServer = serverData == state.connectedServer;
            return Card(
              child: ExpansionTile(
                leading: Icon(Icons.circle, color: connectedToThisServer ? Colors.green : Colors.grey),
                title: Text(
                  serverData.name,
                ),
                children: [
                  const Text('URL:'),
                  Text(serverData.url),
                  const Text('Available Services on this Server:'),
                  ...serverData.availableServices.map((service) => Text(service)),
                  BiocentralSmallButton(
                    label: connectedToThisServer ? 'Disconnect' : 'Connect',
                    onTap: () {
                      final event = connectedToThisServer
                          ? BiocentralClientDisconnectEvent(server: serverData)
                          : BiocentralClientConnectEvent(server: serverData);
                      biocentralClientBloc.add(event);
                    },
                  ),
                ],),);
          },
        ),
      );
    }

    return Column(
      children: [
        Text('Connect to a Server for Advanced Calculations', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () => biocentralClientBloc.add(BiocentralClientLoadDataEvent()),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh List'),),
        const SizedBox(height: 20),
        const Text('Available servers:'),
        const SizedBox(height: 8),
        serverList,
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
