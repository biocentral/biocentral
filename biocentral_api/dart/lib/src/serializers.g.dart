// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(AddEmbeddingsRequest.serializer)
      ..add(AddEmbeddingsResponse.serializer)
      ..add(AutoDetectFormatRequest.serializer)
      ..add(AutoEvalProgress.serializer)
      ..add(BayesianOptimizationRequest.serializer)
      ..add(BiocentralServerCustomModelsEndpointModelsErrorResponse.serializer)
      ..add(
          BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse
              .serializer)
      ..add(BiotrainerSequenceRecord.serializer)
      ..add(ConfigOptionsResponse.serializer)
      ..add(ConfigVerificationRequest.serializer)
      ..add(ConfigVerificationResponse.serializer)
      ..add(DetectedFormatResponse.serializer)
      ..add(EmbedRequest.serializer)
      ..add(EpochMetrics.serializer)
      ..add(GetMissingEmbeddingsRequest.serializer)
      ..add(GetMissingEmbeddingsResponse.serializer)
      ..add(HTTPValidationError.serializer)
      ..add(ImportDatasetRequest.serializer)
      ..add(ImportDatasetResponse.serializer)
      ..add(ModelFilesRequest.serializer)
      ..add(ModelMetadataResponse.serializer)
      ..add(NotFoundErrorResponse.serializer)
      ..add(OutputData.serializer)
      ..add(PLMEvalAutoevalRequest.serializer)
      ..add(PLMEvalInformation.serializer)
      ..add(PLMEvalInformationResponse.serializer)
      ..add(PLMEvalTaskInformation.serializer)
      ..add(PLMEvalValidateRequest.serializer)
      ..add(PLMEvalValidateResponse.serializer)
      ..add(Prediction.serializer)
      ..add(PredictionRequest.serializer)
      ..add(ProtocolsResponse.serializer)
      ..add(RunTestRequest.serializer)
      ..add(RunTestResponse.serializer)
      ..add(SequenceTrainingData.serializer)
      ..add(StartInferenceRequest.serializer)
      ..add(StartTaskResponse.serializer)
      ..add(StartTrainingRequest.serializer)
      ..add(TaskDTO.serializer)
      ..add(TaskStatus.serializer)
      ..add(TaskStatusResponse.serializer)
      ..add(TaxonomyItem.serializer)
      ..add(TaxonomyRequest.serializer)
      ..add(TaxonomyResponse.serializer)
      ..add(TestResult.serializer)
      ..add(ValidationError.serializer)
      ..add(ValidationErrorLocInner.serializer)
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(PLMEvalTaskInformation)]),
          () => ListBuilder<PLMEvalTaskInformation>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TaskDTO)]),
          () => ListBuilder<TaskDTO>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TaxonomyItem)]),
          () => ListBuilder<TaxonomyItem>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ValidationError)]),
          () => ListBuilder<ValidationError>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(ValidationErrorLocInner)]),
          () => ListBuilder<ValidationErrorLocInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType.nullable(JsonObject)]),
          () => ListBuilder<JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType(BuiltList, const [const FullType(Prediction)])
          ]),
          () => MapBuilder<String, BuiltList<Prediction>>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(BiotrainerSequenceRecord)]),
          () => ListBuilder<BiotrainerSequenceRecord>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType.nullable(JsonObject)]),
          () => ListBuilder<JsonObject?>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(SequenceTrainingData)]),
          () => ListBuilder<SequenceTrainingData>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType.nullable(JsonObject)]),
          () => ListBuilder<JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap,
              const [const FullType(dynamic), const FullType(dynamic)]),
          () => MapBuilder<dynamic, dynamic>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
