//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:biocentral_api/src/serializers.dart';
import 'package:biocentral_api/src/auth/api_key_auth.dart';
import 'package:biocentral_api/src/auth/basic_auth.dart';
import 'package:biocentral_api/src/auth/bearer_auth.dart';
import 'package:biocentral_api/src/auth/oauth.dart';
import 'package:biocentral_api/src/api/bayesian_optimization_api.dart';
import 'package:biocentral_api/src/api/biocentral_api.dart' as endpoint;
import 'package:biocentral_api/src/api/custom_models_api.dart';
import 'package:biocentral_api/src/api/default_api.dart';
import 'package:biocentral_api/src/api/embeddings_api.dart';
import 'package:biocentral_api/src/api/plm_eval_api.dart';
import 'package:biocentral_api/src/api/ppi_api.dart';
import 'package:biocentral_api/src/api/prediction_api.dart';
import 'package:biocentral_api/src/api/proteins_api.dart';

class BiocentralApi {
  static const String basePath = r'http://localhost';

  final Dio dio;
  final Serializers serializers;

  BiocentralApi({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : this.serializers = serializers ?? standardSerializers,
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Get BayesianOptimizationApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BayesianOptimizationApi getBayesianOptimizationApi() {
    return BayesianOptimizationApi(dio, serializers);
  }

  /// Get BiocentralApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  endpoint.BiocentralApi getBiocentralApi() {
    return endpoint.BiocentralApi(dio, serializers);
  }

  /// Get CustomModelsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CustomModelsApi getCustomModelsApi() {
    return CustomModelsApi(dio, serializers);
  }

  /// Get DefaultApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DefaultApi getDefaultApi() {
    return DefaultApi(dio, serializers);
  }

  /// Get EmbeddingsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  EmbeddingsApi getEmbeddingsApi() {
    return EmbeddingsApi(dio, serializers);
  }

  /// Get PlmEvalApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PlmEvalApi getPlmEvalApi() {
    return PlmEvalApi(dio, serializers);
  }

  /// Get PpiApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PpiApi getPpiApi() {
    return PpiApi(dio, serializers);
  }

  /// Get PredictionApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PredictionApi getPredictionApi() {
    return PredictionApi(dio, serializers);
  }

  /// Get ProteinsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ProteinsApi getProteinsApi() {
    return ProteinsApi(dio, serializers);
  }
}
