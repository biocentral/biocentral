//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';

part 'epoch_metrics.g.dart';

/// EpochMetrics
///
/// Properties:
/// * [epoch] 
/// * [training] 
/// * [validation] 
@BuiltValue()
abstract class EpochMetrics implements Built<EpochMetrics, EpochMetricsBuilder> {
  @BuiltValueField(wireName: r'epoch')
  int get epoch;

  @BuiltValueField(wireName: r'training')
  BuiltMap<String, JsonObject?> get training;

  @BuiltValueField(wireName: r'validation')
  BuiltMap<String, JsonObject?> get validation;

  EpochMetrics._();

  factory EpochMetrics([void updates(EpochMetricsBuilder b)]) = _$EpochMetrics;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EpochMetricsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EpochMetrics> get serializer => _$EpochMetricsSerializer();
}

class _$EpochMetricsSerializer implements PrimitiveSerializer<EpochMetrics> {
  @override
  final Iterable<Type> types = const [EpochMetrics, _$EpochMetrics];

  @override
  final String wireName = r'EpochMetrics';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EpochMetrics object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'epoch';
    yield serializers.serialize(
      object.epoch,
      specifiedType: const FullType(int),
    );
    yield r'training';
    yield serializers.serialize(
      object.training,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'validation';
    yield serializers.serialize(
      object.validation,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EpochMetrics object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EpochMetricsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'epoch':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.epoch = valueDes;
          break;
        case r'training':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.training.replace(valueDes);
          break;
        case r'validation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.validation.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EpochMetrics deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EpochMetricsBuilder();
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

