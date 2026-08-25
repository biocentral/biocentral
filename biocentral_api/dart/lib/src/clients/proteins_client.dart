import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/model/clustering_request.dart';
import 'package:biocentral_api/src/model/task_dto.dart';
import 'package:biocentral_api/src/model/task_status.dart';
import 'package:biocentral_api/src/model/taxonomy_item.dart';
import 'package:biocentral_api/src/model/taxonomy_request.dart';
import 'package:built_collection/built_collection.dart';

import 'tasks/biocentral_server_task.dart';
import 'tasks/dto_handler.dart';
import 'tasks/submit_task.dart';

class _ClusterDtoHandler extends DtoHandler<Map<String, List<String>>> {
  @override
  Map<String, List<String>>? handle(List<TaskDTO> dtos) {
    for (final dto in dtos) {
      if (dto.status == TaskStatus.FINISHED) {
        return dto.clusteredData?.asMap().map((k, v) => MapEntry(k, v.toList()));
      }
    }
    return null;
  }
}

class ProteinsClient {
  /// Retrieve taxonomy data for the provided taxonomy IDs.
  Future<BuiltList<TaxonomyItem>?> taxonomy({
    required gen.BiocentralApi api,
    required List<int> taxonomyIds,
  }) async {
    final proteinsApi = api.getProteinsApi();
    final req = TaxonomyRequest((b) => b..taxonomyIds.replace(BuiltList<int>(taxonomyIds)));

    try {
      final resp = await proteinsApi.taxonomyApiV1ProteinServiceTaxonomyPost(taxonomyRequest: req);
      return resp.data?.taxonomy;
    } catch (e) {
      print('Exception when calling ProteinsApi->taxonomy: $e');
      return null;
    }
  }

  Future<BiocentralServerTask<Map<String, List<String>>>> cluster({
    required gen.BiocentralApi api,
    required Map<String, String> sequenceData,
    required double sequenceIdentityThreshold,
  }) async {
    assert(sequenceData.isNotEmpty, 'No sequences provided');
    final seqValues = sequenceData.values.toList();
    assert(seqValues.length == seqValues.toSet().length, 'Duplicate sequences provided');

    final proteinsApi = api.getProteinsApi();
    final clusteringRequest = ClusteringRequest((b) => b
      ..sequenceData.replace(BuiltMap<String, String>(sequenceData))
      ..sequenceIdentityThreshold = sequenceIdentityThreshold);

    final taskId = await submitTask(
      () => proteinsApi.triggerProteinClusteringApiV1ProteinServiceClusterPost(clusteringRequest: clusteringRequest),
    );

    return BiocentralServerTask<Map<String, List<String>>>(
      taskId: taskId,
      api: api,
      dtoHandler: _ClusterDtoHandler(),
    );
  }
}
