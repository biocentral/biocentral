import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

import 'package:biocentral/plugins/embeddings/data/embeddings_service_api.dart';

final class EmbeddingsClientFactory extends BiocentralClientFactory<EmbeddingsClient> {
  @override
  EmbeddingsClient create(BiocentralServerData? server) {
    return EmbeddingsClient(server);
  }
}

class EmbeddingsClient extends BiocentralClient {
  EmbeddingsClient(super._server);

  Future<Either<BiocentralException, String>> embed(String embedderName, String biotrainerEmbedderName,
      String databaseHash, bool reduce, bool useHalfPrecision,) async {
    final Map<String, String> body = {
      'embedder_name': biotrainerEmbedderName,
      'database_hash': databaseHash,
      'reduce': reduce.toString(),
      'use_half_precision': useHalfPrecision.toString(),
    };
    final responseEither = await doPostRequest(EmbeddingsServiceEndpoints.embeddingEndpoint, body);
    // TODO jsonEncode might cost performance here
    return responseEither.flatMap((responseMap) => right(jsonEncode(responseMap['embeddings_file'])));
  }

  Future<Either<BiocentralException, UMAPData>> umap(
      String umapIdentifier, List<PerSequenceEmbedding> embeddings,) async {
    final Map<String, String> body = {
      'embeddings_per_sequence': jsonEncode(List.generate(embeddings.length, (index) => embeddings[index].rawValues())),
    };
    final responseEither = await doPostRequest(EmbeddingsServiceEndpoints.umapEndpoint, body);
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
