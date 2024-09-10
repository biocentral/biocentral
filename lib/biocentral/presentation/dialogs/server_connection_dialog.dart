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
        small: false, // TODO Small Dialog not working yet
        children: [
          SizedBox(
              width: SizeConfig.screenWidth(context) * 0.75,
              height: SizeConfig.screenHeight(context) * 0.6,
              child: buildServerTabBar(biocentralClientBloc, state)),
          BiocentralStatusIndicator(state: state, center: true),
          BiocentralSmallButton(
            label: "Close",
            onTap: closeDialog,
          ),
        ],
      );
    });
  }

  Widget buildServerTabBar(BiocentralClientBloc biocentralClientBloc, BiocentralClientState state) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Center(child: Text("Connect to a Server for Advanced Calculations")),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.cloud_outlined), text: "Connect"),
              Tab(icon: Icon(Icons.file_download_outlined), text: "Download Local Server"),
            ],
          ),
        ),
        body: TabBarView(
          children: [buildConnectionTab(biocentralClientBloc, state), buildDownloadTab(biocentralClientBloc, state)],
        ),
      ),
    );
  }

  Widget buildConnectionTab(BiocentralClientBloc biocentralClientBloc, BiocentralClientState state) {
    return Column(
      children: [
        const SizedBox(height: 8),
        ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () => biocentralClientBloc.add(BiocentralClientLoadDataEvent()),
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh List")),
        const SizedBox(height: 20),
        const Text("Available servers:"),
        const SizedBox(height: 8),
        Expanded(
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
                    const Text("URL:"),
                    Text(serverData.url),
                    const Text("Available Services on this Server:"),
                    ...serverData.availableServices.map((service) => Text(service)),
                    BiocentralSmallButton(
                      label: connectedToThisServer ? "Disconnect" : "Connect",
                      onTap: () {
                        final event = connectedToThisServer
                            ? BiocentralClientDisconnectEvent(server: serverData)
                            : BiocentralClientConnectEvent(server: serverData);
                        biocentralClientBloc.add(event);
                      },
                    ),
                  ]));
            },
          ),
        ),
      ],
    );
  }

  Widget buildDownloadTab(BiocentralClientBloc biocentralClientBloc, BiocentralClientState state) {
    if (state.serverDownloadURLs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: state.serverDownloadURLs.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          state.extractedExecutablePath == null
              ? Container()
              : BiocentralSmallButton(
                  label: "Launch now!",
                  onTap: () => biocentralClientBloc.add(BiocentralClientLaunchExistingLocalServerEvent()),
                ),
          TabBar(
            isScrollable: true,
            tabs: state.serverDownloadURLs.keys
                .map((os) => Tab(
                      text: os.capitalize(),
                      icon: getIconForOS(os),
                    ))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              children: state.serverDownloadURLs.entries.map((entry) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: BiocentralSmallButton(
                        label: "Download biocentral server for ${entry.key.capitalize()}",
                        onTap: state.isOperating()
                            ? null
                            : () => biocentralClientBloc
                                .add(BiocentralClientDownloadLocalServerEvent(entry.key, entry.value)),
                      ),
                    ),
                    buildLaunchServer(state.downloadedExecutablePaths[entry.key], biocentralClientBloc, state),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget getIconForOS(String os) {
    final iconData = switch (os.toLowerCase()) {
      "windows" => SimpleIcons.windows10,
      "linux" => SimpleIcons.linux,
      "macos" => SimpleIcons.macos,
      _ => Icons.personal_video
    };
    return Icon(iconData);
  }

  Widget buildLaunchServer(
      String? executablePath, BiocentralClientBloc biocentralClientBloc, BiocentralClientState state) {
    if (executablePath == null) {
      return Container();
    }
    return Column(
      children: [
        const Text("Executable Path:"),
        Text(executablePath),
        BiocentralSmallButton(
          label: "Start server now!",
          onTap: state.isOperating()
              ? null
              : () => biocentralClientBloc.add(BiocentralClientLaunchLocalServerEvent(executablePath)),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
