//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:biocentral_api/src/date_serializer.dart';
import 'package:biocentral_api/src/model/date.dart';

import 'package:biocentral_api/src/model/active_learning_convergence_config.dart';
import 'package:biocentral_api/src/model/active_learning_engineering_campaign_config.dart';
import 'package:biocentral_api/src/model/active_learning_engineering_iteration_config.dart';
import 'package:biocentral_api/src/model/active_learning_engineering_iteration_request.dart';
import 'package:biocentral_api/src/model/active_learning_iteration_result.dart';
import 'package:biocentral_api/src/model/active_learning_model_type.dart';
import 'package:biocentral_api/src/model/active_learning_optimization_mode.dart';
import 'package:biocentral_api/src/model/active_learning_result.dart';
import 'package:biocentral_api/src/model/active_learning_screening_campaign_config.dart';
import 'package:biocentral_api/src/model/active_learning_screening_iteration_config.dart';
import 'package:biocentral_api/src/model/active_learning_screening_iteration_request.dart';
import 'package:biocentral_api/src/model/active_learning_screening_simulation_config.dart';
import 'package:biocentral_api/src/model/active_learning_screening_simulation_request.dart';
import 'package:biocentral_api/src/model/active_learning_screening_simulation_result.dart';
import 'package:biocentral_api/src/model/add_embeddings_request.dart';
import 'package:biocentral_api/src/model/add_embeddings_response.dart';
import 'package:biocentral_api/src/model/auto_detect_format_request.dart';
import 'package:biocentral_api/src/model/biocentral_prediction_model.dart';
import 'package:biocentral_api/src/model/biocentral_server_custom_models_endpoint_models_error_response.dart';
import 'package:biocentral_api/src/model/biocentral_server_server_management_shared_endpoint_models_error_models_error_response.dart';
import 'package:biocentral_api/src/model/biocentral_service_stats.dart';
import 'package:biocentral_api/src/model/biotrainer_inference_result.dart';
import 'package:biocentral_api/src/model/biotrainer_model_result.dart';
import 'package:biocentral_api/src/model/biotrainer_model_update.dart';
import 'package:biocentral_api/src/model/biotrainer_prediction.dart';
import 'package:biocentral_api/src/model/bootstrapped_metric.dart';
import 'package:biocentral_api/src/model/clustering_request.dart';
import 'package:biocentral_api/src/model/common_embedder.dart';
import 'package:biocentral_api/src/model/config_options_response.dart';
import 'package:biocentral_api/src/model/config_verification_request.dart';
import 'package:biocentral_api/src/model/config_verification_response.dart';
import 'package:biocentral_api/src/model/derived_values.dart';
import 'package:biocentral_api/src/model/detected_format_response.dart';
import 'package:biocentral_api/src/model/embed_request.dart';
import 'package:biocentral_api/src/model/embedding_progress.dart';
import 'package:biocentral_api/src/model/embedding_stats.dart';
import 'package:biocentral_api/src/model/epoch_metrics.dart';
import 'package:biocentral_api/src/model/get_missing_embeddings_request.dart';
import 'package:biocentral_api/src/model/get_missing_embeddings_response.dart';
import 'package:biocentral_api/src/model/get_projection_config_response.dart';
import 'package:biocentral_api/src/model/http_validation_error.dart';
import 'package:biocentral_api/src/model/import_dataset_request.dart';
import 'package:biocentral_api/src/model/import_dataset_response.dart';
import 'package:biocentral_api/src/model/location_inner.dart';
import 'package:biocentral_api/src/model/mcd_lower_bound.dart';
import 'package:biocentral_api/src/model/mcd_mean.dart';
import 'package:biocentral_api/src/model/mcd_std.dart';
import 'package:biocentral_api/src/model/mcd_upper_bound.dart';
import 'package:biocentral_api/src/model/model_files_request.dart';
import 'package:biocentral_api/src/model/model_metadata.dart';
import 'package:biocentral_api/src/model/model_metadata_response.dart';
import 'package:biocentral_api/src/model/model_output.dart';
import 'package:biocentral_api/src/model/not_found_error_response.dart';
import 'package:biocentral_api/src/model/output_class.dart';
import 'package:biocentral_api/src/model/output_type.dart';
import 'package:biocentral_api/src/model/ppi_test_result.dart';
import 'package:biocentral_api/src/model/prediction.dart';
import 'package:biocentral_api/src/model/prediction1.dart';
import 'package:biocentral_api/src/model/prediction_request.dart';
import 'package:biocentral_api/src/model/projection_request.dart';
import 'package:biocentral_api/src/model/projection_result.dart';
import 'package:biocentral_api/src/model/projections_data.dart';
import 'package:biocentral_api/src/model/projections_metadata.dart';
import 'package:biocentral_api/src/model/protein_annotations.dart';
import 'package:biocentral_api/src/model/protocol.dart';
import 'package:biocentral_api/src/model/raw_prediction.dart';
import 'package:biocentral_api/src/model/research_stats.dart';
import 'package:biocentral_api/src/model/research_stats_response.dart';
import 'package:biocentral_api/src/model/run_test_request.dart';
import 'package:biocentral_api/src/model/run_test_response.dart';
import 'package:biocentral_api/src/model/sequence_data.dart';
import 'package:biocentral_api/src/model/service_stats_response.dart';
import 'package:biocentral_api/src/model/start_inference_request.dart';
import 'package:biocentral_api/src/model/start_task_response.dart';
import 'package:biocentral_api/src/model/start_training_request.dart';
import 'package:biocentral_api/src/model/task_dto.dart';
import 'package:biocentral_api/src/model/task_status.dart';
import 'package:biocentral_api/src/model/task_status_response.dart';
import 'package:biocentral_api/src/model/taxonomy_item.dart';
import 'package:biocentral_api/src/model/taxonomy_request.dart';
import 'package:biocentral_api/src/model/taxonomy_response.dart';
import 'package:biocentral_api/src/model/test_result.dart';
import 'package:biocentral_api/src/model/training_result.dart';
import 'package:biocentral_api/src/model/validation_error.dart';

