import 'dart:async';

import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:biocentral_api/biocentral_api.dart';


class BiocentralAPIRepository {
  BiocentralAPI _biocentralAPI;

  final _healthStatusController = StreamController<List<BiocentralAPIHealth>>.broadcast();

  Stream<List<BiocentralAPIHealth>> get healthStatusStream => _healthStatusController.stream;

  List<BiocentralAPIHealth>? _currentAPIHealth;

  final BiocentralHubServerClient _hubServerClient = BiocentralHubServerClient('https://hub.biocentral.cloud');

  BiocentralAPIRepository(this._biocentralAPI) : _currentAPIHealth = _biocentralAPI.getHealthStatus();

  BiocentralAPI getBiocentralAPI() {
    return _biocentralAPI;
  }

  BiocentralHubServerClient getHubServerClient() {
    return _hubServerClient;
  }

  void checkHealth() async {
    _biocentralAPI = await _biocentralAPI.updateHealthStatus();
    final List<BiocentralAPIHealth> healthInformationToStream = _biocentralAPI.getHealthStatus();
    _currentAPIHealth = healthInformationToStream;
    _healthStatusController.add(healthInformationToStream);
  }

  List<BiocentralAPIHealth> get currentHealth => _currentAPIHealth ?? [];

//BiocentralAPIRepository.withReload(BiocentralAPIRepository? old) {
//  _clientManager.setServer(old?._clientManager._server);
//}

  // Add dispose method
  void dispose() {
    _healthStatusController.close();
  }
}
