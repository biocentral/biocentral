//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:biocentral_api/src/model/active_learning_iteration_result.dart';
// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_simulation_result.g.dart';

/// Result of a simulated active learning campaign - used as a mutable object to store intermediate results
///
/// Properties:
/// * [campaignName] - Name of the simulated active learning campaign
/// * [iterationMetricsTotal] - Total metrics (rmse/acc) for each iteration on all data
/// * [iterationMetricsSuggestions] - Metrics (rmse/acc) for each iteration on suggested data
/// * [iterationTargetSuccesses] - Number of successful targets found in each iteration
/// * [iterationConsecutiveFailures] - Number of consecutive failures since the last successful target was found
/// * [stopReasons] 
/// * [iterationResults] - List of active learning iteration results
@BuiltValue()
abstract class ActiveLearningSimulationResult implements Built<ActiveLearningSimulationResult, ActiveLearningSimulationResultBuilder> {
  /// Name of the simulated active learning campaign
  @BuiltValueField(wireName: r'campaign_name')
  String get campaignName;

  /// Total metrics (rmse/acc) for each iteration on all data
  @BuiltValueField(wireName: r'iteration_metrics_total')
  BuiltList<num>? get iterationMetricsTotal;

  /// Metrics (rmse/acc) for each iteration on suggested data
  @BuiltValueField(wireName: r'iteration_metrics_suggestions')
  BuiltList<num>? get iterationMetricsSuggestions;

  /// Number of successful targets found in each iteration
  @BuiltValueField(wireName: r'iteration_target_successes')
  BuiltList<int>? get iterationTargetSuccesses;

  /// Number of consecutive failures since the last successful target was found
  @BuiltValueField(wireName: r'iteration_consecutive_failures')
  BuiltList<int>? get iterationConsecutiveFailures;

  @BuiltValueField(wireName: r'stop_reasons')
  BuiltList<String>? get stopReasons;

  /// List of active learning iteration results
  @BuiltValueField(wireName: r'iteration_results')
  BuiltList<ActiveLearningIterationResult>? get iterationResults;

  ActiveLearningSimulationResult._();

  factory ActiveLearningSimulationResult([void updates(ActiveLearningSimulationResultBuilder b)]) = _$ActiveLearningSimulationResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningSimulationResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningSimulationResult> get serializer => _$ActiveLearningSimulationResultSerializer();
}

class _$ActiveLearningSimulationResultSerializer implements PrimitiveSerializer<ActiveLearningSimulationResult> {
  @override
  final Iterable<Type> types = const [ActiveLearningSimulationResult, _$ActiveLearningSimulationResult];

  @override
  final String wireName = r'ActiveLearningSimulationResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningSimulationResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'campaign_name';
    yield serializers.serialize(
      object.campaignName,
      specifiedType: const FullType(String),
    );
    if (object.iterationMetricsTotal != null) {
      yield r'iteration_metrics_total';
      yield serializers.serialize(
        object.iterationMetricsTotal,
        specifiedType: const FullType(BuiltList, [FullType(num)]),
      );
    }
    if (object.iterationMetricsSuggestions != null) {
      yield r'iteration_metrics_suggestions';
      yield serializers.serialize(
        object.iterationMetricsSuggestions,
        specifiedType: const FullType(BuiltList, [FullType(num)]),
      );
    }
    if (object.iterationTargetSuccesses != null) {
      yield r'iteration_target_successes';
      yield serializers.serialize(
        object.iterationTargetSuccesses,
        specifiedType: const FullType(BuiltList, [FullType(int)]),
      );
    }
    if (object.iterationConsecutiveFailures != null) {
      yield r'iteration_consecutive_failures';
      yield serializers.serialize(
        object.iterationConsecutiveFailures,
        specifiedType: const FullType(BuiltList, [FullType(int)]),
      );
    }
    if (object.stopReasons != null) {
      yield r'stop_reasons';
      yield serializers.serialize(
        object.stopReasons,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.iterationResults != null) {
      yield r'iteration_results';
      yield serializers.serialize(
        object.iterationResults,
        specifiedType: const FullType(BuiltList, [FullType(ActiveLearningIterationResult)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningSimulationResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningSimulationResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'campaign_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.campaignName = valueDes;
          break;
        case r'iteration_metrics_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(num)]),
          ) as BuiltList<num>;
          result.iterationMetricsTotal.replace(valueDes);
          break;
        case r'iteration_metrics_suggestions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(num)]),
          ) as BuiltList<num>;
          result.iterationMetricsSuggestions.replace(valueDes);
          break;
        case r'iteration_target_successes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(int)]),
          ) as BuiltList<int>;
          result.iterationTargetSuccesses.replace(valueDes);
          break;
        case r'iteration_consecutive_failures':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(int)]),
          ) as BuiltList<int>;
          result.iterationConsecutiveFailures.replace(valueDes);
          break;
        case r'stop_reasons':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.stopReasons.replace(valueDes);
          break;
        case r'iteration_results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ActiveLearningIterationResult)]),
          ) as BuiltList<ActiveLearningIterationResult>;
          result.iterationResults.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningSimulationResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningSimulationResultBuilder();
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

