//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_convergence_config.g.dart';

/// Configuration for convergence criteria for active learning campaigns
///
/// Properties:
/// * [maxLabelsBudget] 
/// * [targetSuccesses] 
/// * [maxConsecutiveFailures] 
@BuiltValue()
abstract class ActiveLearningConvergenceConfig implements Built<ActiveLearningConvergenceConfig, ActiveLearningConvergenceConfigBuilder> {
  @BuiltValueField(wireName: r'max_labels_budget')
  int? get maxLabelsBudget;

  @BuiltValueField(wireName: r'target_successes')
  int? get targetSuccesses;

  @BuiltValueField(wireName: r'max_consecutive_failures')
  int? get maxConsecutiveFailures;

  ActiveLearningConvergenceConfig._();

  factory ActiveLearningConvergenceConfig([void updates(ActiveLearningConvergenceConfigBuilder b)]) = _$ActiveLearningConvergenceConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningConvergenceConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningConvergenceConfig> get serializer => _$ActiveLearningConvergenceConfigSerializer();
}

class _$ActiveLearningConvergenceConfigSerializer implements PrimitiveSerializer<ActiveLearningConvergenceConfig> {
  @override
  final Iterable<Type> types = const [ActiveLearningConvergenceConfig, _$ActiveLearningConvergenceConfig];

  @override
  final String wireName = r'ActiveLearningConvergenceConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningConvergenceConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.maxLabelsBudget != null) {
      yield r'max_labels_budget';
      yield serializers.serialize(
        object.maxLabelsBudget,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.targetSuccesses != null) {
      yield r'target_successes';
      yield serializers.serialize(
        object.targetSuccesses,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.maxConsecutiveFailures != null) {
      yield r'max_consecutive_failures';
      yield serializers.serialize(
        object.maxConsecutiveFailures,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningConvergenceConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningConvergenceConfigBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'max_labels_budget':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.maxLabelsBudget = valueDes;
          break;
        case r'target_successes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.targetSuccesses = valueDes;
          break;
        case r'max_consecutive_failures':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.maxConsecutiveFailures = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningConvergenceConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningConvergenceConfigBuilder();
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

