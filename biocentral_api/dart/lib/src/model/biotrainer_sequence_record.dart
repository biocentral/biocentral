//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'biotrainer_sequence_record.g.dart';

/// BiotrainerSequenceRecord
///
/// Properties:
/// * [seqId] - Sequence id
/// * [seq] - Sequence
/// * [attributes] 
/// * [embedding] - Embedding
@BuiltValue()
abstract class BiotrainerSequenceRecord implements Built<BiotrainerSequenceRecord, BiotrainerSequenceRecordBuilder> {
  /// Sequence id
  @BuiltValueField(wireName: r'seq_id')
  String get seqId;

  /// Sequence
  @BuiltValueField(wireName: r'seq')
  String get seq;

  @BuiltValueField(wireName: r'attributes')
  BuiltMap<String, JsonObject?>? get attributes;

  /// Embedding
  @BuiltValueField(wireName: r'embedding')
  BuiltMap? get embedding;

  BiotrainerSequenceRecord._();

  factory BiotrainerSequenceRecord([void updates(BiotrainerSequenceRecordBuilder b)]) = _$BiotrainerSequenceRecord;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BiotrainerSequenceRecordBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BiotrainerSequenceRecord> get serializer => _$BiotrainerSequenceRecordSerializer();
}

class _$BiotrainerSequenceRecordSerializer implements PrimitiveSerializer<BiotrainerSequenceRecord> {
  @override
  final Iterable<Type> types = const [BiotrainerSequenceRecord, _$BiotrainerSequenceRecord];

  @override
  final String wireName = r'BiotrainerSequenceRecord';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BiotrainerSequenceRecord object, {
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
        specifiedType: const FullType.nullable(BuiltMap),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BiotrainerSequenceRecord object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BiotrainerSequenceRecordBuilder result,
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
            specifiedType: const FullType.nullable(BuiltMap),
          ) as BuiltMap?;
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
  BiotrainerSequenceRecord deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BiotrainerSequenceRecordBuilder();
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

