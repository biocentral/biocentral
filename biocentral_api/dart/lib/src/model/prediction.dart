//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';

part 'prediction.g.dart';

/// Base class for all model predictions.
///
/// Properties:
/// * [modelName] - Name of the model
/// * [predictionName] - Name of the prediction
/// * [protocol] - Protocol name
/// * [value] 
/// * [valueLower] 
/// * [valueUpper] 
@BuiltValue()
abstract class Prediction implements Built<Prediction, PredictionBuilder> {
  /// Name of the model
  @BuiltValueField(wireName: r'model_name')
  String get modelName;

  /// Name of the prediction
  @BuiltValueField(wireName: r'prediction_name')
  String get predictionName;

  /// Protocol name
  @BuiltValueField(wireName: r'protocol')
  String get protocol;

  @BuiltValueField(wireName: r'value')
  JsonObject? get value;

  @BuiltValueField(wireName: r'value_lower')
  num? get valueLower;

  @BuiltValueField(wireName: r'value_upper')
  num? get valueUpper;

  Prediction._();

  factory Prediction([void updates(PredictionBuilder b)]) = _$Prediction;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PredictionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Prediction> get serializer => _$PredictionSerializer();
}

class _$PredictionSerializer implements PrimitiveSerializer<Prediction> {
  @override
  final Iterable<Type> types = const [Prediction, _$Prediction];

  @override
  final String wireName = r'Prediction';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Prediction object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'model_name';
    yield serializers.serialize(
      object.modelName,
      specifiedType: const FullType(String),
    );
    yield r'prediction_name';
    yield serializers.serialize(
      object.predictionName,
      specifiedType: const FullType(String),
    );
    yield r'protocol';
    yield serializers.serialize(
      object.protocol,
      specifiedType: const FullType(String),
    );
    yield r'value';
    yield object.value == null ? null : serializers.serialize(
      object.value,
      specifiedType: const FullType.nullable(JsonObject),
    );
    if (object.valueLower != null) {
      yield r'value_lower';
      yield serializers.serialize(
        object.valueLower,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.valueUpper != null) {
      yield r'value_upper';
      yield serializers.serialize(
        object.valueUpper,
        specifiedType: const FullType.nullable(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Prediction object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PredictionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'model_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.modelName = valueDes;
          break;
        case r'prediction_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.predictionName = valueDes;
          break;
        case r'protocol':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.protocol = valueDes;
          break;
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.value = valueDes;
          break;
        case r'value_lower':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.valueLower = valueDes;
          break;
        case r'value_upper':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.valueUpper = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Prediction deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PredictionBuilder();
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

