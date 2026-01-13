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

import 'package:biocentral_api/src/model/active_learning_campaign_config.dart';
import 'package:biocentral_api/src/model/active_learning_convergence_config.dart';
import 'package:biocentral_api/src/model/active_learning_iteration_config.dart';
import 'package:biocentral_api/src/model/active_learning_iteration_request.dart';
import 'package:biocentral_api/src/model/active_learning_iteration_result.dart';
import 'package:biocentral_api/src/model/active_learning_model_type.dart';
import 'package:biocentral_api/src/model/active_learning_optimization_mode.dart';
import 'package:biocentral_api/src/model/active_learning_result.dart';
import 'package:biocentral_api/src/model/active_learning_simulation_config.dart';
import 'package:biocentral_api/src/model/active_learning_simulation_request.dart';
import 'package:biocentral_api/src/model/active_learning_simulation_result.dart';
import 'package:biocentral_api/src/model/add_embeddings_request.dart';
import 'package:biocentral_api/src/model/add_embeddings_response.dart';
import 'package:biocentral_api/src/model/auto_detect_format_request.dart';
import 'package:biocentral_api/src/model/auto_eval_progress.dart';
import 'package:biocentral_api/src/model/auto_eval_report.dart';
import 'package:biocentral_api/src/model/biocentral_prediction_model.dart';
import 'package:biocentral_api/src/model/biocentral_server_custom_models_endpoint_models_error_response.dart';
import 'package:biocentral_api/src/model/biocentral_server_server_management_shared_endpoint_models_error_models_error_response.dart';
import 'package:biocentral_api/src/model/biotrainer_sequence_record.dart';
import 'package:biocentral_api/src/model/common_embedder.dart';
import 'package:biocentral_api/src/model/config_options_response.dart';
import 'package:biocentral_api/src/model/config_verification_request.dart';
import 'package:biocentral_api/src/model/config_verification_response.dart';
import 'package:biocentral_api/src/model/detected_format_response.dart';
import 'package:biocentral_api/src/model/embed_request.dart';
import 'package:biocentral_api/src/model/embedding_progress.dart';
import 'package:biocentral_api/src/model/epoch_metrics.dart';
import 'package:biocentral_api/src/model/get_missing_embeddings_request.dart';
import 'package:biocentral_api/src/model/get_missing_embeddings_response.dart';
import 'package:biocentral_api/src/model/get_projection_config_response.dart';
import 'package:biocentral_api/src/model/http_validation_error.dart';
import 'package:biocentral_api/src/model/import_dataset_request.dart';
import 'package:biocentral_api/src/model/import_dataset_response.dart';
import 'package:biocentral_api/src/model/model_files_request.dart';
import 'package:biocentral_api/src/model/model_metadata.dart';
import 'package:biocentral_api/src/model/model_metadata_response.dart';
import 'package:biocentral_api/src/model/model_output.dart';
import 'package:biocentral_api/src/model/not_found_error_response.dart';
import 'package:biocentral_api/src/model/output_class.dart';
import 'package:biocentral_api/src/model/output_data.dart';
import 'package:biocentral_api/src/model/output_type.dart';
import 'package:biocentral_api/src/model/plm_eval_autoeval_request.dart';
import 'package:biocentral_api/src/model/plm_eval_information.dart';
import 'package:biocentral_api/src/model/plm_eval_information_response.dart';
import 'package:biocentral_api/src/model/plm_eval_task_information.dart';
import 'package:biocentral_api/src/model/plm_eval_validate_request.dart';
import 'package:biocentral_api/src/model/plm_eval_validate_response.dart';
import 'package:biocentral_api/src/model/prediction.dart';
import 'package:biocentral_api/src/model/prediction_request.dart';
import 'package:biocentral_api/src/model/projection_request.dart';
import 'package:biocentral_api/src/model/protocol.dart';
import 'package:biocentral_api/src/model/run_test_request.dart';
import 'package:biocentral_api/src/model/run_test_response.dart';
import 'package:biocentral_api/src/model/sequence_training_data.dart';
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
import 'package:biocentral_api/src/model/validation_error.dart';
import 'package:biocentral_api/src/model/validation_error_loc_inner.dart';

part 'serializers.g.dart';

@SerializersFor([
  ActiveLearningCampaignConfig,
  ActiveLearningConvergenceConfig,
  ActiveLearningIterationConfig,
  ActiveLearningIterationRequest,
  ActiveLearningIterationResult,
  ActiveLearningModelType,
  ActiveLearningOptimizationMode,
  ActiveLearningResult,
  ActiveLearningSimulationConfig,
  ActiveLearningSimulationRequest,
  ActiveLearningSimulationResult,
  AddEmbeddingsRequest,
  AddEmbeddingsResponse,
  AutoDetectFormatRequest,
  AutoEvalProgress,
  AutoEvalReport,
  BiocentralPredictionModel,
  BiocentralServerCustomModelsEndpointModelsErrorResponse,
  BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse,
  BiotrainerSequenceRecord,
  CommonEmbedder,
  ConfigOptionsResponse,
  ConfigVerificationRequest,
  ConfigVerificationResponse,
  DetectedFormatResponse,
  EmbedRequest,
  EmbeddingProgress,
  EpochMetrics,
  GetMissingEmbeddingsRequest,
  GetMissingEmbeddingsResponse,
  GetProjectionConfigResponse,
  HTTPValidationError,
  ImportDatasetRequest,
  ImportDatasetResponse,
  ModelFilesRequest,
  ModelMetadata,
  ModelMetadataResponse,
  ModelOutput,
  NotFoundErrorResponse,
  OutputClass,
  OutputData,
  OutputType,
  PLMEvalAutoevalRequest,
  PLMEvalInformation,
  PLMEvalInformationResponse,
  PLMEvalTaskInformation,
  PLMEvalValidateRequest,
  PLMEvalValidateResponse,
  Prediction,
  PredictionRequest,
  ProjectionRequest,
  Protocol,
  RunTestRequest,
  RunTestResponse,
  SequenceTrainingData,
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
  ValidationError,
  ValidationErrorLocInner,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(CommonEmbedder)]),
        () => ListBuilder<CommonEmbedder>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
        () => MapBuilder<String, JsonObject>(),
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
