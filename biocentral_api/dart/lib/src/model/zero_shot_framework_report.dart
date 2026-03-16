//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/ranking_result.dart';
import 'package:biocentral_api/src/model/zero_shot_method.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'zero_shot_framework_report.g.dart';

/// ZeroShotFrameworkReport
///
/// Properties:
/// * [method] - Scoring method used
/// * [aggregatedResults] - Accumulated autoeval task results (combined_task_name -> RankingResult)
/// * [individualResults] - Individual autoeval task results (dataset_name -> RankingResult)
@BuiltValue()
abstract class ZeroShotFrameworkReport implements Built<ZeroShotFrameworkReport, ZeroShotFrameworkReportBuilder> {
  /// Scoring method used
  @BuiltValueField(wireName: r'method')
  ZeroShotMethod get method;
  // enum methodEnum {  WT_MARGINALS,  MASKED_MARGINALS,  PSEUDOPERPLEXITY,  PERPLEXITY,  };

  /// Accumulated autoeval task results (combined_task_name -> RankingResult)
  @BuiltValueField(wireName: r'aggregated_results')
  BuiltMap<String, RankingResult> get aggregatedResults;

  /// Individual autoeval task results (dataset_name -> RankingResult)
  @BuiltValueField(wireName: r'individual_results')
  BuiltMap<String, RankingResult> get individualResults;

  ZeroShotFrameworkReport._();

  factory ZeroShotFrameworkReport([void updates(ZeroShotFrameworkReportBuilder b)]) = _$ZeroShotFrameworkReport;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ZeroShotFrameworkReportBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ZeroShotFrameworkReport> get serializer => _$ZeroShotFrameworkReportSerializer();
}

class _$ZeroShotFrameworkReportSerializer implements PrimitiveSerializer<ZeroShotFrameworkReport> {
  @override
  final Iterable<Type> types = const [ZeroShotFrameworkReport, _$ZeroShotFrameworkReport];

  @override
  final String wireName = r'ZeroShotFrameworkReport';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ZeroShotFrameworkReport object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(ZeroShotMethod),
    );
    yield r'aggregated_results';
    yield serializers.serialize(
      object.aggregatedResults,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(RankingResult)]),
    );
    yield r'individual_results';
    yield serializers.serialize(
      object.individualResults,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(RankingResult)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ZeroShotFrameworkReport object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ZeroShotFrameworkReportBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ZeroShotMethod),
          ) as ZeroShotMethod;
          result.method = valueDes;
          break;
        case r'aggregated_results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(RankingResult)]),
          ) as BuiltMap<String, RankingResult>;
          result.aggregatedResults.replace(valueDes);
          break;
        case r'individual_results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(RankingResult)]),
          ) as BuiltMap<String, RankingResult>;
          result.individualResults.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ZeroShotFrameworkReport deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ZeroShotFrameworkReportBuilder();
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

