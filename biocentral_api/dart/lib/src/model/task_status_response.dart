//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/task_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'task_status_response.g.dart';

/// TaskStatusResponse
///
/// Properties:
/// * [dtos] - List of task DTOs generated during task execution since last request for the given task id
@BuiltValue()
abstract class TaskStatusResponse implements Built<TaskStatusResponse, TaskStatusResponseBuilder> {
  /// List of task DTOs generated during task execution since last request for the given task id
  @BuiltValueField(wireName: r'dtos')
  BuiltList<TaskDTO> get dtos;

  TaskStatusResponse._();

  factory TaskStatusResponse([void updates(TaskStatusResponseBuilder b)]) = _$TaskStatusResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaskStatusResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaskStatusResponse> get serializer => _$TaskStatusResponseSerializer();
}

class _$TaskStatusResponseSerializer implements PrimitiveSerializer<TaskStatusResponse> {
  @override
  final Iterable<Type> types = const [TaskStatusResponse, _$TaskStatusResponse];

  @override
  final String wireName = r'TaskStatusResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaskStatusResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'dtos';
    yield serializers.serialize(
      object.dtos,
      specifiedType: const FullType(BuiltList, [FullType(TaskDTO)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TaskStatusResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TaskStatusResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dtos':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TaskDTO)]),
          ) as BuiltList<TaskDTO>;
          result.dtos.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TaskStatusResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaskStatusResponseBuilder();
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

