//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/sequence_training_data.dart';
import 'package:biocentral_api/src/model/active_learning_convergence_config.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_simulation_config.g.dart';

/// Configuration for a simulation of active learning on a complete dataset
///
/// Properties:
/// * [simulationData] - List of all sequence data for the simulation
/// * [nStart] 
/// * [startIds] 
/// * [nSuggestionsPerIteration] - Number of suggestions to propose per iteration
/// * [convergenceConfig] - Convergence criteria for the simulation
@BuiltValue()
abstract class ActiveLearningSimulationConfig implements Built<ActiveLearningSimulationConfig, ActiveLearningSimulationConfigBuilder> {
  /// List of all sequence data for the simulation
  @BuiltValueField(wireName: r'simulation_data')
  BuiltList<SequenceTrainingData> get simulationData;

  @BuiltValueField(wireName: r'n_start')
  int? get nStart;

  @BuiltValueField(wireName: r'start_ids')
  BuiltList<String>? get startIds;

  /// Number of suggestions to propose per iteration
  @BuiltValueField(wireName: r'n_suggestions_per_iteration')
  int get nSuggestionsPerIteration;

  /// Convergence criteria for the simulation
  @BuiltValueField(wireName: r'convergence_config')
  ActiveLearningConvergenceConfig get convergenceConfig;

  ActiveLearningSimulationConfig._();

  factory ActiveLearningSimulationConfig([void updates(ActiveLearningSimulationConfigBuilder b)]) = _$ActiveLearningSimulationConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningSimulationConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningSimulationConfig> get serializer => _$ActiveLearningSimulationConfigSerializer();
}

class _$ActiveLearningSimulationConfigSerializer implements PrimitiveSerializer<ActiveLearningSimulationConfig> {
  @override
  final Iterable<Type> types = const [ActiveLearningSimulationConfig, _$ActiveLearningSimulationConfig];

  @override
  final String wireName = r'ActiveLearningSimulationConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningSimulationConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'simulation_data';
    yield serializers.serialize(
      object.simulationData,
      specifiedType: const FullType(BuiltList, [FullType(SequenceTrainingData)]),
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
    ActiveLearningSimulationConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningSimulationConfigBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'simulation_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SequenceTrainingData)]),
          ) as BuiltList<SequenceTrainingData>;
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
  ActiveLearningSimulationConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningSimulationConfigBuilder();
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

