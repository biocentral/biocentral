//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/sequence_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_screening_iteration_config.g.dart';

/// Configuration for a single iteration of active learning
///
/// Properties:
/// * [iteration] - Iteration number
/// * [iterationData] - List of sequence training data for this iteration
/// * [coefficient] - Exploitation-Exploration coefficient value (must be between 0 and 1, 1 is maximum exploration)
/// * [nSuggestions] - Number of suggestions to propose from this iteration
@BuiltValue()
abstract class ActiveLearningScreeningIterationConfig implements Built<ActiveLearningScreeningIterationConfig, ActiveLearningScreeningIterationConfigBuilder> {
  /// Iteration number
  @BuiltValueField(wireName: r'iteration')
  int get iteration;

  /// List of sequence training data for this iteration
  @BuiltValueField(wireName: r'iteration_data')
  BuiltList<SequenceData> get iterationData;

  /// Exploitation-Exploration coefficient value (must be between 0 and 1, 1 is maximum exploration)
  @BuiltValueField(wireName: r'coefficient')
  num get coefficient;

  /// Number of suggestions to propose from this iteration
  @BuiltValueField(wireName: r'n_suggestions')
  int get nSuggestions;

  ActiveLearningScreeningIterationConfig._();

  factory ActiveLearningScreeningIterationConfig([void updates(ActiveLearningScreeningIterationConfigBuilder b)]) = _$ActiveLearningScreeningIterationConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningScreeningIterationConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningScreeningIterationConfig> get serializer => _$ActiveLearningScreeningIterationConfigSerializer();
}

class _$ActiveLearningScreeningIterationConfigSerializer implements PrimitiveSerializer<ActiveLearningScreeningIterationConfig> {
  @override
  final Iterable<Type> types = const [ActiveLearningScreeningIterationConfig, _$ActiveLearningScreeningIterationConfig];

  @override
  final String wireName = r'ActiveLearningScreeningIterationConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningScreeningIterationConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'iteration';
    yield serializers.serialize(
      object.iteration,
      specifiedType: const FullType(int),
    );
    yield r'iteration_data';
    yield serializers.serialize(
      object.iterationData,
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
    ActiveLearningScreeningIterationConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningScreeningIterationConfigBuilder result,
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
        case r'iteration_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SequenceData)]),
          ) as BuiltList<SequenceData>;
          result.iterationData.replace(valueDes);
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
  ActiveLearningScreeningIterationConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningScreeningIterationConfigBuilder();
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

