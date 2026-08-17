//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/active_learning_optimization_mode.dart';
import 'package:biocentral_api/src/model/active_learning_model_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_screening_campaign_config.g.dart';

/// Configuration for an active learning screening campaign
///
/// Properties:
/// * [embedderName] - Name of the embedder model to use
/// * [name] - Name of the active learning campaign
/// * [modelType] - Type of model to use
/// * [optimizationMode] - Optimization mode selection
/// * [seed] - Random seed for reproducibility.
/// * [targetLb] - Lower bound of the target value to optimize (mode: INTERVAL)
/// * [targetUb] - Upper bound of the target value to optimize (mode: INTERVAL)
/// * [targetValue] - Target value to optimize (mode: VALUE)
/// * [discreteTargets] - List of target labels (must be subset of all labels)
@BuiltValue()
abstract class ActiveLearningScreeningCampaignConfig implements Built<ActiveLearningScreeningCampaignConfig, ActiveLearningScreeningCampaignConfigBuilder> {
  /// Name of the embedder model to use
  @BuiltValueField(wireName: r'embedder_name')
  String get embedderName;

  /// Name of the active learning campaign
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Type of model to use
  @BuiltValueField(wireName: r'model_type')
  ActiveLearningModelType get modelType;
  // enum modelTypeEnum {  GAUSSIAN_PROCESS,  FNN_MCD,  RANDOM,  };

  /// Optimization mode selection
  @BuiltValueField(wireName: r'optimization_mode')
  ActiveLearningOptimizationMode get optimizationMode;
  // enum optimizationModeEnum {  INTERVAL,  VALUE,  MAXIMIZE,  MINIMIZE,  DISCRETE,  };

  /// Random seed for reproducibility.
  @BuiltValueField(wireName: r'seed')
  int? get seed;

  /// Lower bound of the target value to optimize (mode: INTERVAL)
  @BuiltValueField(wireName: r'target_lb')
  num? get targetLb;

  /// Upper bound of the target value to optimize (mode: INTERVAL)
  @BuiltValueField(wireName: r'target_ub')
  num? get targetUb;

  /// Target value to optimize (mode: VALUE)
  @BuiltValueField(wireName: r'target_value')
  num? get targetValue;

  /// List of target labels (must be subset of all labels)
  @BuiltValueField(wireName: r'discrete_targets')
  BuiltList<String>? get discreteTargets;

  ActiveLearningScreeningCampaignConfig._();

  factory ActiveLearningScreeningCampaignConfig([void updates(ActiveLearningScreeningCampaignConfigBuilder b)]) = _$ActiveLearningScreeningCampaignConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningScreeningCampaignConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningScreeningCampaignConfig> get serializer => _$ActiveLearningScreeningCampaignConfigSerializer();
}

class _$ActiveLearningScreeningCampaignConfigSerializer implements PrimitiveSerializer<ActiveLearningScreeningCampaignConfig> {
  @override
  final Iterable<Type> types = const [ActiveLearningScreeningCampaignConfig, _$ActiveLearningScreeningCampaignConfig];

  @override
  final String wireName = r'ActiveLearningScreeningCampaignConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningScreeningCampaignConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'embedder_name';
    yield serializers.serialize(
      object.embedderName,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'model_type';
    yield serializers.serialize(
      object.modelType,
      specifiedType: const FullType(ActiveLearningModelType),
    );
    yield r'optimization_mode';
    yield serializers.serialize(
      object.optimizationMode,
      specifiedType: const FullType(ActiveLearningOptimizationMode),
    );
    if (object.seed != null) {
      yield r'seed';
      yield serializers.serialize(
        object.seed,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.targetLb != null) {
      yield r'target_lb';
      yield serializers.serialize(
        object.targetLb,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.targetUb != null) {
      yield r'target_ub';
      yield serializers.serialize(
        object.targetUb,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.targetValue != null) {
      yield r'target_value';
      yield serializers.serialize(
        object.targetValue,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.discreteTargets != null) {
      yield r'discrete_targets';
      yield serializers.serialize(
        object.discreteTargets,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningScreeningCampaignConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningScreeningCampaignConfigBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'embedder_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.embedderName = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'model_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningModelType),
          ) as ActiveLearningModelType;
          result.modelType = valueDes;
          break;
        case r'optimization_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningOptimizationMode),
          ) as ActiveLearningOptimizationMode;
          result.optimizationMode = valueDes;
          break;
        case r'seed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.seed = valueDes;
          break;
        case r'target_lb':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.targetLb = valueDes;
          break;
        case r'target_ub':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.targetUb = valueDes;
          break;
        case r'target_value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.targetValue = valueDes;
          break;
        case r'discrete_targets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.discreteTargets.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningScreeningCampaignConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningScreeningCampaignConfigBuilder();
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

