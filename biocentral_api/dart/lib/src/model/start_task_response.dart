//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'start_task_response.g.dart';

/// Response model for job submission
///
/// Properties:
/// * [taskId] - Unique task identifier for tracking the computation job
@BuiltValue()
abstract class StartTaskResponse implements Built<StartTaskResponse, StartTaskResponseBuilder> {
  /// Unique task identifier for tracking the computation job
  @BuiltValueField(wireName: r'task_id')
  String get taskId;

  StartTaskResponse._();

  factory StartTaskResponse([void updates(StartTaskResponseBuilder b)]) = _$StartTaskResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StartTaskResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StartTaskResponse> get serializer => _$StartTaskResponseSerializer();
}

class _$StartTaskResponseSerializer implements PrimitiveSerializer<StartTaskResponse> {
  @override
  final Iterable<Type> types = const [StartTaskResponse, _$StartTaskResponse];

  @override
  final String wireName = r'StartTaskResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StartTaskResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'task_id';
    yield serializers.serialize(
      object.taskId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StartTaskResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StartTaskResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'task_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.taskId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StartTaskResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StartTaskResponseBuilder();
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

