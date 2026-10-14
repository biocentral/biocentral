import 'package:biocentral_api/biocentral_api.dart';
import 'package:biocentral_api/src/api.dart';
import 'package:biocentral_api/src/api/custom_models_api.dart';
import 'package:biocentral_api/src/model/cluster_hbi_request.dart';
import 'package:biocentral_api/src/model/cluster_hbi_response.dart';
import 'package:biocentral_api/src/model/split_hbi_request.dart';
import 'package:biocentral_api/src/model/split_hbi_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:dio/dio.dart';

class HbiClientService {
  final CustomModelsApi _api;

  HbiClientService({String? basePath})
      : _api = BiocentralApi(
          dio: Dio(BaseOptions(baseUrl: basePath ?? 'http://127.0.0.1:8000')),
        ).getCustomModelsApi();

  /// Execute Cluster-based HBI
  Future<ClusterHBIResponse?> executeClusterHbi({
    required String datasetHash,
    required Map<String, dynamic> targetData,
    Map<String, String>? sequenceData,
    num sequenceIdentityThreshold = 0.3,
    bool isNumeric = false,
    int iterations = 100,
  }) async {
    final targetsBuilder = MapBuilder<String, JsonObject?>();
    targetData.forEach((key, value) {
      targetsBuilder[key] = value != null ? JsonObject(value) : null;
    });

    final request = ClusterHBIRequestBuilder()
      ..datasetHash = datasetHash
      ..targetData = targetsBuilder
      ..sequenceIdentityThreshold = sequenceIdentityThreshold
      ..isNumeric = isNumeric
      ..iterations = iterations;

    if (sequenceData != null) {
      request.sequenceData = MapBuilder<String, String>(sequenceData);
    }

    final response = await _api.clusterHbiApiV1CustomModelsServiceClusterHbiPost(
      clusterHBIRequest: request.build(),
    );

    return response.data;
  }

  /// Execute Split-based HBI
  Future<SplitHBIResponse?> executeSplitHbi({
    required Map<String, String> trainSeqs,
    required Map<String, String> querySeqs,
    required Map<String, dynamic> trainLabels,
    required Map<String, dynamic> queryLabels,
    num evalueCutoff = 0.001,
    num minSeqId = 0.0,
    bool isNumeric = false,
    int iterations = 100,
  }) async {
    final trainLabelsBuilder = MapBuilder<String, JsonObject?>();
    trainLabels.forEach((k, v) {
      trainLabelsBuilder[k] = v != null ? JsonObject(v) : null;
    });

    final queryLabelsBuilder = MapBuilder<String, JsonObject?>();
    queryLabels.forEach((k, v) {
      queryLabelsBuilder[k] = v != null ? JsonObject(v) : null;
    });

    final request = SplitHBIRequestBuilder()
      ..trainSeqs = MapBuilder<String, String>(trainSeqs)
      ..querySeqs = MapBuilder<String, String>(querySeqs)
      ..trainLabels = trainLabelsBuilder
      ..queryLabels = queryLabelsBuilder
      ..evalueCutoff = evalueCutoff
      ..minSeqId = minSeqId
      ..isNumeric = isNumeric
      ..iterations = iterations;

    final response = await _api.splitHbiApiV1CustomModelsServiceSplitHbiPost(
      splitHBIRequest: request.build(),
    );

    return response.data;
  }
}