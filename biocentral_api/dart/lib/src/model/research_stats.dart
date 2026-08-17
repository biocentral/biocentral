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
/// * [totalSequencesToday] - Total number of sequences uploaded in the last 24 hours
/// * [totalSequencesAllTime] - Total number of sequences uploaded in all time
/// * [avgSequenceLength] - Average length of sequences uploaded
/// * [aaDistribution] - Distribution of amino acids in the sequences
/// * [topEmbedders] - Top embedders based on usage
/// * [topPredictors] - Top prediction models based on usage
/// * [updatedAt] - Timestamp of the last update
@BuiltValue()
abstract class ResearchStats implements Built<ResearchStats, ResearchStatsBuilder> {
  /// Total number of sequences uploaded in the last 24 hours
  @BuiltValueField(wireName: r'total_sequences_today')
  int get totalSequencesToday;

  /// Total number of sequences uploaded in all time
  @BuiltValueField(wireName: r'total_sequences_all_time')
  int get totalSequencesAllTime;

  /// Average length of sequences uploaded
  @BuiltValueField(wireName: r'avg_sequence_length')
  num get avgSequenceLength;

  /// Distribution of amino acids in the sequences
  @BuiltValueField(wireName: r'aa_distribution')
  BuiltMap<String, int> get aaDistribution;

  /// Top embedders based on usage
  @BuiltValueField(wireName: r'top_embedders')
  BuiltMap<String, num> get topEmbedders;

  /// Top prediction models based on usage
  @BuiltValueField(wireName: r'top_predictors')
  BuiltMap<String, num> get topPredictors;

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
    yield r'total_sequences_today';
    yield serializers.serialize(
      object.totalSequencesToday,
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
    yield r'aa_distribution';
    yield serializers.serialize(
      object.aaDistribution,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(int)]),
    );
    yield r'top_embedders';
    yield serializers.serialize(
      object.topEmbedders,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(num)]),
    );
    yield r'top_predictors';
    yield serializers.serialize(
      object.topPredictors,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(num)]),
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
        case r'total_sequences_today':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalSequencesToday = valueDes;
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
        case r'aa_distribution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(int)]),
          ) as BuiltMap<String, int>;
          result.aaDistribution.replace(valueDes);
          break;
        case r'top_embedders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(num)]),
          ) as BuiltMap<String, num>;
          result.topEmbedders.replace(valueDes);
          break;
        case r'top_predictors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(num)]),
          ) as BuiltMap<String, num>;
          result.topPredictors.replace(valueDes);
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

