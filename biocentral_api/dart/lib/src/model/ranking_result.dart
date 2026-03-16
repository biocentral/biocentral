//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/metric_estimate.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ranking_result.g.dart';

/// RankingResult
///
/// Properties:
/// * [scc] - Spearmans correlation coefficient (overall ranking quality)
/// * [ndcg] - Normalized discounted cumulative gain (top-k ranking quality)
@BuiltValue()
abstract class RankingResult implements Built<RankingResult, RankingResultBuilder> {
  /// Spearmans correlation coefficient (overall ranking quality)
  @BuiltValueField(wireName: r'scc')
  MetricEstimate get scc;

  /// Normalized discounted cumulative gain (top-k ranking quality)
  @BuiltValueField(wireName: r'ndcg')
  MetricEstimate get ndcg;

  RankingResult._();

  factory RankingResult([void updates(RankingResultBuilder b)]) = _$RankingResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RankingResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RankingResult> get serializer => _$RankingResultSerializer();
}

class _$RankingResultSerializer implements PrimitiveSerializer<RankingResult> {
  @override
  final Iterable<Type> types = const [RankingResult, _$RankingResult];

  @override
  final String wireName = r'RankingResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RankingResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'scc';
    yield serializers.serialize(
      object.scc,
      specifiedType: const FullType(MetricEstimate),
    );
    yield r'ndcg';
    yield serializers.serialize(
      object.ndcg,
      specifiedType: const FullType(MetricEstimate),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RankingResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RankingResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'scc':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MetricEstimate),
          ) as MetricEstimate;
          result.scc.replace(valueDes);
          break;
        case r'ndcg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MetricEstimate),
          ) as MetricEstimate;
          result.ndcg.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RankingResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RankingResultBuilder();
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

