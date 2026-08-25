import 'dart:async';
import 'dart:convert';

import 'package:biocentral/sdk/util/biocentral_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';


@immutable
class DownloadProgress {
  final int bytesReceived;
  final int? totalBytes;
  final Uint8List bytes;

  const DownloadProgress(this.bytesReceived, this.totalBytes, this.bytes);

  bool isDone() {
    return totalBytes == null ? false : bytesReceived == totalBytes;
  }

  double? progress() => totalBytes != null ? (bytesReceived / totalBytes!) : null;
}

final class _ClientSandbox {
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
          message: 'Error for GET Request at $url$endpoint',
          error: e,
          stackTrace: stackTrace,
        ),
      );
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
          message: 'Error for POST Request at $url$endpoint',
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
    return urlEither.match((l) => left(l), (url) => _ClientSandbox.doGetRequest(url, endpoint));
  }

  Future<Either<BiocentralException, Map>> doPostRequest(String endpoint, Map<String, String> body) async {
    final urlEither = getBaseURL();
    return urlEither.match((l) => left(l), (url) => _ClientSandbox.doPostRequest(url, endpoint, body));
  }

  Future<Either<BiocentralException, String>> doSimpleFileDownload(String url) async {
    final downloadEither = await _ClientSandbox.downloadFile(url);
    return downloadEither.flatMap((bytes) => right(String.fromCharCodes(bytes.toList())));
  }
}

// TODO [Refactoring] Could be moved directly to biocentral_api
class BiocentralHubServerClient with HTTPClient {
  final String _baseUrl;

  static const String leaderBoardEndpoint = '/plm_leaderboard/';
  static const String publishLeaderboardEntryEndpoint = '/plm_leaderboard_publish/';

  BiocentralHubServerClient(this._baseUrl);

  @override
  Either<BiocentralException, String> getBaseURL() {
    return right(_baseUrl);
  }

  Future<Either<BiocentralException, Map>> downloadPLMLeaderboardData() async {
    final leaderboardMapEither = await doGetRequest(BiocentralHubServerClient.leaderBoardEndpoint);
    return leaderboardMapEither;
  }

  Future<Either<BiocentralException, Map>> publishResult(String result) async {
    final Map<String, String> body = {'result': result};

    final leaderboardMapEither = await doPostRequest(BiocentralHubServerClient.publishLeaderboardEntryEndpoint, body);
    return leaderboardMapEither;
  }

}
