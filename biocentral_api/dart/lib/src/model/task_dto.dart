//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/prediction.dart';
import 'package:biocentral_api/src/model/output_data.dart';
import 'package:biocentral_api/src/model/task_status.dart';
import 'package:biocentral_api/src/model/auto_eval_progress.dart';
import 'package:biocentral_api/src/model/biotrainer_sequence_record.dart';
import 'package:built_value/json_object.dart';
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
/// * [embeddingCurrent] 
/// * [embeddingTotal] 
/// * [embeddedSequences] 
/// * [embeddings] 
/// * [embeddingsFile] 
/// * [embedderName] 
/// * [autoevalProgress] 
/// * [bayOptResults] 
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
  OutputData? get biotrainerUpdate;

  @BuiltValueField(wireName: r'biotrainer_result')
  BuiltMap<String, JsonObject?>? get biotrainerResult;

  @BuiltValueField(wireName: r'embedding_current')
  int? get embeddingCurrent;

  @BuiltValueField(wireName: r'embedding_total')
  int? get embeddingTotal;

  @BuiltValueField(wireName: r'embedded_sequences')
  BuiltMap<String, String>? get embeddedSequences;

  @BuiltValueField(wireName: r'embeddings')
  BuiltList<BiotrainerSequenceRecord>? get embeddings;

  @BuiltValueField(wireName: r'embeddings_file')
  String? get embeddingsFile;

  @BuiltValueField(wireName: r'embedder_name')
  String? get embedderName;

  @BuiltValueField(wireName: r'autoeval_progress')
  AutoEvalProgress? get autoevalProgress;

  @BuiltValueField(wireName: r'bay_opt_results')
  BuiltList<JsonObject?>? get bayOptResults;

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
        specifiedType: const FullType.nullable(OutputData),
      );
    }
    if (object.biotrainerResult != null) {
      yield r'biotrainer_result';
      yield serializers.serialize(
        object.biotrainerResult,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.embeddingCurrent != null) {
      yield r'embedding_current';
      yield serializers.serialize(
        object.embeddingCurrent,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.embeddingTotal != null) {
      yield r'embedding_total';
      yield serializers.serialize(
        object.embeddingTotal,
        specifiedType: const FullType.nullable(int),
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
        specifiedType: const FullType.nullable(BuiltList, [FullType(BiotrainerSequenceRecord)]),
      );
    }
    if (object.embeddingsFile != null) {
      yield r'embeddings_file';
      yield serializers.serialize(
        object.embeddingsFile,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.embedderName != null) {
      yield r'embedder_name';
      yield serializers.serialize(
        object.embedderName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.autoevalProgress != null) {
      yield r'autoeval_progress';
      yield serializers.serialize(
        object.autoevalProgress,
        specifiedType: const FullType.nullable(AutoEvalProgress),
      );
    }
    if (object.bayOptResults != null) {
      yield r'bay_opt_results';
      yield serializers.serialize(
        object.bayOptResults,
        specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
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
            specifiedType: const FullType.nullable(OutputData),
          ) as OutputData?;
          if (valueDes == null) continue;
          result.biotrainerUpdate.replace(valueDes);
          break;
        case r'biotrainer_result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.biotrainerResult.replace(valueDes);
          break;
        case r'embedding_current':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.embeddingCurrent = valueDes;
          break;
        case r'embedding_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.embeddingTotal = valueDes;
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
            specifiedType: const FullType.nullable(BuiltList, [FullType(BiotrainerSequenceRecord)]),
          ) as BuiltList<BiotrainerSequenceRecord>?;
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
        case r'embedder_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.embedderName = valueDes;
          break;
        case r'autoeval_progress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AutoEvalProgress),
          ) as AutoEvalProgress?;
          if (valueDes == null) continue;
          result.autoevalProgress.replace(valueDes);
          break;
        case r'bay_opt_results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>?;
          if (valueDes == null) continue;
          result.bayOptResults.replace(valueDes);
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

