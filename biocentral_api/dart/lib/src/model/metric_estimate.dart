//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'metric_estimate.g.dart';

/// MetricEstimate
///
/// Properties:
/// * [name] - Name of the metric
/// * [mean] - Mean of the metric values
/// * [lower] - Lower bound of the metric values
/// * [upper] - Upper bound of the metric values
@BuiltValue()
abstract class MetricEstimate implements Built<MetricEstimate, MetricEstimateBuilder> {
  /// Name of the metric
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Mean of the metric values
  @BuiltValueField(wireName: r'mean')
  num get mean;

  /// Lower bound of the metric values
  @BuiltValueField(wireName: r'lower')
  num get lower;

  /// Upper bound of the metric values
  @BuiltValueField(wireName: r'upper')
  num get upper;

  MetricEstimate._();

  factory MetricEstimate([void updates(MetricEstimateBuilder b)]) = _$MetricEstimate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MetricEstimateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MetricEstimate> get serializer => _$MetricEstimateSerializer();
}

class _$MetricEstimateSerializer implements PrimitiveSerializer<MetricEstimate> {
  @override
  final Iterable<Type> types = const [MetricEstimate, _$MetricEstimate];

  @override
  final String wireName = r'MetricEstimate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MetricEstimate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'mean';
    yield serializers.serialize(
      object.mean,
      specifiedType: const FullType(num),
    );
    yield r'lower';
    yield serializers.serialize(
      object.lower,
      specifiedType: const FullType(num),
    );
    yield r'upper';
    yield serializers.serialize(
      object.upper,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MetricEstimate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MetricEstimateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'mean':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.mean = valueDes;
          break;
        case r'lower':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lower = valueDes;
          break;
        case r'upper':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.upper = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MetricEstimate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MetricEstimateBuilder();
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

