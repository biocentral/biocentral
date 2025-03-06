import 'dart:async';
import 'dart:convert';

import 'package:biocentral/sdk/data/biocentral_server_data.dart';
import 'package:biocentral/sdk/data/biocentral_service_api.dart';
import 'package:biocentral/sdk/util/biocentral_exception.dart';
import 'package:biocentral/sdk/util/constants.dart';
import 'package:biocentral/sdk/util/logging.dart';
import 'package:biocentral/sdk/util/type_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'biocentral_task_dto.dart';

@immutable
class DownloadProgress {
  final int bytesReceived;
  final int? totalBytes;
  final double? progress;
  final Uint8List bytes;

  const DownloadProgress(this.bytesReceived, this.totalBytes, this.bytes)
      : progress = totalBytes != null ? bytesReceived / totalBytes : null;

  bool isDone() {
    return totalBytes == null ? false : bytesReceived == totalBytes;
  }
}

final class _BiocentralClientSandbox {
  static Either<BiocentralException, Map> _handleServerResponse(Response response) {
    if (response.statusCode != 200) {
      if (response.statusCode >= 500) {
        return left(
          BiocentralServerException(
            message: 'An error on the server happened, Status Code: ${response.statusCode} '
                '- Reason: ${response.reasonPhrase}',
          ),
        );
      }
      return left(
        BiocentralNetworkException(
          message:
              'A networking error happened, Status Code: ${response.statusCode} - Reason: ${response.reasonPhrase}',
        ),
      );
    }
    final responseMap = jsonDecode(response.body);
    if (responseMap == null) {
      return left(
        BiocentralParsingException(message: 'Could not parse response body to json! Response: ${response.body}'),
      );
    }
    final String? error = responseMap['error'];
    if (error != null && error.isNotEmpty) {
      return left(BiocentralServerException(message: 'An error on the server happened!', error: error));
    }
    return right(responseMap);
  }

