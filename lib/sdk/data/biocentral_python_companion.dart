import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';
import 'package:serious_python/serious_python.dart';

class BiocentralPythonCompanion with HTTPClient {
  bool _companionReady = false;

  static Future<BiocentralPythonCompanion> startCompanion() async {
    // TODO Error handling / maybe downloading of asset
    final companion = BiocentralPythonCompanion();
    final companionAlreadyRunning = await companion._companionHealthCheck();
    if (!companionAlreadyRunning) {
      SeriousPython.run('assets/python_companion.zip', appFileName: 'python_companion.py');
    }
    return companion;
  }

  Future<bool> terminateCompanion() async {
    final responseEither = await super.doGetRequest('terminate');
    return true;
  }

  @override
  Either<BiocentralException, String> getBaseURL() {
    return right('http://127.0.0.1:50001/');
  }

  Future<bool> _companionHealthCheck() async {
    final response = await super.doGetRequest('health_check');
    if (response.isRight()) {
      return true;
    }
    return false;
  }

  Future<bool> _checkCompanionRunning() async {
    if (_companionReady) {
      return true;
    }
    final int maxRetries = 120;
    for (int retry = 0; retry < maxRetries; retry++) {
      try {
        final companionHealthCheck = await _companionHealthCheck();
        if (companionHealthCheck) {
          return true;
        }
      } catch (e) {
        // Server not ready yet, wait and try again
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    return false;
  }

  @override
  Future<Either<BiocentralException, Map>> doGetRequest(String endpoint) async {
    return _intercept<Map>(() => super.doGetRequest(endpoint));
  }

  @override
  Future<Either<BiocentralException, Map>> doPostRequest(String endpoint, Map<String, String> body) {
    return _intercept<Map>(() => super.doPostRequest(endpoint, body));
  }

  @override
  Future<Either<BiocentralException, String>> doSimpleFileDownload(String url) {
    return _intercept<String>(() => super.doSimpleFileDownload(url));
  }

  Future<Either<BiocentralException, T>> _intercept<T>(
      Future<Either<BiocentralException, T>> Function() operation) async {
    final companionRunning = await _checkCompanionRunning();
    if (!companionRunning) {
      return left(BiocentralNetworkException(
          message:
              'Could not reach python companion after max retries. Please restart the application and try again!'));
    }
    _companionReady = true;
    return operation();
  }
}
