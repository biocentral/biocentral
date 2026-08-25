//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'embedding_progress.g.dart';

/// EmbeddingProgress
///
/// Properties:
/// * [current] - Current progress
/// * [total] - Total number of embeddings to compute
@BuiltValue()
abstract class EmbeddingProgress implements Built<EmbeddingProgress, EmbeddingProgressBuilder> {
  /// Current progress
  @BuiltValueField(wireName: r'current')
  int get current;

  /// Total number of embeddings to compute
  @BuiltValueField(wireName: r'total')
  int get total;

  EmbeddingProgress._();

  factory EmbeddingProgress([void updates(EmbeddingProgressBuilder b)]) = _$EmbeddingProgress;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EmbeddingProgressBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EmbeddingProgress> get serializer => _$EmbeddingProgressSerializer();
}

class _$EmbeddingProgressSerializer implements PrimitiveSerializer<EmbeddingProgress> {
  @override
  final Iterable<Type> types = const [EmbeddingProgress, _$EmbeddingProgress];

  @override
  final String wireName = r'EmbeddingProgress';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EmbeddingProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'current';
    yield serializers.serialize(
      object.current,
      specifiedType: const FullType(int),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EmbeddingProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EmbeddingProgressBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.current = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EmbeddingProgress deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EmbeddingProgressBuilder();
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

