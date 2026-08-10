//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sequence_data.g.dart';

/// SequenceData
///
/// Properties:
/// * [seqId] - Sequence id
/// * [seq] - Sequence
/// * [label] - Shortcut for TARGET attribute
/// * [set_] - Shortcut for SET attribute
/// * [mask] - Shortcut for MASK attribute
/// * [attributes] - Attributes such as TARGET, SET or MASK
/// * [embedding] - Embedding (should be a list or torch.tensor or numpy array)
@BuiltValue()
abstract class SequenceData implements Built<SequenceData, SequenceDataBuilder> {
  /// Sequence id
  @BuiltValueField(wireName: r'seq_id')
  String get seqId;

  /// Sequence
  @BuiltValueField(wireName: r'seq')
  String get seq;

  /// Shortcut for TARGET attribute
  @BuiltValueField(wireName: r'label')
  String? get label;

  /// Shortcut for SET attribute
  @BuiltValueField(wireName: r'set')
  String? get set_;

  /// Shortcut for MASK attribute
  @BuiltValueField(wireName: r'mask')
  String? get mask;

  /// Attributes such as TARGET, SET or MASK
  @BuiltValueField(wireName: r'attributes')
  BuiltMap<String, JsonObject?>? get attributes;

  /// Embedding (should be a list or torch.tensor or numpy array)
  @BuiltValueField(wireName: r'embedding')
  BuiltList<JsonObject?>? get embedding;

  SequenceData._();

  factory SequenceData([void updates(SequenceDataBuilder b)]) = _$SequenceData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SequenceDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SequenceData> get serializer => _$SequenceDataSerializer();
}

class _$SequenceDataSerializer implements PrimitiveSerializer<SequenceData> {
  @override
  final Iterable<Type> types = const [SequenceData, _$SequenceData];

  @override
  final String wireName = r'SequenceData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SequenceData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'seq_id';
    yield serializers.serialize(
      object.seqId,
      specifiedType: const FullType(String),
    );
    yield r'seq';
    yield serializers.serialize(
      object.seq,
      specifiedType: const FullType(String),
    );
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.set_ != null) {
      yield r'set';
      yield serializers.serialize(
        object.set_,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.mask != null) {
      yield r'mask';
      yield serializers.serialize(
        object.mask,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.attributes != null) {
      yield r'attributes';
      yield serializers.serialize(
        object.attributes,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.embedding != null) {
      yield r'embedding';
      yield serializers.serialize(
        object.embedding,
        specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SequenceData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SequenceDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'seq_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.seqId = valueDes;
          break;
        case r'seq':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.seq = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'set':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.set_ = valueDes;
          break;
        case r'mask':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mask = valueDes;
          break;
        case r'attributes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.attributes.replace(valueDes);
          break;
        case r'embedding':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>?;
          if (valueDes == null) continue;
          result.embedding.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SequenceData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SequenceDataBuilder();
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
