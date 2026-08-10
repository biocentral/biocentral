//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/active_learning_optimization_mode.dart';
import 'package:biocentral_api/src/model/active_learning_model_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_engineering_campaign_config.g.dart';

/// Configuration for an active learning engineering campaign
///
/// Properties:
/// * [embedderName] - Name of the embedder model to use
/// * [name] - Name of the active learning campaign
/// * [modelType] - Type of model to use
/// * [optimizationMode] - Optimization mode selection
/// * [seed] - Random seed for reproducibility.
/// * [wildtypeSequence] - Wildtype sequence to engineer
@BuiltValue()
abstract class ActiveLearningEngineeringCampaignConfig implements Built<ActiveLearningEngineeringCampaignConfig, ActiveLearningEngineeringCampaignConfigBuilder> {
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

  /// Wildtype sequence to engineer
  @BuiltValueField(wireName: r'wildtype_sequence')
  String get wildtypeSequence;

  ActiveLearningEngineeringCampaignConfig._();

  factory ActiveLearningEngineeringCampaignConfig([void updates(ActiveLearningEngineeringCampaignConfigBuilder b)]) = _$ActiveLearningEngineeringCampaignConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningEngineeringCampaignConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningEngineeringCampaignConfig> get serializer => _$ActiveLearningEngineeringCampaignConfigSerializer();
}

class _$ActiveLearningEngineeringCampaignConfigSerializer implements PrimitiveSerializer<ActiveLearningEngineeringCampaignConfig> {
  @override
  final Iterable<Type> types = const [ActiveLearningEngineeringCampaignConfig, _$ActiveLearningEngineeringCampaignConfig];

  @override
  final String wireName = r'ActiveLearningEngineeringCampaignConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningEngineeringCampaignConfig object, {
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
    yield r'wildtype_sequence';
    yield serializers.serialize(
      object.wildtypeSequence,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningEngineeringCampaignConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningEngineeringCampaignConfigBuilder result,
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
        case r'wildtype_sequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.wildtypeSequence = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningEngineeringCampaignConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningEngineeringCampaignConfigBuilder();
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
