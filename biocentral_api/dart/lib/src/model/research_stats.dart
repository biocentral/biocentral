//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'research_stats.g.dart';

/// ResearchStats
///
/// Properties:
/// * [totalSequences24h] - Total number of sequences uploaded in the last 24 hours
/// * [totalSequences7d] - Total number of sequences uploaded in the last 7 days
/// * [totalSequencesAllTime] - Total number of sequences uploaded in all time
/// * [avgSequenceLength] - Average length of sequences uploaded
/// * [topEmbedders] - Top embedders based on usage
/// * [updatedAt] - Timestamp of the last update
@BuiltValue()
abstract class ResearchStats implements Built<ResearchStats, ResearchStatsBuilder> {
  /// Total number of sequences uploaded in the last 24 hours
  @BuiltValueField(wireName: r'total_sequences_24h')
  int get totalSequences24h;

  /// Total number of sequences uploaded in the last 7 days
  @BuiltValueField(wireName: r'total_sequences_7d')
  int get totalSequences7d;

  /// Total number of sequences uploaded in all time
  @BuiltValueField(wireName: r'total_sequences_all_time')
  int get totalSequencesAllTime;

  /// Average length of sequences uploaded
  @BuiltValueField(wireName: r'avg_sequence_length')
  num get avgSequenceLength;

  /// Top embedders based on usage
  @BuiltValueField(wireName: r'top_embedders')
  BuiltList<BuiltMap<String, num>> get topEmbedders;

  /// Timestamp of the last update
  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  ResearchStats._();

  factory ResearchStats([void updates(ResearchStatsBuilder b)]) = _$ResearchStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResearchStatsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResearchStats> get serializer => _$ResearchStatsSerializer();
}

class _$ResearchStatsSerializer implements PrimitiveSerializer<ResearchStats> {
  @override
  final Iterable<Type> types = const [ResearchStats, _$ResearchStats];

  @override
  final String wireName = r'ResearchStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResearchStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'total_sequences_24h';
    yield serializers.serialize(
      object.totalSequences24h,
      specifiedType: const FullType(int),
    );
    yield r'total_sequences_7d';
    yield serializers.serialize(
      object.totalSequences7d,
      specifiedType: const FullType(int),
    );
    yield r'total_sequences_all_time';
    yield serializers.serialize(
      object.totalSequencesAllTime,
      specifiedType: const FullType(int),
    );
    yield r'avg_sequence_length';
    yield serializers.serialize(
      object.avgSequenceLength,
      specifiedType: const FullType(num),
    );
    yield r'top_embedders';
    yield serializers.serialize(
      object.topEmbedders,
      specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType(num)])]),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResearchStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ResearchStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'total_sequences_24h':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalSequences24h = valueDes;
          break;
        case r'total_sequences_7d':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalSequences7d = valueDes;
          break;
        case r'total_sequences_all_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalSequencesAllTime = valueDes;
          break;
        case r'avg_sequence_length':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgSequenceLength = valueDes;
          break;
        case r'top_embedders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType(num)])]),
          ) as BuiltList<BuiltMap<String, num>>;
          result.topEmbedders.replace(valueDes);
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResearchStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResearchStatsBuilder();
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

