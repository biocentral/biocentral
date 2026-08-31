import 'package:biocentral_api/biocentral_api.dart';
import 'package:biocentral_api/src/clients/active_learning_client.dart';
import 'package:biocentral_api/src/clients/custom_models_client.dart';
import 'package:biocentral_api/src/clients/stats_client.dart';
import 'package:biocentral_api/src/model/projection_result.dart';
import 'package:built_collection/built_collection.dart';

import 'api.dart' as gen;
import 'clients/embedding_client.dart';
import 'clients/predict_client.dart';
import 'clients/proteins_client.dart';

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
  final String? _selectedUrl;

  static const String _apiURL = "https://biocentral.rostlab.org";
  static const String _localhostURL = "http://localhost:9540";

  // API compatibility window: [MIN_API_VERSION, MAX_API_VERSION)
  static const String MIN_API_VERSION = "1.0.0"; // inclusive
  static const String MAX_API_VERSION = "3.0.0"; // exclusive

  BiocentralAPI._(
      {required this.fixedURL,
      required this.apiToken,
      required this.localOnly,
      required List<BiocentralAPIHealth> urlHealthStatus,
      String? selectedUrl})
      : _urlHealthStatus = urlHealthStatus,
        _selectedUrl = selectedUrl;

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
      final updatedHealthStatus = await healthCheck(healthStatus.url);
      updatedList.add(updatedHealthStatus);
    }
    return BiocentralAPI._(
        fixedURL: fixedURL,
        apiToken: apiToken,
        localOnly: localOnly,
        urlHealthStatus: updatedList,
        selectedUrl: _selectedUrl);
  }

  List<BiocentralAPIHealth> getHealthStatus() {
    return List.from(_urlHealthStatus);
  }

  String? get activeUrl => _getAvailableURL();

  Future<BiocentralAPI> withUrl(String url) async {
    if (fixedURL != null || _urlHealthStatus.any((healthStatus) => healthStatus.url == url)) {
      return this;
    }
    final newHealthStatus = await healthCheck(url);
    return BiocentralAPI._(
        fixedURL: fixedURL,
        apiToken: apiToken,
        localOnly: localOnly,
        urlHealthStatus: [..._urlHealthStatus, newHealthStatus],
        selectedUrl: _selectedUrl);
  }

  BiocentralAPI withoutUrl(String url) {
    if (fixedURL != null) {
      return this;
    }
    return BiocentralAPI._(
        fixedURL: fixedURL,
        apiToken: apiToken,
        localOnly: localOnly,
        urlHealthStatus: _urlHealthStatus.where((healthStatus) => healthStatus.url != url).toList(),
        selectedUrl: _selectedUrl == url ? null : _selectedUrl);
  }

  Future<BiocentralAPI> withSelectedUrl(String? url) async {
    if (fixedURL != null) {
      return this;
    }
    if (url == null) {
      return BiocentralAPI._(
          fixedURL: fixedURL,
          apiToken: apiToken,
          localOnly: localOnly,
          urlHealthStatus: _urlHealthStatus,
          selectedUrl: null);
    }
    final withEntry = await withUrl(url);
    return BiocentralAPI._(
        fixedURL: fixedURL,
        apiToken: apiToken,
        localOnly: localOnly,
        urlHealthStatus: withEntry._urlHealthStatus,
        selectedUrl: url);
  }

  static Future<(BiocentralServiceStats?, ResearchStats?)?> getStats(String url) async {
    final api = gen.BiocentralApi(basePathOverride: url);
    final statsClient = StatsClient();

    try {
      final serviceStats = await statsClient.serviceStats(api: api);
      final researchStats = await statsClient.researchStats(api: api);
      return (serviceStats, researchStats);
    } catch (_) {
      return null;
    }
  }

  static Future<BiocentralAPIHealth> healthCheck(String url) async {
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
    if (_selectedUrl != null) {
      for (final healthStatus in _urlHealthStatus) {
        if (healthStatus.url == _selectedUrl && healthStatus.healthy) {
          return healthStatus.url;
        }
      }
    }
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

  Future<BiocentralServerTask<BiotrainerModelResult?>> train({
    required Map<String, dynamic> config,
    required List<SequenceData> trainingData,
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

  Future<BiocentralServerTask<ProjectionResult?>> project({
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

  Future<BiocentralServerTask<Map<String, List<String>>>> cluster({
    required Map<String, String> sequenceData,
    double sequenceIdentityThreshold = 0.3,
  }) async {
    return ProteinsClient().cluster(
      api: _getAPI(),
      sequenceData: sequenceData,
      sequenceIdentityThreshold: sequenceIdentityThreshold,
    );
  }
}

extension ActiveLearningAPI on BiocentralAPI {
  Future<BiocentralServerTask<ActiveLearningIterationResult>> activeLearningIteration({
    required ActiveLearningScreeningCampaignConfig campaignConfig,
    required ActiveLearningScreeningIterationConfig iterationConfig,
  }) async {
    return ActiveLearningClient()
        .activeLearningIteration(api: _getAPI(), campaignConfig: campaignConfig, iterationConfig: iterationConfig);
  }
}
