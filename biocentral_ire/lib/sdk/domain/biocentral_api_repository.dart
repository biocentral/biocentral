import 'dart:async';
import 'dart:convert';

import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:biocentral/sdk/data/biocentral_server_data.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiocentralAPIRepository {
  static const String _customServersPrefKey = 'biocentralCustomServers';
  static const String _selectedServerUrlPrefKey = 'biocentralSelectedServerUrl';

  BiocentralAPI _biocentralAPI;

  final _healthStatusController = StreamController<List<BiocentralAPIHealth>>.broadcast();

  Stream<List<BiocentralAPIHealth>> get healthStatusStream => _healthStatusController.stream;

  final _serverFallbackController = StreamController<String>.broadcast();

  Stream<String> get serverFallbackMessages => _serverFallbackController.stream;

  List<BiocentralAPIHealth>? _currentAPIHealth;

  final BiocentralHubServerClient _hubServerClient = BiocentralHubServerClient('https://hub.biocentral.cloud');

  List<BiocentralServerData> _customServers = [];

  BiocentralServerData? _selectedServer;

  bool _isFallenBack = false;

  BiocentralAPIRepository(this._biocentralAPI) : _currentAPIHealth = _biocentralAPI.getHealthStatus();

  static Future<BiocentralAPIRepository> create(BiocentralAPI biocentralAPI) async {
    final repository = BiocentralAPIRepository(biocentralAPI);
    await repository._restoreServers();
    return repository;
  }

  Future<void> _restoreServers() async {
    final prefs = await SharedPreferences.getInstance();

    final storedServers = prefs.getString(_customServersPrefKey);
    if (storedServers != null) {
      final decoded = jsonDecode(storedServers) as List<dynamic>;
      _customServers = decoded.map((entry) => BiocentralServerData.fromJson(entry as Map<String, dynamic>)).toList();
      for (final server in _customServers) {
        _biocentralAPI = await _biocentralAPI.withUrl(server.url);
      }
    }

    final selectedUrl = prefs.getString(_selectedServerUrlPrefKey);
    if (selectedUrl != null) {
      _biocentralAPI = await _biocentralAPI.withSelectedUrl(selectedUrl);
      _selectedServer = _allServers.firstWhereOrNull((server) => server.url == selectedUrl);
    }

    _emitHealth();
  }

  List<BiocentralServerData> get _allServers =>
      [const BiocentralServerData.local(), const BiocentralServerData.official(), ..._customServers];

  List<BiocentralServerData> get servers => List.unmodifiable(_allServers);

  BiocentralServerData? get selectedServer => _selectedServer;

  BiocentralAPI getBiocentralAPI() {
    return _biocentralAPI;
  }

  BiocentralHubServerClient getHubServerClient() {
    return _hubServerClient;
  }

  Future<void> addServer(BiocentralServerData server) async {
    _biocentralAPI = await _biocentralAPI.withSelectedUrl(server.url);
    _customServers = [..._customServers, server];
    _selectedServer = server;
    _isFallenBack = false;
    await _persistServers();
    _emitHealth();
    _checkFallback();
  }

  Future<void> removeServer(BiocentralServerData server) async {
    if (server.isBuiltIn) {
      return;
    }
    _biocentralAPI = _biocentralAPI.withoutUrl(server.url);
    _customServers = _customServers.where((existing) => existing.url != server.url).toList();
    if (_selectedServer?.url == server.url) {
      _selectedServer = null;
      _isFallenBack = false;
    }
    await _persistServers();
    _emitHealth();
  }

  Future<void> selectServer(BiocentralServerData? server) async {
    _biocentralAPI = await _biocentralAPI.withSelectedUrl(server?.url);
    _selectedServer = server;
    _isFallenBack = false;
    await _persistServers();
    _emitHealth();
    _checkFallback();
  }

  Future<void> _persistServers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _customServersPrefKey,
      jsonEncode(_customServers.map((server) => server.toJson()).toList()),
    );
    if (_selectedServer != null) {
      await prefs.setString(_selectedServerUrlPrefKey, _selectedServer!.url);
    } else {
      await prefs.remove(_selectedServerUrlPrefKey);
    }
  }

  void checkHealth() async {
    _biocentralAPI = await _biocentralAPI.updateHealthStatus();
    _emitHealth();
    _checkFallback();
  }

  void _emitHealth() {
    final List<BiocentralAPIHealth> healthInformationToStream = _biocentralAPI.getHealthStatus();
    _currentAPIHealth = healthInformationToStream;
    _healthStatusController.add(healthInformationToStream);
  }

  void _checkFallback() {
    final selectedServer = _selectedServer;
    if (selectedServer == null) {
      return;
    }
    final activeUrl = _biocentralAPI.activeUrl;
    final hasFallenBack = activeUrl != null && activeUrl != selectedServer.url;
    if (hasFallenBack && !_isFallenBack) {
      _isFallenBack = true;
      final fallbackServer = _allServers.firstWhereOrNull((server) => server.url == activeUrl);
      _serverFallbackController.add(
        '${selectedServer.name} is unreachable, falling back to ${fallbackServer?.name ?? activeUrl}',
      );
    } else if (!hasFallenBack && _isFallenBack) {
      _isFallenBack = false;
      _serverFallbackController.add('${selectedServer.name} is reachable again');
    }
  }

  List<BiocentralAPIHealth> get currentHealth => _currentAPIHealth ?? [];

//BiocentralAPIRepository.withReload(BiocentralAPIRepository? old) {
//  _clientManager.setServer(old?._clientManager._server);
//}

  // Add dispose method
  void dispose() {
    _healthStatusController.close();
    _serverFallbackController.close();
  }
}
