//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'embedding_stats.g.dart';

/// EmbeddingStats
///
/// Properties:
/// * [embedderName]
/// * [dims]
/// * [nTracked]
/// * [min]
/// * [max]
@BuiltValue()
abstract class EmbeddingStats implements Built<EmbeddingStats, EmbeddingStatsBuilder> {
  @BuiltValueField(wireName: r'embedder_name')
  String get embedderName;

  @BuiltValueField(wireName: r'dims')
  int get dims;

  @BuiltValueField(wireName: r'n_tracked')
  int get nTracked;

  @BuiltValueField(wireName: r'min')
  num get min;

  @BuiltValueField(wireName: r'max')
  num get max;

  EmbeddingStats._();

  factory EmbeddingStats([void updates(EmbeddingStatsBuilder b)]) = _$EmbeddingStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EmbeddingStatsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EmbeddingStats> get serializer => _$EmbeddingStatsSerializer();
}

class _$EmbeddingStatsSerializer implements PrimitiveSerializer<EmbeddingStats> {
  @override
  final Iterable<Type> types = const [EmbeddingStats, _$EmbeddingStats];

  @override
  final String wireName = r'EmbeddingStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EmbeddingStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'embedder_name';
    yield serializers.serialize(
      object.embedderName,
      specifiedType: const FullType(String),
    );
    yield r'dims';
    yield serializers.serialize(
      object.dims,
      specifiedType: const FullType(int),
    );
    yield r'n_tracked';
    yield serializers.serialize(
      object.nTracked,
      specifiedType: const FullType(int),
    );
    yield r'min';
    yield serializers.serialize(
      object.min,
      specifiedType: const FullType(num),
    );
    yield r'max';
    yield serializers.serialize(
      object.max,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EmbeddingStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EmbeddingStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'embedder_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.embedderName = valueDes;
          break;
        case r'dims':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.dims = valueDes;
          break;
        case r'n_tracked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.nTracked = valueDes;
          break;
        case r'min':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.min = valueDes;
          break;
        case r'max':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.max = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EmbeddingStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EmbeddingStatsBuilder();
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