  static Future<Either<BiocentralException, Map>> doGetRequest(String url, String endpoint) async {
    try {
      final Uri uri = Uri.parse(url + endpoint);
      final Response response = await http.get(uri);
      return _handleServerResponse(response);
    } catch (e, stackTrace) {
      return left(
        BiocentralNetworkException(
          message: "Error for GET Request at $url$endpoint",
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Test the server at [url] against the specified [endpoint]
  ///
  /// In contrast to [doGetRequest], this method does not throw an error if the connection cannot be established,
  /// but an empty map
  static Future<Map> isServerUp(String url, String endpoint) async {
    try {
      final Uri uri = Uri.parse(url + endpoint);
      final Response response = await http.get(uri);
      if (response.statusCode != 200) {
        return {};
      }
      return jsonDecode(response.body);
    } catch (e) {
      return {};
    }
  }

  static Future<Either<BiocentralException, Map>> doPostRequest(
    String url,
    String endpoint,
    Map<String, String> body,
  ) async {
    try {
      final Uri uri = Uri.parse(url + endpoint);
      final Map<String, String> headers = {'Content-Type': 'application/json'};
      final Response response = await http.post(uri, headers: headers, body: json.encode(body));
      return _handleServerResponse(response);
    } catch (e, stackTrace) {
      return left(
        BiocentralNetworkException(
          message: "Error for POST Request at $url$endpoint",
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  static Future<Either<BiocentralException, Uint8List>> downloadFile(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      final Response response = await http.get(uri);

      if (response.statusCode != 200) {
        return left(
          BiocentralNetworkException(message: 'Failed to download file. Status code: ${response.statusCode}'),
        );
      }
      final Uint8List downloadedBytes = response.bodyBytes;

      if (downloadedBytes.isEmpty) {
        return left(BiocentralNetworkException(message: 'Downloaded file is empty!'));
      }

      return right(downloadedBytes);
    } catch (e, stackTrace) {
      return left(
        BiocentralNetworkException(message: 'Error downloading file from $url', error: e, stackTrace: stackTrace),
      );
    }
  }

  static Stream<Either<BiocentralException, DownloadProgress>> downloadFileWithProgress(String url) async* {
    int? totalBytes;

    try {
      final Uri uri = Uri.parse(url);

      // Try to get the file size with a HEAD request
      final headResponse = await http.head(uri);
      if (headResponse.statusCode == 200) {
        totalBytes = int.tryParse(headResponse.headers['content-length'] ?? '');
      }

      final request = http.Request('GET', uri);
      final response = await request.send();

      if (response.statusCode != 200) {
        yield left(
          BiocentralNetworkException(message: 'Failed to start download. Status code: ${response.statusCode}'),
        );
        return;
      }

      // If we didn't get the size from HEAD, try to get it from GET
      totalBytes ??= response.contentLength;

      int received = 0;

      await for (final chunk in response.stream) {
        received += chunk.length;

        yield right(DownloadProgress(received, totalBytes, Uint8List.fromList(chunk)));
      }
      // Empty last chunk to indicate that download is done
      yield right(DownloadProgress(received, received, Uint8List.fromList([])));
    } catch (e, stackTrace) {
      yield left(
        BiocentralNetworkException(message: 'Error downloading file from $url', error: e, stackTrace: stackTrace),
      );
    }
  }
}

mixin HTTPClient {

  Either<BiocentralException, String> getBaseURL();

  Future<Either<BiocentralException, Map>> doGetRequest(String endpoint) async {
    final urlEither = getBaseURL();
    return urlEither.match((l) => left(l), (url) => _BiocentralClientSandbox.doGetRequest(url, endpoint));
  }

  Future<Either<BiocentralException, Map>> doPostRequest(String endpoint, Map<String, String> body) async {
    final urlEither = getBaseURL();
    return urlEither.match((l) => left(l), (url) => _BiocentralClientSandbox.doPostRequest(url, endpoint, body));
  }

  Future<Either<BiocentralException, String>> doSimpleFileDownload(String url) async {
    final downloadEither = await _BiocentralClientSandbox.downloadFile(url);
    return downloadEither.flatMap((bytes) => right(String.fromCharCodes(bytes.toList())));
  }

}

abstract class BiocentralClient with HTTPClient {
  final BiocentralServerData? _server;
  final BiocentralHubServerClient _hubServerClient;

  const BiocentralClient(this._server, this._hubServerClient);

  String getServiceName();

  BiocentralHubServerClient get hubServerClient => _hubServerClient;

  @override
  Either<BiocentralException, String> getBaseURL() {
    if (_server == null) {
      return left(BiocentralNetworkException(message: 'Not connected to any server to perform request!'));
    }
    return right(_server!.url);
  }

  Future<Either<BiocentralException, Unit>> transferFile(
    String databaseHash,
    StorageFileType fileType,
    Future<String> Function() databaseConversionFunction,
  ) async {
    // Check if hash exists
    final responseEither = await doGetRequest("${BiocentralServiceEndpoints.hashes}$databaseHash/${fileType.name}");
    return responseEither.match((l) => left(l), (responseMap) async {
      final bool hashExists = responseMap[databaseHash] ?? false;
      if (hashExists) {
        logger.i('Found file type $fileType for $databaseHash on server, file is not transferred!');
        return right(unit);
      } else {
        final String convertedDatabase = await databaseConversionFunction();

        if (convertedDatabase.isEmpty) {
          // Nothing to send
          return right(unit);
        }

        final transferResponseEither = await doPostRequest(
          BiocentralServiceEndpoints.transferFile,
          {'hash': databaseHash, 'file_type': fileType.name, 'file': convertedDatabase},
        );
        return transferResponseEither.match((e) => left(e), (r) {
          logger.i('File type $fileType was transferred for database hash $databaseHash!');
          return right(unit);
        });
      }
    });
  }

  Future<Either<BiocentralException, List<BiocentralDTO>>> getTaskStatus(String taskID) async {
    final responseEither = await doGetRequest('${BiocentralServiceEndpoints.taskStatus}/$taskID');
    return responseEither.flatMap((responseMaps) {
      final sortedUpdatesKeys = responseMaps.keys.toList()..sort();
      return right(sortedUpdatesKeys.map((sortedKey) => BiocentralDTO(responseMaps[sortedKey])).toList());
    });
  }

  Stream<T?> taskUpdateStream<T>(
      String taskID, T? initialValue, T? Function(T?, BiocentralDTO) updateFunction) async* {
    const int maxRequests = 1800; // TODO Listening for only 60 Minutes
    bool finished = false;
    T? currentValue = initialValue;
    for (int i = 0; i < maxRequests; i++) {
      if (finished) {
        break;
      }
      await Future.delayed(const Duration(seconds: 2));
      final biocentralDTOEither = await getTaskStatus(taskID);

      if (biocentralDTOEither.isLeft() || biocentralDTOEither.getRight().isNone()) {
        finished = true;
        continue;
      }
      final biocentralDTOs = biocentralDTOEither.getRight().getOrElse(() => []);
      for(final biocentralDTO in biocentralDTOs) {
        if (biocentralDTO.taskStatus?.isFinished() ?? true) {
          finished = true;
        }
        currentValue = updateFunction(currentValue, biocentralDTO) ?? currentValue;
        yield currentValue;
      }
    }
  }

}

abstract class BiocentralClientFactory<T extends BiocentralClient> {
  T create(BiocentralServerData? server, BiocentralHubServerClient hubServerClient);

  Type getClientType() {
    return T;
  }
}

class BiocentralHubServerClient with HTTPClient {
  final String _baseUrl;

  BiocentralHubServerClient(this._baseUrl);

  @override
  Either<BiocentralException, String> getBaseURL() {
    return right(_baseUrl);
  }

}

class ClientManager {
  final Map<Type, BiocentralClientFactory> _factories = {};
  final Map<Type, BiocentralClient> _clients = {};
  // TODO Config
  final BiocentralHubServerClient _hubServerClient = BiocentralHubServerClient('http://localhost:5000');

  BiocentralServerData? _server;

  void registerFactory(BiocentralClientFactory factory) {
    _factories[factory.getClientType()] = factory;
  }

  void setServer(BiocentralServerData? server) {
    _server = server;
    _clients.clear();
  }

  T getClient<T extends BiocentralClient>() {
    if (!_clients.containsKey(T)) {
      final factory = _factories[T];
      if (factory == null) {
        throw Exception('No factory registered for $T');
      }
      _clients[T] = factory.create(_server, _hubServerClient);
    }
    return _clients[T] as T;
  }

  BiocentralHubServerClient getHubServerClient() {
    return _hubServerClient;
  }

  bool isServiceAvailable<T extends BiocentralClient>() {
    return _factories.containsKey(T);
  }
}

final class BiocentralClientRepository {
  final ClientManager _clientManager = ClientManager();

  BiocentralClientRepository.withReload(BiocentralClientRepository? old) {
    _clientManager.setServer(old?._clientManager._server);
  }

  void registerServices(List<BiocentralClientFactory> factories) {
    for (BiocentralClientFactory factory in factories) {
      _clientManager.registerFactory(factory);
    }
  }

  Future<Set<BiocentralServerData>> getAvailableServers() async {
    // TODO Connect to master server and get actual list
    final services = await checkServerStatus(Constants.localHostServerURL);
    if (services.isEmpty) {
      return {};
    }
    return {BiocentralServerData.local(availableServices: services)};
  }

  Future<List<String>> checkServerStatus(String url) async {
    final serviceMap = await _BiocentralClientSandbox.isServerUp(url, BiocentralServiceEndpoints.services);
    return List<String>.from(serviceMap['services'] ?? {});
  }

  Future<Either<BiocentralException, Unit>> connectToServer(BiocentralServerData server) async {
    final services = await checkServerStatus(server.url);
    if (services.isEmpty) {
      return left(BiocentralServerException(message: 'The server does not provide any services!'));
    }
    _clientManager.setServer(server);
    logger.i('Connected to biocentral server with services: ${server.availableServices}');
    return right(unit);
  }

  bool isServiceAvailable<T extends BiocentralClient>() {
    return _clientManager.isServiceAvailable<T>();
  }

  T getServiceClient<T extends BiocentralClient>() {
    return _clientManager.getClient<T>();
  }
}
