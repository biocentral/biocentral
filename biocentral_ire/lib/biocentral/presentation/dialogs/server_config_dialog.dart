import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> with BiocentralDialogCloseMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  late BiocentralAPIRepository _apiRepository;

  @override
  void initState() {
    super.initState();
    _apiRepository = context.read<BiocentralAPIRepository>();
  }

  BiocentralAPIHealth? _healthFor(String url, List<BiocentralAPIHealth> healthStatusList) {
    return healthStatusList.firstWhereOrNull((healthStatus) => healthStatus.url == url);
  }

  Future<void> _addServer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await _apiRepository.addServer(
      BiocentralServerData(
        name: _nameController.text,
        url: _urlController.text,
        availableServices: const [],
      ),
    );
    _nameController.clear();
    _urlController.clear();
    setState(() {});
  }

  Future<void> _removeServer(BiocentralServerData server) async {
    await _apiRepository.removeServer(server);
    setState(() {});
  }

  Future<void> _selectServer(BiocentralServerData? server) async {
    await _apiRepository.selectServer(server);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralDialog(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Server Configuration',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            StreamBuilder<List<BiocentralAPIHealth>>(
              initialData: _apiRepository.currentHealth,
              stream: _apiRepository.healthStatusStream,
              builder: (context, snapshot) {
                final healthStatusList = snapshot.data ?? [];
                return RadioGroup<BiocentralServerData?>(
                  groupValue: _apiRepository.selectedServer,
                  onChanged: _selectServer,
                  child: Column(
                    children: [
                      const RadioListTile<BiocentralServerData?>(
                        title: Text('Automatic'),
                        subtitle: Text('Prefer localhost, fall back to the official server'),
                        value: null,
                      ),
                      ..._apiRepository.servers.map(
                        (server) => RadioListTile<BiocentralServerData?>(
                          title: Text(server.name),
                          subtitle: Text(server.url),
                          value: server,
                          secondary: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 12,
                                color: _healthFor(server.url, healthStatusList)?.healthy == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              if (!server.isBuiltIn)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _removeServer(server),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(labelText: 'URL'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  BiocentralSmallButton(onTap: _addServer, label: 'Add server'),
                ],
              ),
            ),
            BiocentralSmallButton(onTap: closeDialog, label: 'Close'),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}
