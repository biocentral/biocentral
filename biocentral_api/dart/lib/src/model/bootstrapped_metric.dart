//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bootstrapped_metric.g.dart';

/// BootstrappedMetric
///
/// Properties:
/// * [name] - Name of the metric
/// * [mean] - Mean of the metric values
/// * [lower] - Lower bound of the metric values
/// * [upper] - Upper bound of the metric values
/// * [iterations] - Number of iterations used for bootstrapping
/// * [sampleSize] - Sample size used for bootstrapping
/// * [confidenceLevel] - Confidence level used for bootstrapping
@BuiltValue()
abstract class BootstrappedMetric implements Built<BootstrappedMetric, BootstrappedMetricBuilder> {
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

  /// Number of iterations used for bootstrapping
  @BuiltValueField(wireName: r'iterations')
  int get iterations;

  /// Sample size used for bootstrapping
  @BuiltValueField(wireName: r'sample_size')
  int get sampleSize;

  /// Confidence level used for bootstrapping
  @BuiltValueField(wireName: r'confidence_level')
  num get confidenceLevel;

  BootstrappedMetric._();

  factory BootstrappedMetric([void updates(BootstrappedMetricBuilder b)]) = _$BootstrappedMetric;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BootstrappedMetricBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BootstrappedMetric> get serializer => _$BootstrappedMetricSerializer();
}

class _$BootstrappedMetricSerializer implements PrimitiveSerializer<BootstrappedMetric> {
  @override
  final Iterable<Type> types = const [BootstrappedMetric, _$BootstrappedMetric];

  @override
  final String wireName = r'BootstrappedMetric';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BootstrappedMetric object, {
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
    yield r'iterations';
    yield serializers.serialize(
      object.iterations,
      specifiedType: const FullType(int),
    );
    yield r'sample_size';
    yield serializers.serialize(
      object.sampleSize,
      specifiedType: const FullType(int),
    );
    yield r'confidence_level';
    yield serializers.serialize(
      object.confidenceLevel,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BootstrappedMetric object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BootstrappedMetricBuilder result,
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
        case r'iterations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.iterations = valueDes;
          break;
        case r'sample_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sampleSize = valueDes;
          break;
        case r'confidence_level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.confidenceLevel = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BootstrappedMetric deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BootstrappedMetricBuilder();
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
