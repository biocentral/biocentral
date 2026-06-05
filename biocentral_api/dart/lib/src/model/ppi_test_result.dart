//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ppi_test_result.g.dart';

/// PPITestResult
///
/// Properties:
/// * [success] 
/// * [information] 
/// * [testMetrics] 
/// * [testStatistic] 
/// * [pValue] 
/// * [significanceLevel] 
@BuiltValue()
abstract class PPITestResult implements Built<PPITestResult, PPITestResultBuilder> {
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

  PPITestResult._();

  factory PPITestResult([void updates(PPITestResultBuilder b)]) = _$PPITestResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PPITestResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PPITestResult> get serializer => _$PPITestResultSerializer();
}

class _$PPITestResultSerializer implements PrimitiveSerializer<PPITestResult> {
  @override
  final Iterable<Type> types = const [PPITestResult, _$PPITestResult];

  @override
  final String wireName = r'PPITestResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PPITestResult object, {
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
    PPITestResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PPITestResultBuilder result,
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
  PPITestResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PPITestResultBuilder();
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

