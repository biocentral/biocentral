import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_dto.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_service_api.dart';
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

  Future<Either<BiocentralException, UMAPData>> umap(
    String umapIdentifier,
    List<PerSequenceEmbedding> embeddings,
  ) async {
    final Map<String, String> body = {
      'embeddings_per_sequence': jsonEncode(List.generate(embeddings.length, (index) => embeddings[index].rawValues())),
    };
    final responseEither = await doPostRequest(EmbeddingsServiceEndpoints.umap, body);
    return responseEither.flatMap((responseMap) {
      final Map umap = responseMap['umap_data'];
      final List<dynamic> rawCoordinates = umap['umap'];
      final List<(double, double)> coordinates =
          List.generate(rawCoordinates.length, (index) => (rawCoordinates[index][0], rawCoordinates[index][1]));
      return right(UMAPData(umapIdentifier, null, coordinates));
    });
  }

  @override
  String getServiceName() {
    return 'embeddings_service';
  }
}
