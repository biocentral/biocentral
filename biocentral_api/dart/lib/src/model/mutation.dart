//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mutation.g.dart';

/// Represents a single mutation (e.g. A15G)
///
/// Properties:
/// * [wt] - Wild type residue
/// * [position] - Position of the mutation
/// * [mt] - Mutated residue
/// * [oneIndexed] - Whether the position is one-indexed or zero-indexed
@BuiltValue()
abstract class Mutation implements Built<Mutation, MutationBuilder> {
  /// Wild type residue
  @BuiltValueField(wireName: r'wt')
  String get wt;

  /// Position of the mutation
  @BuiltValueField(wireName: r'position')
  int get position;

  /// Mutated residue
  @BuiltValueField(wireName: r'mt')
  String get mt;

  /// Whether the position is one-indexed or zero-indexed
  @BuiltValueField(wireName: r'one_indexed')
  bool? get oneIndexed;

  Mutation._();

  factory Mutation([void updates(MutationBuilder b)]) = _$Mutation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MutationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Mutation> get serializer => _$MutationSerializer();
}

class _$MutationSerializer implements PrimitiveSerializer<Mutation> {
  @override
  final Iterable<Type> types = const [Mutation, _$Mutation];

  @override
  final String wireName = r'Mutation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Mutation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'wt';
    yield serializers.serialize(
      object.wt,
      specifiedType: const FullType(String),
    );
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    yield r'mt';
    yield serializers.serialize(
      object.mt,
      specifiedType: const FullType(String),
    );
    if (object.oneIndexed != null) {
      yield r'one_indexed';
      yield serializers.serialize(
        object.oneIndexed,
        specifiedType: const FullType.nullable(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Mutation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MutationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'wt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.wt = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'mt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mt = valueDes;
          break;
        case r'one_indexed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.oneIndexed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Mutation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MutationBuilder();
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

