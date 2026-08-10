//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/sequence_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_engineering_iteration_config.g.dart';

/// Configuration for a single iteration of active learning
///
/// Properties:
/// * [iteration] - Iteration number
/// * [baseSequences] - Sequences used to generate mutations
/// * [trainingData] - List of training data for this iteration
/// * [coefficient] - Exploitation-Exploration coefficient value (must be between 0 and 1, 1 is maximum exploration)
/// * [nSuggestions] - Number of suggestions to propose from this iteration
@BuiltValue()
abstract class ActiveLearningEngineeringIterationConfig implements Built<ActiveLearningEngineeringIterationConfig, ActiveLearningEngineeringIterationConfigBuilder> {
  /// Iteration number
  @BuiltValueField(wireName: r'iteration')
  int get iteration;

  /// Sequences used to generate mutations
  @BuiltValueField(wireName: r'base_sequences')
  BuiltList<String> get baseSequences;

  /// List of training data for this iteration
  @BuiltValueField(wireName: r'training_data')
  BuiltList<SequenceData> get trainingData;

  /// Exploitation-Exploration coefficient value (must be between 0 and 1, 1 is maximum exploration)
  @BuiltValueField(wireName: r'coefficient')
  num get coefficient;

  /// Number of suggestions to propose from this iteration
  @BuiltValueField(wireName: r'n_suggestions')
  int get nSuggestions;

  ActiveLearningEngineeringIterationConfig._();

  factory ActiveLearningEngineeringIterationConfig([void updates(ActiveLearningEngineeringIterationConfigBuilder b)]) = _$ActiveLearningEngineeringIterationConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningEngineeringIterationConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningEngineeringIterationConfig> get serializer => _$ActiveLearningEngineeringIterationConfigSerializer();
}

class _$ActiveLearningEngineeringIterationConfigSerializer implements PrimitiveSerializer<ActiveLearningEngineeringIterationConfig> {
  @override
  final Iterable<Type> types = const [ActiveLearningEngineeringIterationConfig, _$ActiveLearningEngineeringIterationConfig];

  @override
  final String wireName = r'ActiveLearningEngineeringIterationConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningEngineeringIterationConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'iteration';
    yield serializers.serialize(
      object.iteration,
      specifiedType: const FullType(int),
    );
    yield r'base_sequences';
    yield serializers.serialize(
      object.baseSequences,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'training_data';
    yield serializers.serialize(
      object.trainingData,
      specifiedType: const FullType(BuiltList, [FullType(SequenceData)]),
    );
    yield r'coefficient';
    yield serializers.serialize(
      object.coefficient,
      specifiedType: const FullType(num),
    );
    yield r'n_suggestions';
    yield serializers.serialize(
      object.nSuggestions,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningEngineeringIterationConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningEngineeringIterationConfigBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'iteration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.iteration = valueDes;
          break;
        case r'base_sequences':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.baseSequences.replace(valueDes);
          break;
        case r'training_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SequenceData)]),
          ) as BuiltList<SequenceData>;
          result.trainingData.replace(valueDes);
          break;
        case r'coefficient':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.coefficient = valueDes;
          break;
        case r'n_suggestions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.nSuggestions = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningEngineeringIterationConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningEngineeringIterationConfigBuilder();
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
