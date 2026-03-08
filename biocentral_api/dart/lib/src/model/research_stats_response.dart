//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/research_stats.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'research_stats_response.g.dart';

/// ResearchStatsResponse
///
/// Properties:
/// * [researchStats] - Research statistics
@BuiltValue()
abstract class ResearchStatsResponse implements Built<ResearchStatsResponse, ResearchStatsResponseBuilder> {
  /// Research statistics
  @BuiltValueField(wireName: r'research_stats')
  ResearchStats get researchStats;

  ResearchStatsResponse._();

  factory ResearchStatsResponse([void updates(ResearchStatsResponseBuilder b)]) = _$ResearchStatsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResearchStatsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResearchStatsResponse> get serializer => _$ResearchStatsResponseSerializer();
}

class _$ResearchStatsResponseSerializer implements PrimitiveSerializer<ResearchStatsResponse> {
  @override
  final Iterable<Type> types = const [ResearchStatsResponse, _$ResearchStatsResponse];

  @override
  final String wireName = r'ResearchStatsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResearchStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'research_stats';
    yield serializers.serialize(
      object.researchStats,
      specifiedType: const FullType(ResearchStats),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResearchStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ResearchStatsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'research_stats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResearchStats),
          ) as ResearchStats;
          result.researchStats.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResearchStatsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResearchStatsResponseBuilder();
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

