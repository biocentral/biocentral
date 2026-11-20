//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_stopping_config.g.dart';

/// Configuration for stopping criteria for active learning campaigns
///
/// Properties:
/// * [maxLabelsBudget] - Maximum number of labels that can be tested in the lab ('We can afford to test 100 proteins total')
/// * [nHits] - Number of positive targets (hits) found before stopping ('Stop when we find 10 good proteins')
/// * [maxConsecutiveFailures] - Maximum number of iterations in a row that do not yield a new target ('Stop if 3 rounds yield nothing')
/// * [nMaxIterations] - Hard upper limit on the number of iterations, applied even if no other criterion is reached
@BuiltValue()
abstract class ActiveLearningStoppingConfig implements Built<ActiveLearningStoppingConfig, ActiveLearningStoppingConfigBuilder> {
  /// Maximum number of labels that can be tested in the lab ('We can afford to test 100 proteins total')
  @BuiltValueField(wireName: r'max_labels_budget')
  int? get maxLabelsBudget;

  /// Number of positive targets (hits) found before stopping ('Stop when we find 10 good proteins')
  @BuiltValueField(wireName: r'n_hits')
  int? get nHits;

  /// Maximum number of iterations in a row that do not yield a new target ('Stop if 3 rounds yield nothing')
  @BuiltValueField(wireName: r'max_consecutive_failures')
  int? get maxConsecutiveFailures;

  /// Hard upper limit on the number of iterations, applied even if no other criterion is reached
  @BuiltValueField(wireName: r'n_max_iterations')
  int? get nMaxIterations;

  ActiveLearningStoppingConfig._();

  factory ActiveLearningStoppingConfig([void updates(ActiveLearningStoppingConfigBuilder b)]) = _$ActiveLearningStoppingConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningStoppingConfigBuilder b) => b
      ..nMaxIterations = 100;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningStoppingConfig> get serializer => _$ActiveLearningStoppingConfigSerializer();
}

class _$ActiveLearningStoppingConfigSerializer implements PrimitiveSerializer<ActiveLearningStoppingConfig> {
  @override
  final Iterable<Type> types = const [ActiveLearningStoppingConfig, _$ActiveLearningStoppingConfig];

  @override
  final String wireName = r'ActiveLearningStoppingConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningStoppingConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.maxLabelsBudget != null) {
      yield r'max_labels_budget';
      yield serializers.serialize(
        object.maxLabelsBudget,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.nHits != null) {
      yield r'n_hits';
      yield serializers.serialize(
        object.nHits,
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
    if (object.nMaxIterations != null) {
      yield r'n_max_iterations';
      yield serializers.serialize(
        object.nMaxIterations,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningStoppingConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningStoppingConfigBuilder result,
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
        case r'n_hits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nHits = valueDes;
          break;
        case r'max_consecutive_failures':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.maxConsecutiveFailures = valueDes;
          break;
        case r'n_max_iterations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nMaxIterations = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningStoppingConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningStoppingConfigBuilder();
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

