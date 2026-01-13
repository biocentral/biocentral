//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_result.g.dart';

/// ActiveLearningResult
///
/// Properties:
/// * [entityId] - Entity identifier
/// * [prediction] - Predicted value
/// * [uncertainty] - Uncertainty of the prediction
/// * [score] - Score of the entity for using it for the next iteration
@BuiltValue()
abstract class ActiveLearningResult implements Built<ActiveLearningResult, ActiveLearningResultBuilder> {
  /// Entity identifier
  @BuiltValueField(wireName: r'entity_id')
  String get entityId;

  /// Predicted value
  @BuiltValueField(wireName: r'prediction')
  num get prediction;

  /// Uncertainty of the prediction
  @BuiltValueField(wireName: r'uncertainty')
  num get uncertainty;

  /// Score of the entity for using it for the next iteration
  @BuiltValueField(wireName: r'score')
  num get score;

  ActiveLearningResult._();

  factory ActiveLearningResult([void updates(ActiveLearningResultBuilder b)]) = _$ActiveLearningResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningResult> get serializer => _$ActiveLearningResultSerializer();
}

class _$ActiveLearningResultSerializer implements PrimitiveSerializer<ActiveLearningResult> {
  @override
  final Iterable<Type> types = const [ActiveLearningResult, _$ActiveLearningResult];

  @override
  final String wireName = r'ActiveLearningResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'entity_id';
    yield serializers.serialize(
      object.entityId,
      specifiedType: const FullType(String),
    );
    yield r'prediction';
    yield serializers.serialize(
      object.prediction,
      specifiedType: const FullType(num),
    );
    yield r'uncertainty';
    yield serializers.serialize(
      object.uncertainty,
      specifiedType: const FullType(num),
    );
    yield r'score';
    yield serializers.serialize(
      object.score,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'entity_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.entityId = valueDes;
          break;
        case r'prediction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.prediction = valueDes;
          break;
        case r'uncertainty':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.uncertainty = valueDes;
          break;
        case r'score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.score = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningResultBuilder();
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

