//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/prediction.dart';
import 'package:biocentral_api/src/model/biotrainer_inference_result.dart';
import 'package:biocentral_api/src/model/biotrainer_model_result.dart';
import 'package:biocentral_api/src/model/embedding_progress.dart';
import 'package:biocentral_api/src/model/biotrainer_model_update.dart';
import 'package:biocentral_api/src/model/task_status.dart';
import 'package:biocentral_api/src/model/active_learning_iteration_result.dart';
import 'package:biocentral_api/src/model/active_learning_screening_simulation_result.dart';
import 'package:biocentral_api/src/model/sequence_data.dart';
import 'package:biocentral_api/src/model/projection_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'task_dto.g.dart';

/// TaskDTO
///
/// Properties:
/// * [status] 
/// * [error] 
/// * [predictions] 
/// * [biotrainerUpdate] 
/// * [biotrainerResult] 
/// * [biotrainerInferenceResult] 
/// * [embeddingProgress] 
/// * [embeddedSequences] 
/// * [embeddings] 
/// * [embeddingsFile] 
/// * [clusteredData] 
/// * [projectionResult] 
/// * [alIterationResult] 
/// * [alSimulationResult] 
@BuiltValue()
abstract class TaskDTO implements Built<TaskDTO, TaskDTOBuilder> {
  @BuiltValueField(wireName: r'status')
  TaskStatus get status;
  // enum statusEnum {  PENDING,  RUNNING,  FINISHED,  FAILED,  };

  @BuiltValueField(wireName: r'error')
  String? get error;

  @BuiltValueField(wireName: r'predictions')
  BuiltMap<String, BuiltList<Prediction>>? get predictions;

  @BuiltValueField(wireName: r'biotrainer_update')
  BiotrainerModelUpdate? get biotrainerUpdate;

  @BuiltValueField(wireName: r'biotrainer_result')
  BiotrainerModelResult? get biotrainerResult;

  @BuiltValueField(wireName: r'biotrainer_inference_result')
  BiotrainerInferenceResult? get biotrainerInferenceResult;

  @BuiltValueField(wireName: r'embedding_progress')
  EmbeddingProgress? get embeddingProgress;

  @BuiltValueField(wireName: r'embedded_sequences')
  BuiltMap<String, String>? get embeddedSequences;

  @BuiltValueField(wireName: r'embeddings')
  BuiltList<SequenceData>? get embeddings;

  @BuiltValueField(wireName: r'embeddings_file')
  String? get embeddingsFile;

  @BuiltValueField(wireName: r'clustered_data')
  BuiltMap<String, BuiltList<String>>? get clusteredData;

  @BuiltValueField(wireName: r'projection_result')
  ProjectionResult? get projectionResult;

  @BuiltValueField(wireName: r'al_iteration_result')
  ActiveLearningIterationResult? get alIterationResult;

  @BuiltValueField(wireName: r'al_simulation_result')
  ActiveLearningScreeningSimulationResult? get alSimulationResult;

  TaskDTO._();

  factory TaskDTO([void updates(TaskDTOBuilder b)]) = _$TaskDTO;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaskDTOBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaskDTO> get serializer => _$TaskDTOSerializer();
}

class _$TaskDTOSerializer implements PrimitiveSerializer<TaskDTO> {
  @override
  final Iterable<Type> types = const [TaskDTO, _$TaskDTO];

