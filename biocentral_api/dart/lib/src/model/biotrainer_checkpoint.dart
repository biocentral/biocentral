//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:typed_data';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'biotrainer_checkpoint.g.dart';

/// BiotrainerCheckpoint
///
/// Properties:
/// * [name] - Name of the checkpoint (e.g. hold_out)
/// * [checkpoint] - Bytes containing the checkpoint
@BuiltValue()
abstract class BiotrainerCheckpoint implements Built<BiotrainerCheckpoint, BiotrainerCheckpointBuilder> {
  /// Name of the checkpoint (e.g. hold_out)
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Bytes containing the checkpoint
  @BuiltValueField(wireName: r'checkpoint')
  Uint8List get checkpoint;

  BiotrainerCheckpoint._();

  factory BiotrainerCheckpoint([void updates(BiotrainerCheckpointBuilder b)]) = _$BiotrainerCheckpoint;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BiotrainerCheckpointBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BiotrainerCheckpoint> get serializer => _$BiotrainerCheckpointSerializer();
}

class _$BiotrainerCheckpointSerializer implements PrimitiveSerializer<BiotrainerCheckpoint> {
  @override
  final Iterable<Type> types = const [BiotrainerCheckpoint, _$BiotrainerCheckpoint];

  @override
  final String wireName = r'BiotrainerCheckpoint';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BiotrainerCheckpoint object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'checkpoint';
    yield serializers.serialize(
      object.checkpoint,
      specifiedType: const FullType(Uint8List),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BiotrainerCheckpoint object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BiotrainerCheckpointBuilder result,
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
        case r'checkpoint':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Uint8List),
          ) as Uint8List;
          result.checkpoint = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BiotrainerCheckpoint deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BiotrainerCheckpointBuilder();
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

