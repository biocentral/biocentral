//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/biotrainer_prediction.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'biotrainer_inference_result.g.dart';

/// BiotrainerInferenceResult
///
/// Properties:
/// * [predictions] - List of predictions
/// * [metrics] - Metrics
@BuiltValue()
abstract class BiotrainerInferenceResult implements Built<BiotrainerInferenceResult, BiotrainerInferenceResultBuilder> {
  /// List of predictions
  @BuiltValueField(wireName: r'predictions')
  BuiltList<BiotrainerPrediction> get predictions;

  /// Metrics
  @BuiltValueField(wireName: r'metrics')
  BuiltMap<String, num>? get metrics;

  BiotrainerInferenceResult._();

  factory BiotrainerInferenceResult([void updates(BiotrainerInferenceResultBuilder b)]) = _$BiotrainerInferenceResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BiotrainerInferenceResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BiotrainerInferenceResult> get serializer => _$BiotrainerInferenceResultSerializer();
}

class _$BiotrainerInferenceResultSerializer implements PrimitiveSerializer<BiotrainerInferenceResult> {
  @override
  final Iterable<Type> types = const [BiotrainerInferenceResult, _$BiotrainerInferenceResult];

  @override
  final String wireName = r'BiotrainerInferenceResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BiotrainerInferenceResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'predictions';
    yield serializers.serialize(
      object.predictions,
      specifiedType: const FullType(BuiltList, [FullType(BiotrainerPrediction)]),
    );
    if (object.metrics != null) {
      yield r'metrics';
      yield serializers.serialize(
        object.metrics,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(num)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BiotrainerInferenceResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BiotrainerInferenceResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'predictions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BiotrainerPrediction)]),
          ) as BuiltList<BiotrainerPrediction>;
          result.predictions.replace(valueDes);
          break;
        case r'metrics':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(num)]),
          ) as BuiltMap<String, num>?;
          if (valueDes == null) continue;
          result.metrics.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BiotrainerInferenceResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BiotrainerInferenceResultBuilder();
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
