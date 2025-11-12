//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'test_result.g.dart';

/// TestResult
///
/// Properties:
/// * [success] 
/// * [information] 
/// * [testMetrics] 
/// * [testStatistic] 
/// * [pValue] 
/// * [significanceLevel] 
@BuiltValue()
abstract class TestResult implements Built<TestResult, TestResultBuilder> {
  @BuiltValueField(wireName: r'success')
  String get success;

  @BuiltValueField(wireName: r'information')
  String get information;

  @BuiltValueField(wireName: r'test_metrics')
  String get testMetrics;

  @BuiltValueField(wireName: r'test_statistic')
  String get testStatistic;

  @BuiltValueField(wireName: r'p_value')
  String get pValue;

  @BuiltValueField(wireName: r'significance_level')
  num? get significanceLevel;

  TestResult._();

  factory TestResult([void updates(TestResultBuilder b)]) = _$TestResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TestResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TestResult> get serializer => _$TestResultSerializer();
}

class _$TestResultSerializer implements PrimitiveSerializer<TestResult> {
  @override
  final Iterable<Type> types = const [TestResult, _$TestResult];

  @override
  final String wireName = r'TestResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TestResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'success';
    yield serializers.serialize(
      object.success,
      specifiedType: const FullType(String),
    );
    yield r'information';
    yield serializers.serialize(
      object.information,
      specifiedType: const FullType(String),
    );
    yield r'test_metrics';
    yield serializers.serialize(
      object.testMetrics,
      specifiedType: const FullType(String),
    );
    yield r'test_statistic';
    yield serializers.serialize(
      object.testStatistic,
      specifiedType: const FullType(String),
    );
    yield r'p_value';
    yield serializers.serialize(
      object.pValue,
      specifiedType: const FullType(String),
    );
    yield r'significance_level';
    yield object.significanceLevel == null ? null : serializers.serialize(
      object.significanceLevel,
      specifiedType: const FullType.nullable(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TestResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TestResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'success':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.success = valueDes;
          break;
        case r'information':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.information = valueDes;
          break;
        case r'test_metrics':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.testMetrics = valueDes;
          break;
        case r'test_statistic':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.testStatistic = valueDes;
          break;
        case r'p_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pValue = valueDes;
          break;
        case r'significance_level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.significanceLevel = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TestResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TestResultBuilder();
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

