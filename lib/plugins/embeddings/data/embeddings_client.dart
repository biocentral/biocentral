import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_dto.dart';
import 'package:biocentral/plugins/embeddings/data/embeddings_service_api.dart';
import 'package:biocentral/plugins/embeddings/data/projection_dto.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:biocentral/sdk/model/biocentral_config_option.dart';
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
    return responseEither
        .flatMap((responseMap) => right(List<String>.from(responseMap['missing']?.map((v) => v.toString()) ?? [])));
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

  Future<Either<BiocentralException, Map<String, List<BiocentralConfigOption>>>> getProjectionConfig() async {
    final responseEither = await doGetRequest(EmbeddingsServiceEndpoints.projectionConfig);
    return responseEither.flatMap((responseMap) => ProtspaceConfigHandler.fromMap(responseMap));
  }

  Future<Either<BiocentralException, String>> projectionForSequences(
    Map<String, String> sequences,
    String projectionIdentifier,
    String projectionMethod,
    Map<BiocentralConfigOption, dynamic> projectionConfig,
    String embedderName,
  ) async {
    final Map<String, String> body = {
      'sequences': jsonEncode(sequences),
      'method': projectionMethod,
      'config': jsonEncode(projectionConfig.map((option, value) => MapEntry(option.name, value))),
      'embedder_name': embedderName,
    };
    final responseEither = await doPostRequest(EmbeddingsServiceEndpoints.projectionForSequences, body);
    return responseEither.flatMap((responseMap) => right(responseMap['task_id']));
  }

  Stream<Map<ProjectionData, List<Map<String, dynamic>>>?> projectionTaskStream(String taskID) async* {
    Map<ProjectionData, List<Map<String, dynamic>>>? updateFunction(var currentMap, BiocentralDTO biocentralDTO) {
      final String? projections = biocentralDTO.projections;
      if (projections == null) {
        return null;
      }
      return ProtspaceFileHandler.parse(projections);
    }

    yield* taskUpdateStream<Map<ProjectionData, List<Map<String, dynamic>>>>(taskID, null, updateFunction);
  }

  @override
  String getServiceName() {
    return 'embeddings_service';
  }
}
