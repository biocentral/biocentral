//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/active_learning_convergence_config.dart';
import 'package:biocentral_api/src/model/sequence_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_screening_simulation_config.g.dart';

/// Configuration for a simulation of active learning on a complete dataset
///
/// Properties:
/// * [simulationData] - List of all sequence data for the simulation
/// * [nStart] - Number of initial sequences to use for training (chosen randomly, seed from campaign config used)
/// * [startIds] - List of sequence IDs to start the simulated campaign
/// * [nSuggestionsPerIteration] - Number of suggestions to propose per iteration
/// * [convergenceConfig] - Convergence criteria for the simulation
@BuiltValue()
abstract class ActiveLearningScreeningSimulationConfig implements Built<ActiveLearningScreeningSimulationConfig, ActiveLearningScreeningSimulationConfigBuilder> {
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

  /// Convergence criteria for the simulation
  @BuiltValueField(wireName: r'convergence_config')
  ActiveLearningConvergenceConfig get convergenceConfig;

  ActiveLearningScreeningSimulationConfig._();

  factory ActiveLearningScreeningSimulationConfig([void updates(ActiveLearningScreeningSimulationConfigBuilder b)]) = _$ActiveLearningScreeningSimulationConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningScreeningSimulationConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningScreeningSimulationConfig> get serializer => _$ActiveLearningScreeningSimulationConfigSerializer();
}

class _$ActiveLearningScreeningSimulationConfigSerializer implements PrimitiveSerializer<ActiveLearningScreeningSimulationConfig> {
  @override
  final Iterable<Type> types = const [ActiveLearningScreeningSimulationConfig, _$ActiveLearningScreeningSimulationConfig];

  @override
  final String wireName = r'ActiveLearningScreeningSimulationConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningScreeningSimulationConfig object, {
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
    yield r'convergence_config';
    yield serializers.serialize(
      object.convergenceConfig,
      specifiedType: const FullType(ActiveLearningConvergenceConfig),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningScreeningSimulationConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningScreeningSimulationConfigBuilder result,
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
        case r'convergence_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningConvergenceConfig),
          ) as ActiveLearningConvergenceConfig;
          result.convergenceConfig.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningScreeningSimulationConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningScreeningSimulationConfigBuilder();
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
