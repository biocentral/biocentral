import 'dart:async';

import 'package:biocentral/sdk/domain/biocentral_api_repository.dart';

class BiocentralAPIHealthService {
  final BiocentralAPIRepository _repository;
  Timer? _timer;

  BiocentralAPIHealthService(this._repository);

  void startMonitoring({Duration interval = const Duration(seconds: 20)}) {
    _checkHealth(); // Immediate check
    _timer = Timer.periodic(interval, (_) => _checkHealth());
  }

  Future<void> _checkHealth() async {
    try {
      _repository.checkHealth();
    } catch (e) {
      // TODO [Error Handling]
    }
  }

  void stopMonitoring() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}
