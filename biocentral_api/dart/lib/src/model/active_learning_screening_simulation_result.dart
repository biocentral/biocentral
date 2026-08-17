//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/active_learning_iteration_result.dart';
import 'package:biocentral_api/src/model/bootstrapped_metric.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_screening_simulation_result.g.dart';

/// Result of a simulated active learning screening campaign - used as a mutable object to store intermediate results
///
/// Properties:
/// * [campaignName] - Name of the simulated active learning campaign
/// * [potentialHits] - Potential targets (hits) to find in the dataset given the campaign config
/// * [iterationMetricsTotal] - Total metrics (mae/acc) for each iteration on all data
/// * [iterationMetricsSuggestions] - Metrics (mae/acc) for each iteration on suggested data
/// * [iterationHits] - Successful targets (hits) found in each iteration
/// * [iterationConsecutiveFailures] - Number of consecutive failures since the last successful target was found
/// * [stopReasons] - Reason(s) for stopping the simulation (convergence criteria reached)
/// * [iterationResults] - List of active learning iteration results
@BuiltValue()
abstract class ActiveLearningScreeningSimulationResult implements Built<ActiveLearningScreeningSimulationResult, ActiveLearningScreeningSimulationResultBuilder> {
  /// Name of the simulated active learning campaign
  @BuiltValueField(wireName: r'campaign_name')
  String get campaignName;

  /// Potential targets (hits) to find in the dataset given the campaign config
  @BuiltValueField(wireName: r'potential_hits')
  BuiltList<String> get potentialHits;

  /// Total metrics (mae/acc) for each iteration on all data
  @BuiltValueField(wireName: r'iteration_metrics_total')
  BuiltList<BootstrappedMetric>? get iterationMetricsTotal;

  /// Metrics (mae/acc) for each iteration on suggested data
  @BuiltValueField(wireName: r'iteration_metrics_suggestions')
  BuiltList<BootstrappedMetric>? get iterationMetricsSuggestions;

  /// Successful targets (hits) found in each iteration
  @BuiltValueField(wireName: r'iteration_hits')
  BuiltList<BuiltList<String>>? get iterationHits;

  /// Number of consecutive failures since the last successful target was found
  @BuiltValueField(wireName: r'iteration_consecutive_failures')
  BuiltList<int>? get iterationConsecutiveFailures;

  /// Reason(s) for stopping the simulation (convergence criteria reached)
  @BuiltValueField(wireName: r'stop_reasons')
  BuiltList<String>? get stopReasons;

  /// List of active learning iteration results
  @BuiltValueField(wireName: r'iteration_results')
  BuiltList<ActiveLearningIterationResult>? get iterationResults;

  ActiveLearningScreeningSimulationResult._();

  factory ActiveLearningScreeningSimulationResult([void updates(ActiveLearningScreeningSimulationResultBuilder b)]) = _$ActiveLearningScreeningSimulationResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningScreeningSimulationResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningScreeningSimulationResult> get serializer => _$ActiveLearningScreeningSimulationResultSerializer();
}

class _$ActiveLearningScreeningSimulationResultSerializer implements PrimitiveSerializer<ActiveLearningScreeningSimulationResult> {
  @override
  final Iterable<Type> types = const [ActiveLearningScreeningSimulationResult, _$ActiveLearningScreeningSimulationResult];

  @override
  final String wireName = r'ActiveLearningScreeningSimulationResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningScreeningSimulationResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'campaign_name';
    yield serializers.serialize(
      object.campaignName,
      specifiedType: const FullType(String),
    );
    yield r'potential_hits';
    yield serializers.serialize(
      object.potentialHits,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.iterationMetricsTotal != null) {
      yield r'iteration_metrics_total';
      yield serializers.serialize(
        object.iterationMetricsTotal,
        specifiedType: const FullType(BuiltList, [FullType(BootstrappedMetric)]),
      );
    }
    if (object.iterationMetricsSuggestions != null) {
      yield r'iteration_metrics_suggestions';
      yield serializers.serialize(
        object.iterationMetricsSuggestions,
        specifiedType: const FullType(BuiltList, [FullType(BootstrappedMetric)]),
      );
    }
    if (object.iterationHits != null) {
      yield r'iteration_hits';
      yield serializers.serialize(
        object.iterationHits,
        specifiedType: const FullType(BuiltList, [FullType(BuiltList, [FullType(String)])]),
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
    ActiveLearningScreeningSimulationResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningScreeningSimulationResultBuilder result,
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
        case r'potential_hits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.potentialHits.replace(valueDes);
          break;
        case r'iteration_metrics_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(BootstrappedMetric)]),
          ) as BuiltList<BootstrappedMetric>?;
          if (valueDes == null) continue;
          result.iterationMetricsTotal.replace(valueDes);
          break;
        case r'iteration_metrics_suggestions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(BootstrappedMetric)]),
          ) as BuiltList<BootstrappedMetric>?;
          if (valueDes == null) continue;
          result.iterationMetricsSuggestions.replace(valueDes);
          break;
        case r'iteration_hits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(BuiltList, [FullType(String)])]),
          ) as BuiltList<BuiltList<String>>?;
          if (valueDes == null) continue;
          result.iterationHits.replace(valueDes);
          break;
        case r'iteration_consecutive_failures':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(int)]),
          ) as BuiltList<int>?;
          if (valueDes == null) continue;
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
            specifiedType: const FullType.nullable(BuiltList, [FullType(ActiveLearningIterationResult)]),
          ) as BuiltList<ActiveLearningIterationResult>?;
          if (valueDes == null) continue;
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
  ActiveLearningScreeningSimulationResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningScreeningSimulationResultBuilder();
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

