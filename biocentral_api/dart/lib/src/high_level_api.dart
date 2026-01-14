import 'package:biocentral_api/src/clients/custom_models_client.dart';
import 'package:biocentral_api/src/clients/plm_eval_client.dart';
import 'package:biocentral_api/src/model/auto_eval_report.dart';
import 'package:biocentral_api/src/model/model_metadata.dart';

import 'api.dart' as gen;
import 'clients/embedding_client.dart';
import 'clients/predict_client.dart';
import 'clients/proteins_client.dart';
import 'clients/tasks/biocentral_server_task.dart';
import 'model/plm_eval_information.dart';
import 'model/prediction.dart';
import 'model/sequence_training_data.dart';
import 'model/taxonomy_item.dart';

final class BiocentralAPIHealth {
  final String url;
  final bool healthy;
  final String? version;

  BiocentralAPIHealth({required this.url, required this.healthy, this.version});
}

class BiocentralAPI {
  final String? fixedURL;
  final String? apiToken;
  final bool localOnly;

  final List<BiocentralAPIHealth> _urlHealthStatus;

  static const String _apiURL = "https://biocentral.rostlab.org";
  static const String _localhostURL = "http://localhost:9540";

  // API compatibility window: [MIN_API_VERSION, MAX_API_VERSION)
  static const String MIN_API_VERSION = "1.0.0"; // inclusive
  static const String MAX_API_VERSION = "2.0.0"; // exclusive

  BiocentralAPI._(
      {required this.fixedURL,
      required this.apiToken,
      required this.localOnly,
      required List<BiocentralAPIHealth> urlHealthStatus})
      : _urlHealthStatus = urlHealthStatus;

  static Future<BiocentralAPI> createWithHealthCheck(
      {String? fixedUrl, String? apiToken, bool localOnly = false}) async {
    List<BiocentralAPIHealth> _urlHealthStatus = [];
    if (fixedUrl != null) {
      if (localOnly && !(fixedUrl.contains("localhost") || fixedUrl.contains("127.0.0.1"))) {
        throw Exception("Using localOnly=true and a non-local fixedURL is not possible!");
      }
      _urlHealthStatus.add(BiocentralAPIHealth(url: fixedUrl, healthy: false));
    } else {
      _urlHealthStatus.add(BiocentralAPIHealth(url: _localhostURL, healthy: false));
      if (!localOnly) {
        _urlHealthStatus.add(BiocentralAPIHealth(url: _apiURL, healthy: false));
      }
    }
    final api = BiocentralAPI._(
        fixedURL: fixedUrl, apiToken: apiToken, localOnly: localOnly, urlHealthStatus: _urlHealthStatus);
    return await api.updateHealthStatus();
  }

  Future<BiocentralAPI> updateHealthStatus() async {
    final updatedList = <BiocentralAPIHealth>[];
    for (final healthStatus in _urlHealthStatus) {
      final updatedHealthStatus = await _healthCheck(healthStatus.url);
      updatedList.add(updatedHealthStatus);
    }
    return BiocentralAPI._(fixedURL: fixedURL, apiToken: apiToken, localOnly: localOnly, urlHealthStatus: updatedList);
  }

  List<BiocentralAPIHealth> getHealthStatus() {
    return List.from(_urlHealthStatus);
  }

  static Future<BiocentralAPIHealth> _healthCheck(String url) async {
    final defaultApi = gen.BiocentralApi(basePathOverride: url).getDefaultApi();

    try {
      final resp = await defaultApi.healthCheckHealthGet();
      if ((resp.statusCode ?? 404) != 200) {
        return BiocentralAPIHealth(url: url, healthy: false);
      }
      // Extract version string from response body
      final data = resp.data;
      String? serverVersion;
      try {
        final value = data?.value;
        if (value is Map) {
          final v = value['version'];
          if (v.toString().contains(".")) {
            serverVersion = v;
          }
        }
      } catch (_) {
        // ignore and treat as incompatible
      }

      if (serverVersion == null) {
        return BiocentralAPIHealth(url: url, healthy: false);
      }

      String serverMajor = serverVersion.split('.').first;
      String minMajor = MIN_API_VERSION.split('.').first;
      String maxMajor = MAX_API_VERSION.split('.').first;

      // Compare majors lexicographically since they are integers in string form
      // Ensure padding not needed as we only compare single number strings
      final isCompatible = (minMajor.compareTo(serverMajor) <= 0) && (serverMajor.compareTo(maxMajor) < 0);
      return BiocentralAPIHealth(url: url, healthy: isCompatible, version: serverVersion);
    } catch (e) {
      return BiocentralAPIHealth(url: url, healthy: false);
    }
  }

  static bool _isLocalUrl(String url) {
    return url.contains("localhost") || url.contains("127.0.0.1");
  }

  String? _getAvailableURL() {
    String? availableURL;
    for (final healthStatus in _urlHealthStatus) {
      if (healthStatus.healthy && _isLocalUrl(healthStatus.url)) {
        availableURL = healthStatus.url;
        break; // Always prefer local URL
      }
      if (healthStatus.healthy && availableURL == null) {
        availableURL = healthStatus.url;
      }
    }
    return availableURL;
  }

  gen.BiocentralApi _getAPI() {
    String? url = _getAvailableURL();
    if (url == null) {
      throw Exception("No healthy service available!");
    }
    return gen.BiocentralApi(basePathOverride: url);
  }
}

extension CustomModelsAPI on BiocentralAPI {
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

  Future<BiocentralServerTask<AutoEvalReport?>> autoeval({
    required String modelID,
    String? onnxFile,
    String? tokenizerConfig,
  }) async {
    return PlmEvalClient()
        .autoeval(api: _getAPI(), modelID: modelID, onnxFile: onnxFile, tokenizerConfig: tokenizerConfig);
  }
}

extension PredictAPI on BiocentralAPI {
  Future<List<ModelMetadata>?> getModelMetadata() {
    return PredictClient().getModelMetadata(api: _getAPI());
  }

  Future<BiocentralServerTask<Map<String, List<Prediction>>>> predict({
    required List<String> modelNames,
    required Map<String, String> sequenceData,
  }) async {
    assert(sequenceData.isNotEmpty, 'No sequences provided');
    final seqValues = sequenceData.values.toList();
    assert(seqValues.length == seqValues.toSet().length, 'Duplicate sequences provided');
    assert(modelNames.isNotEmpty, 'Empty model list provided');

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
