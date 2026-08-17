//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_test_request.g.dart';

/// RunTestRequest
///
/// Properties:
/// * [hash] 
/// * [test] 
@BuiltValue()
abstract class RunTestRequest implements Built<RunTestRequest, RunTestRequestBuilder> {
  @BuiltValueField(wireName: r'hash')
  String get hash;

  @BuiltValueField(wireName: r'test')
  String get test;

  RunTestRequest._();

  factory RunTestRequest([void updates(RunTestRequestBuilder b)]) = _$RunTestRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunTestRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RunTestRequest> get serializer => _$RunTestRequestSerializer();
}

class _$RunTestRequestSerializer implements PrimitiveSerializer<RunTestRequest> {
  @override
  final Iterable<Type> types = const [RunTestRequest, _$RunTestRequest];

  @override
  final String wireName = r'RunTestRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RunTestRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'hash';
    yield serializers.serialize(
      object.hash,
      specifiedType: const FullType(String),
    );
    yield r'test';
    yield serializers.serialize(
      object.test,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RunTestRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RunTestRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.hash = valueDes;
          break;
        case r'test':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.test = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RunTestRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RunTestRequestBuilder();
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

