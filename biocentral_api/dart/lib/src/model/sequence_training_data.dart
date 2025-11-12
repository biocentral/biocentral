//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sequence_training_data.g.dart';

/// SequenceTrainingData
///
/// Properties:
/// * [seqId] - Sequence identifier
/// * [sequence] - AA Sequence
/// * [label] - Label to predict
/// * [set_] - Set
/// * [mask] 
@BuiltValue()
abstract class SequenceTrainingData implements Built<SequenceTrainingData, SequenceTrainingDataBuilder> {
  /// Sequence identifier
  @BuiltValueField(wireName: r'seq_id')
  String get seqId;

  /// AA Sequence
  @BuiltValueField(wireName: r'sequence')
  String get sequence;

  /// Label to predict
  @BuiltValueField(wireName: r'label')
  String get label;

  /// Set
  @BuiltValueField(wireName: r'set')
  String get set_;

  @BuiltValueField(wireName: r'mask')
  String? get mask;

  SequenceTrainingData._();

  factory SequenceTrainingData([void updates(SequenceTrainingDataBuilder b)]) = _$SequenceTrainingData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SequenceTrainingDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SequenceTrainingData> get serializer => _$SequenceTrainingDataSerializer();
}

class _$SequenceTrainingDataSerializer implements PrimitiveSerializer<SequenceTrainingData> {
  @override
  final Iterable<Type> types = const [SequenceTrainingData, _$SequenceTrainingData];

  @override
  final String wireName = r'SequenceTrainingData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SequenceTrainingData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'seq_id';
    yield serializers.serialize(
      object.seqId,
      specifiedType: const FullType(String),
    );
    yield r'sequence';
    yield serializers.serialize(
      object.sequence,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'set';
    yield serializers.serialize(
      object.set_,
      specifiedType: const FullType(String),
    );
    if (object.mask != null) {
      yield r'mask';
      yield serializers.serialize(
        object.mask,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SequenceTrainingData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SequenceTrainingDataBuilder result,
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
        case r'sequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sequence = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'set':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SequenceTrainingData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SequenceTrainingDataBuilder();
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

