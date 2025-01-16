import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_dto.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_service_api.dart';
import 'package:biocentral/plugins/embeddings/data/projection_dto.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

final class EmbeddingsClientFactory extends BiocentralClientFactory<EmbeddingsClient> {
  @override
  EmbeddingsClient create(BiocentralServerData? server, BiocentralHubServerClient hubServerClient) {
    return EmbeddingsClient(server, hubServerClient);
  }
}

class EmbeddingsClient extends BiocentralClient {
  const EmbeddingsClient(super._server, super._hubServerClient);

  Future<Either<BiocentralException, String>> startEmbedding(
    String embedderName,
    String biotrainerEmbedderName,
    String databaseHash,
    bool reduce,
    bool useHalfPrecision,
  ) async {
    final Map<String, String> body = {
      'embedder_name': biotrainerEmbedderName,
      'database_hash': databaseHash,
      'reduce': reduce.toString(),
      'use_half_precision': useHalfPrecision.toString(),
    };
    final responseEither = await doPostRequest(EmbeddingsServiceEndpoints.embedding, body);
    return responseEither.flatMap((responseMap) => right(responseMap['task_id']));
  }

  Stream<String?> embeddingsTaskStream(String taskID) async* {
    // TODO jsonEncode might cost performance here
    String? updateFunction(String? currentString, BiocentralDTO biocentralDTO) =>
        biocentralDTO.embeddings != null ? jsonEncode(biocentralDTO.embeddings) : null;
    yield* taskUpdateStream<String?>(taskID, null, updateFunction);
  }

  Future<Either<BiocentralException, List<String>>> getMissingEmbeddings(
      Map<String, String> sequences, String embedderName, bool reduced) async {
    final Map<String, String> body = {
      'sequences': jsonEncode(sequences),
      'embedder_name': embedderName,
      'reduced': reduced.toString(),
    };
    final responseEither = await doPostRequest(EmbeddingsServiceEndpoints.getMissingEmbeddings, body);
    return responseEither.flatMap((responseMap) => right(BiocentralDTO(responseMap).missing));
  }

  Future<Either<BiocentralException, Unit>> addEmbeddings(
      String h5Bytes, Map<String, String> sequences, String embedderName, bool reduced) async {
    final Map<String, String> body = {
      'sequences': jsonEncode(sequences),
      'h5_bytes': h5Bytes,
      'embedder_name': embedderName,
      'reduced': reduced.toString(),
    };
    final responseEither = await doPostRequest(EmbeddingsServiceEndpoints.addEmbeddings, body);
    return responseEither.flatMap((responseMap) => right(unit));
  }

  Future<Either<BiocentralException, String>> projectionForSequences(Map<String, String> sequences,
      String projectionIdentifier, String method, int dimensions, String embedderName) async {
    final Map<String, String> body = {
      'sequences': jsonEncode(sequences),
      'method': method,
      'dimensions': dimensions.toString(),
      'embedder_name': embedderName,
    };
    final responseEither = await doPostRequest(EmbeddingsServiceEndpoints.projectionForSequences, body);
    return responseEither.flatMap((responseMap) => right(responseMap['task_id']));

    //return responseEither.flatMap((responseMap) {
    //  final Map umap = responseMap['umap_data'];
    //  final List<dynamic> rawCoordinates = umap['umap'];
    //  final List<(double, double)> coordinates =
    //      List.generate(rawCoordinates.length, (index) => (rawCoordinates[index][0], rawCoordinates[index][1]));
    //  return right(ProjectionData(umapIdentifier, null, coordinates));
    //});
  }

  Stream<String?> projectionTaskStream(String taskID) async* {
    String? updateFunction(String? currentString, BiocentralDTO biocentralDTO) => biocentralDTO.projectionJson;
    yield* taskUpdateStream<String?>(taskID, null, updateFunction);
  }

  @override
  String getServiceName() {
    return 'embeddings_service';
  }
}
