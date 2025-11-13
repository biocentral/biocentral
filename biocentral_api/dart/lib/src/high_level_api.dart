import 'package:biocentral_api/src/clients/custom_models_client.dart';
import 'package:biocentral_api/src/clients/plm_eval_client.dart';

import 'api.dart' as gen;
import 'clients/embedding_client.dart';
import 'clients/predict_client.dart';
import 'clients/proteins_client.dart';
import 'clients/tasks/biocentral_server_task.dart';
import 'model/plm_eval_information.dart';
import 'model/prediction.dart';
import 'model/sequence_training_data.dart';
import 'model/taxonomy_item.dart';

class BiocentralAPI {
  final String? fixedURL;
  final String? apiToken;
  final bool localOnly;

  final List<(String, bool)> _urlHealthStatus;

  static const String _apiURL = "https://biocentral.rostlab.org";
  static const String _localhostURL = "http://localhost:9540";

  BiocentralAPI._(
      {required this.fixedURL,
      required this.apiToken,
      required this.localOnly,
      required List<(String, bool)> urlHealthStatus})
      : _urlHealthStatus = urlHealthStatus;

  static Future<BiocentralAPI> createWithHealthCheck(
      {String? fixedUrl, String? apiToken, bool localOnly = false}) async {
    List<(String, bool)> _urlHealthStatus = [];
    if (fixedUrl != null) {
      if (localOnly && !(fixedUrl.contains("localhost") || fixedUrl.contains("127.0.0.1"))) {
        throw Exception("Using localOnly=true and a non-local fixedURL is not possible!");
      }
      _urlHealthStatus.add((fixedUrl, false));
    } else {
      _urlHealthStatus.add((_localhostURL, false));
      if (!localOnly) {
        // TODO!
        //_urlHealthStatus.add((_apiURL, false));
      }
    }
    final api = BiocentralAPI._(
        fixedURL: fixedUrl, apiToken: apiToken, localOnly: localOnly, urlHealthStatus: _urlHealthStatus);
    return await api.updateHealthStatus();
  }

  Future<BiocentralAPI> updateHealthStatus() async {
    final updatedHealthStatus = <(String, bool)>[];
    for (final (url, _) in _urlHealthStatus) {
      final healthy = await _healthCheck(url);
      updatedHealthStatus.add((url, healthy));
    }
    return BiocentralAPI._(
        fixedURL: fixedURL, apiToken: apiToken, localOnly: localOnly, urlHealthStatus: updatedHealthStatus);
  }

  Map<String, bool> getHealthStatus() {
    return Map.fromEntries(_urlHealthStatus.map((r) => MapEntry(r.$1, r.$2)));
  }

  static Future<bool> _healthCheck(String url) async {
    final defaultApi = gen.BiocentralApi(basePathOverride: url).getDefaultApi();

    try {
      final resp = await defaultApi.healthCheckHealthGet();
      return (resp.statusCode ?? 404) == 200;
    } catch (e) {
      return false;
    }
  }

  String? _getFirstAvailableURL() {
    for (final (url, health) in _urlHealthStatus) {
      if (health) {
        return url;
      }
    }
    return null;
  }

  gen.BiocentralApi _getAPI() {
    String? url = _getFirstAvailableURL();
    if (url == null) {
      throw Exception("No healthy service available!");
    }
    return gen.BiocentralApi(basePathOverride: url);
  }
}

extension CustomModelsAPI on BiocentralAPI {
  Future<Set<String>?> getProtocols() async {
    return CustomModelsClient().getProtocols(api: _getAPI());
  }

  Future<List<dynamic>?> getConfigOptionsForProtocol({required String protocol}) async {
    return CustomModelsClient().getConfigOptionsForProtocol(api: _getAPI(), protocol: protocol);
  }

  Future<String?> verifyTrainingConfig({
    required Map<String, dynamic> config,
  }) async {
    return CustomModelsClient().verifyTrainingConfig(api: _getAPI(), config: config);
  }

  Future<BiocentralServerTask<Map<String, dynamic>?>> train({
    required Map<String, dynamic> config,
    required List<SequenceTrainingData> trainingData,
  }) async {
    return CustomModelsClient().train(api: _getAPI(), config: config, trainingData: trainingData);
  }

  Future<BiocentralServerTask<Map<String, List<Prediction>>>> inference({
    required String modelHash,
    required Map<String, String> sequenceData,
  }) async {
    return CustomModelsClient().inference(api: _getAPI(), modelHash: modelHash, sequenceData: sequenceData);
  }
}

extension EmbeddingAPI on BiocentralAPI {
  Future<BiocentralServerTask<String>> embed({
    required String embedderName,
    required Map<String, String> sequenceData,
    bool reduce = true,
    bool useHalfPrecision = false,
  }) async {
    assert(sequenceData.isNotEmpty, 'No sequences provided');
    final seqValues = sequenceData.values.toList();
    assert(seqValues.length == seqValues.toSet().length, 'Duplicate sequences provided');

    return EmbeddingClient().embed(api: _getAPI(), embedderName: embedderName, sequenceData: sequenceData);
  }

  Future<Map<String, dynamic>?> projectionConfig() async {
    return EmbeddingClient().projectionConfig(api: _getAPI());
  }

  Future<BiocentralServerTask<Map<String, dynamic>?>> project({
    required String embedderName,
    required String method,
    required Map<String, String> sequenceData,
    required Map<String, dynamic> config,
  }) async {
    assert(sequenceData.isNotEmpty, 'No sequences provided');
    final seqValues = sequenceData.values.toList();
    assert(seqValues.length == seqValues.toSet().length, 'Duplicate sequences provided');

    return EmbeddingClient().project(
      api: _getAPI(),
      embedderName: embedderName,
      method: method,
      sequenceData: sequenceData,
      config: config,
    );
  }
}

extension PlmEvalAPI on BiocentralAPI {
  Future<PLMEvalInformation?> getPlmEvalInformation() async {
    return PlmEvalClient().getPlmEvalInformation(api: _getAPI());
  }

  Future<String?> validateModelID({
    required String modelID,
  }) async {
    return PlmEvalClient().validateModelID(api: _getAPI(), modelID: modelID);
  }

  Future<BiocentralServerTask<Map<String, dynamic>?>> autoeval({
    required String modelID,
    String? onnxFile,
    String? tokenizerConfig,
  }) async {
    return PlmEvalClient()
        .autoeval(api: _getAPI(), modelID: modelID, onnxFile: onnxFile, tokenizerConfig: tokenizerConfig);
  }
}

extension PredictAPI on BiocentralAPI {
  Future<Map<String, dynamic>?> getModelMetadata() {
    return PredictClient().getModelMetadata(api: _getAPI());
  }

  Future<BiocentralServerTask<Map<String, List<Prediction>>>> predict({
    required List<String> modelNames,
    required Map<String, String> sequenceData,
  }) async {
    assert(sequenceData.isNotEmpty, 'No sequences provided');
    final seqValues = sequenceData.values.toList();
    assert(seqValues.length == seqValues.toSet().length, 'Duplicate sequences provided');

    return PredictClient().predict(api: _getAPI(), modelNames: modelNames, sequenceData: sequenceData);
  }
}

extension ProteinsAPI on BiocentralAPI {
  Future<List<TaxonomyItem>?> taxonomy({
    required List<int> taxonomyIds,
  }) async {
    final result = await ProteinsClient().taxonomy(api: _getAPI(), taxonomyIds: taxonomyIds);
    return result?.toList();
  }
}
