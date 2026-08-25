//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/biotrainer_model_result.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'biotrainer_model_update.g.dart';

/// BiotrainerModelUpdate
///
/// Properties:
/// * [currentModelResult] - Current model result
/// * [trainingIteration] - Current training iteration for fast updates of observers like tensorboard
@BuiltValue()
abstract class BiotrainerModelUpdate implements Built<BiotrainerModelUpdate, BiotrainerModelUpdateBuilder> {
  /// Current model result
  @BuiltValueField(wireName: r'current_model_result')
  BiotrainerModelResult get currentModelResult;

  /// Current training iteration for fast updates of observers like tensorboard
  @BuiltValueField(wireName: r'training_iteration')
  BuiltList<JsonObject?>? get trainingIteration;

  BiotrainerModelUpdate._();

  factory BiotrainerModelUpdate([void updates(BiotrainerModelUpdateBuilder b)]) = _$BiotrainerModelUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BiotrainerModelUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BiotrainerModelUpdate> get serializer => _$BiotrainerModelUpdateSerializer();
}

class _$BiotrainerModelUpdateSerializer implements PrimitiveSerializer<BiotrainerModelUpdate> {
  @override
  final Iterable<Type> types = const [BiotrainerModelUpdate, _$BiotrainerModelUpdate];

  @override
  final String wireName = r'BiotrainerModelUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BiotrainerModelUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'current_model_result';
    yield serializers.serialize(
      object.currentModelResult,
      specifiedType: const FullType(BiotrainerModelResult),
    );
    if (object.trainingIteration != null) {
      yield r'training_iteration';
      yield serializers.serialize(
        object.trainingIteration,
        specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BiotrainerModelUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BiotrainerModelUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current_model_result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BiotrainerModelResult),
          ) as BiotrainerModelResult;
          result.currentModelResult.replace(valueDes);
          break;
        case r'training_iteration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>?;
          if (valueDes == null) continue;
          result.trainingIteration.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BiotrainerModelUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BiotrainerModelUpdateBuilder();
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