  @override
  final String wireName = r'TaskDTO';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaskDTO object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(TaskStatus),
    );
    if (object.error != null) {
      yield r'error';
      yield serializers.serialize(
        object.error,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.predictions != null) {
      yield r'predictions';
      yield serializers.serialize(
        object.predictions,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(BuiltList, [FullType(Prediction)])]),
      );
    }
    if (object.biotrainerUpdate != null) {
      yield r'biotrainer_update';
      yield serializers.serialize(
        object.biotrainerUpdate,
        specifiedType: const FullType.nullable(BiotrainerModelUpdate),
      );
    }
    if (object.biotrainerResult != null) {
      yield r'biotrainer_result';
      yield serializers.serialize(
        object.biotrainerResult,
        specifiedType: const FullType.nullable(BiotrainerModelResult),
      );
    }
    if (object.biotrainerInferenceResult != null) {
      yield r'biotrainer_inference_result';
      yield serializers.serialize(
        object.biotrainerInferenceResult,
        specifiedType: const FullType.nullable(BiotrainerInferenceResult),
      );
    }
    if (object.embeddingProgress != null) {
      yield r'embedding_progress';
      yield serializers.serialize(
        object.embeddingProgress,
        specifiedType: const FullType.nullable(EmbeddingProgress),
      );
    }
    if (object.embeddedSequences != null) {
      yield r'embedded_sequences';
      yield serializers.serialize(
        object.embeddedSequences,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(String)]),
      );
    }
    if (object.embeddings != null) {
      yield r'embeddings';
      yield serializers.serialize(
        object.embeddings,
        specifiedType: const FullType.nullable(BuiltList, [FullType(SequenceData)]),
      );
    }
    if (object.embeddingsFile != null) {
      yield r'embeddings_file';
      yield serializers.serialize(
        object.embeddingsFile,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.clusteredData != null) {
      yield r'clustered_data';
      yield serializers.serialize(
        object.clusteredData,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(BuiltList, [FullType(String)])]),
      );
    }
    if (object.projectionResult != null) {
      yield r'projection_result';
      yield serializers.serialize(
        object.projectionResult,
        specifiedType: const FullType.nullable(ProjectionResult),
      );
    }
    if (object.alIterationResult != null) {
      yield r'al_iteration_result';
      yield serializers.serialize(
        object.alIterationResult,
        specifiedType: const FullType.nullable(ActiveLearningIterationResult),
      );
    }
    if (object.alSimulationResult != null) {
      yield r'al_simulation_result';
      yield serializers.serialize(
        object.alSimulationResult,
        specifiedType: const FullType.nullable(ActiveLearningScreeningSimulationResult),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TaskDTO object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TaskDTOBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TaskStatus),
          ) as TaskStatus;
          result.status = valueDes;
          break;
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.error = valueDes;
          break;
        case r'predictions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(BuiltList, [FullType(Prediction)])]),
          ) as BuiltMap<String, BuiltList<Prediction>>?;
          if (valueDes == null) continue;
          result.predictions.replace(valueDes);
          break;
        case r'biotrainer_update':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BiotrainerModelUpdate),
          ) as BiotrainerModelUpdate?;
          if (valueDes == null) continue;
          result.biotrainerUpdate.replace(valueDes);
          break;
        case r'biotrainer_result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BiotrainerModelResult),
          ) as BiotrainerModelResult?;
          if (valueDes == null) continue;
          result.biotrainerResult.replace(valueDes);
          break;
        case r'biotrainer_inference_result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BiotrainerInferenceResult),
          ) as BiotrainerInferenceResult?;
          if (valueDes == null) continue;
          result.biotrainerInferenceResult.replace(valueDes);
          break;
        case r'embedding_progress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(EmbeddingProgress),
          ) as EmbeddingProgress?;
          if (valueDes == null) continue;
          result.embeddingProgress.replace(valueDes);
          break;
        case r'embedded_sequences':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>?;
          if (valueDes == null) continue;
          result.embeddedSequences.replace(valueDes);
          break;
        case r'embeddings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(SequenceData)]),
          ) as BuiltList<SequenceData>?;
          if (valueDes == null) continue;
          result.embeddings.replace(valueDes);
          break;
        case r'embeddings_file':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.embeddingsFile = valueDes;
          break;
        case r'clustered_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(BuiltList, [FullType(String)])]),
          ) as BuiltMap<String, BuiltList<String>>?;
          if (valueDes == null) continue;
          result.clusteredData.replace(valueDes);
          break;
        case r'projection_result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ProjectionResult),
          ) as ProjectionResult?;
          if (valueDes == null) continue;
          result.projectionResult.replace(valueDes);
          break;
        case r'al_iteration_result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ActiveLearningIterationResult),
          ) as ActiveLearningIterationResult?;
          if (valueDes == null) continue;
          result.alIterationResult.replace(valueDes);
          break;
        case r'al_simulation_result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ActiveLearningScreeningSimulationResult),
          ) as ActiveLearningScreeningSimulationResult?;
          if (valueDes == null) continue;
          result.alSimulationResult.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TaskDTO deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaskDTOBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

