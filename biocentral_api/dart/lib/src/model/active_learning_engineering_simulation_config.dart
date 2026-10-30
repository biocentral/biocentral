//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/active_learning_stopping_config.dart';
import 'package:biocentral_api/src/model/sequence_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_engineering_simulation_config.g.dart';

/// Configuration for a simulated engineering campaign over a labelled landscape.  Each round scores candidates drawn from simulation_data, so every suggestion has a label to reveal. Engineering campaigns only maximize or minimize, so there is no hit_target_delta.
///
/// Properties:
/// * [simulationData] - List of all sequence data for the simulation
/// * [nStart] - Number of initial sequences to use for training (chosen randomly, seed from campaign config used)
/// * [startIds] - List of sequence IDs to start the simulated campaign
/// * [nSuggestionsPerIteration] - Number of suggestions to propose per iteration
/// * [stoppingConfig] - Stopping criteria for the simulation
/// * [hitPercentile] - Percentile of all labels that counts as a hit (modes: MAXIMIZE, MINIMIZE). 1.0 means the top/bottom 1% of the labels.
/// * [nCandidatesPerIteration] - Number of unlabelled landscape variants to score per iteration
@BuiltValue()
abstract class ActiveLearningEngineeringSimulationConfig implements Built<ActiveLearningEngineeringSimulationConfig, ActiveLearningEngineeringSimulationConfigBuilder> {
  /// List of all sequence data for the simulation
  @BuiltValueField(wireName: r'simulation_data')
  BuiltList<SequenceData> get simulationData;

  /// Number of initial sequences to use for training (chosen randomly, seed from campaign config used)
  @BuiltValueField(wireName: r'n_start')
  int? get nStart;

  /// List of sequence IDs to start the simulated campaign
  @BuiltValueField(wireName: r'start_ids')
  BuiltList<String>? get startIds;

  /// Number of suggestions to propose per iteration
  @BuiltValueField(wireName: r'n_suggestions_per_iteration')
  int get nSuggestionsPerIteration;

  /// Stopping criteria for the simulation
  @BuiltValueField(wireName: r'stopping_config')
  ActiveLearningStoppingConfig get stoppingConfig;

  /// Percentile of all labels that counts as a hit (modes: MAXIMIZE, MINIMIZE). 1.0 means the top/bottom 1% of the labels.
  @BuiltValueField(wireName: r'hit_percentile')
  num? get hitPercentile;

  /// Number of unlabelled landscape variants to score per iteration
  @BuiltValueField(wireName: r'n_candidates_per_iteration')
  int? get nCandidatesPerIteration;

  ActiveLearningEngineeringSimulationConfig._();

  factory ActiveLearningEngineeringSimulationConfig([void updates(ActiveLearningEngineeringSimulationConfigBuilder b)]) = _$ActiveLearningEngineeringSimulationConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningEngineeringSimulationConfigBuilder b) => b
      ..hitPercentile = 1.0
      ..nCandidatesPerIteration = 1000;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningEngineeringSimulationConfig> get serializer => _$ActiveLearningEngineeringSimulationConfigSerializer();
}

class _$ActiveLearningEngineeringSimulationConfigSerializer implements PrimitiveSerializer<ActiveLearningEngineeringSimulationConfig> {
  @override
  final Iterable<Type> types = const [ActiveLearningEngineeringSimulationConfig, _$ActiveLearningEngineeringSimulationConfig];

  @override
  final String wireName = r'ActiveLearningEngineeringSimulationConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningEngineeringSimulationConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'simulation_data';
    yield serializers.serialize(
      object.simulationData,
      specifiedType: const FullType(BuiltList, [FullType(SequenceData)]),
    );
    if (object.nStart != null) {
      yield r'n_start';
      yield serializers.serialize(
        object.nStart,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.startIds != null) {
      yield r'start_ids';
      yield serializers.serialize(
        object.startIds,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    yield r'n_suggestions_per_iteration';
    yield serializers.serialize(
      object.nSuggestionsPerIteration,
      specifiedType: const FullType(int),
    );
    yield r'stopping_config';
    yield serializers.serialize(
      object.stoppingConfig,
      specifiedType: const FullType(ActiveLearningStoppingConfig),
    );
    if (object.hitPercentile != null) {
      yield r'hit_percentile';
      yield serializers.serialize(
        object.hitPercentile,
        specifiedType: const FullType(num),
      );
    }
    if (object.nCandidatesPerIteration != null) {
      yield r'n_candidates_per_iteration';
      yield serializers.serialize(
        object.nCandidatesPerIteration,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningEngineeringSimulationConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningEngineeringSimulationConfigBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'simulation_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SequenceData)]),
          ) as BuiltList<SequenceData>;
          result.simulationData.replace(valueDes);
          break;
        case r'n_start':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nStart = valueDes;
          break;
        case r'start_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.startIds.replace(valueDes);
          break;
        case r'n_suggestions_per_iteration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.nSuggestionsPerIteration = valueDes;
          break;
        case r'stopping_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningStoppingConfig),
          ) as ActiveLearningStoppingConfig;
          result.stoppingConfig.replace(valueDes);
          break;
        case r'hit_percentile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.hitPercentile = valueDes;
          break;
        case r'n_candidates_per_iteration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nCandidatesPerIteration = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningEngineeringSimulationConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningEngineeringSimulationConfigBuilder();
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

