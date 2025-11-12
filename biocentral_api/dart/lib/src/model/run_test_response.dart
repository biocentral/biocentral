//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/test_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_test_response.g.dart';

/// RunTestResponse
///
/// Properties:
/// * [testResult] 
@BuiltValue()
abstract class RunTestResponse implements Built<RunTestResponse, RunTestResponseBuilder> {
  @BuiltValueField(wireName: r'test_result')
  TestResult get testResult;

  RunTestResponse._();

  factory RunTestResponse([void updates(RunTestResponseBuilder b)]) = _$RunTestResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunTestResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RunTestResponse> get serializer => _$RunTestResponseSerializer();
}

class _$RunTestResponseSerializer implements PrimitiveSerializer<RunTestResponse> {
  @override
  final Iterable<Type> types = const [RunTestResponse, _$RunTestResponse];

  @override
  final String wireName = r'RunTestResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RunTestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'test_result';
    yield serializers.serialize(
      object.testResult,
      specifiedType: const FullType(TestResult),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RunTestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RunTestResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'test_result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TestResult),
          ) as TestResult;
          result.testResult.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RunTestResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RunTestResponseBuilder();
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

