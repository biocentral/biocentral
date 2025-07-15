import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/proteins/data/prediction_dto.dart';
import 'package:biocentral/plugins/proteins/data/protein_service_api.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

final class ProteinClientFactory extends BiocentralClientFactory<ProteinClient> {
  @override
  ProteinClient create(BiocentralServerData? server, BiocentralHubServerClient hubServerClient) {
    return ProteinClient(server, hubServerClient);
  }
}

class ProteinClient extends BiocentralClient {
  const ProteinClient(super._server, super._hubServerClient);

  Future<Either<BiocentralException, Map<int, Taxonomy>>> retrieveTaxonomy(Set<int> taxonomyIDs) async {
    final Map<String, String> body = {'taxonomy': jsonEncode(taxonomyIDs.map((e) => e.toString()).toList())};
    final responseEither = await doPostRequest(ProteinServiceEndpoints.retrieveTaxonomy, body);
    return responseEither.flatMap((responseMap) => parseTaxonomy(responseMap['taxonomy']));
  }

  Future<Either<BiocentralException, Map<String, dynamic>>> modelMetadata() async {
    final responseEither = await doGetRequest(ProteinServiceEndpoints.modelMetadata);
    return responseEither.flatMap((responseMap) => right(responseMap.map((k, v) => MapEntry(k.toString(), v))));
  }

  Stream<(BiocentralDTO, Map<String, dynamic>?)> predictionTaskStream(String taskID) async* {
    Map<String, dynamic>? updateFunction(Map<String, dynamic>? currentString, BiocentralDTO biocentralDTO) =>
        biocentralDTO.predictions;
    yield* taskUpdateStream<Map<String, dynamic>?>(taskID, null, updateFunction);
  }

  Future<Either<BiocentralException, String>> predictProtein(
    Map<String, Protein> proteins,
    List<String> modelNames,
  ) async {
    final Map<String, String> body = {
      'model_names': jsonEncode(modelNames),
      'sequence_input': jsonEncode(proteins.map((k, v) => MapEntry(k, v.sequence.seq))),
      'batch_size': '1',
    };
    final responseEither = await doPostRequest(ProteinServiceEndpoints.predictProtein, body);
    return responseEither.flatMap((responseMap) => right(responseMap['task_id']));
  }

  @override
  String getServiceName() {
    return 'protein_service';
  }
}