part 'serializers.g.dart';

@SerializersFor([
  ActiveLearningConvergenceConfig,
  ActiveLearningEngineeringCampaignConfig,
  ActiveLearningEngineeringIterationConfig,
  ActiveLearningEngineeringIterationRequest,
  ActiveLearningIterationResult,
  ActiveLearningModelType,
  ActiveLearningOptimizationMode,
  ActiveLearningResult,
  ActiveLearningScreeningCampaignConfig,
  ActiveLearningScreeningIterationConfig,
  ActiveLearningScreeningIterationRequest,
  ActiveLearningScreeningSimulationConfig,
  ActiveLearningScreeningSimulationRequest,
  ActiveLearningScreeningSimulationResult,
  AddEmbeddingsRequest,
  AddEmbeddingsResponse,
  AutoDetectFormatRequest,
  BiocentralPredictionModel,
  BiocentralServerCustomModelsEndpointModelsErrorResponse,
  BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse,
  BiocentralServiceStats,
  BiotrainerInferenceResult,
  BiotrainerModelResult,
  BiotrainerModelUpdate,
  BiotrainerPrediction,
  BootstrappedMetric,
  ClusteringRequest,
  CommonEmbedder,
  ConfigOptionsResponse,
  ConfigVerificationRequest,
  ConfigVerificationResponse,
  DerivedValues,
  DetectedFormatResponse,
  EmbedRequest,
  EmbeddingProgress,
  EmbeddingStats,
  EpochMetrics,
  GetMissingEmbeddingsRequest,
  GetMissingEmbeddingsResponse,
  GetProjectionConfigResponse,
  HTTPValidationError,
  ImportDatasetRequest,
  ImportDatasetResponse,
  LocationInner,
  McdLowerBound,
  McdMean,
  McdStd,
  McdUpperBound,
  ModelFilesRequest,
  ModelMetadata,
  ModelMetadataResponse,
  ModelOutput,
  NotFoundErrorResponse,
  OutputClass,
  OutputType,
  PPITestResult,
  Prediction,
  Prediction1,
  PredictionRequest,
  ProjectionRequest,
  ProjectionResult,
  ProjectionsData,
  ProjectionsMetadata,
  ProteinAnnotations,
  Protocol,
  RawPrediction,
  ResearchStats,
  ResearchStatsResponse,
  RunTestRequest,
  RunTestResponse,
  SequenceData,
  ServiceStatsResponse,
  StartInferenceRequest,
  StartTaskResponse,
  StartTrainingRequest,
  TaskDTO,
  TaskStatus,
  TaskStatusResponse,
  TaxonomyItem,
  TaxonomyRequest,
  TaxonomyResponse,
  TestResult,
  TrainingResult,
  ValidationError,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(CommonEmbedder)]),
        () => ListBuilder<CommonEmbedder>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(JsonObject)]),
        () => MapBuilder<String, JsonObject>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
