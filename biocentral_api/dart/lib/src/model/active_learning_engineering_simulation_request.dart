//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/active_learning_engineering_campaign_config.dart';
import 'package:biocentral_api/src/model/active_learning_engineering_simulation_config.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_engineering_simulation_request.g.dart';

/// Request model for an active learning engineering simulation
///
/// Properties:
/// * [campaignConfig] - Engineering campaign configuration
/// * [simulationConfig] - Simulation configuration
@BuiltValue()
abstract class ActiveLearningEngineeringSimulationRequest implements Built<ActiveLearningEngineeringSimulationRequest, ActiveLearningEngineeringSimulationRequestBuilder> {
  /// Engineering campaign configuration
  @BuiltValueField(wireName: r'campaign_config')
  ActiveLearningEngineeringCampaignConfig get campaignConfig;

  /// Simulation configuration
  @BuiltValueField(wireName: r'simulation_config')
  ActiveLearningEngineeringSimulationConfig get simulationConfig;

  ActiveLearningEngineeringSimulationRequest._();

  factory ActiveLearningEngineeringSimulationRequest([void updates(ActiveLearningEngineeringSimulationRequestBuilder b)]) = _$ActiveLearningEngineeringSimulationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningEngineeringSimulationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningEngineeringSimulationRequest> get serializer => _$ActiveLearningEngineeringSimulationRequestSerializer();
}

class _$ActiveLearningEngineeringSimulationRequestSerializer implements PrimitiveSerializer<ActiveLearningEngineeringSimulationRequest> {
  @override
  final Iterable<Type> types = const [ActiveLearningEngineeringSimulationRequest, _$ActiveLearningEngineeringSimulationRequest];

  @override
  final String wireName = r'ActiveLearningEngineeringSimulationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningEngineeringSimulationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'campaign_config';
    yield serializers.serialize(
      object.campaignConfig,
      specifiedType: const FullType(ActiveLearningEngineeringCampaignConfig),
    );
    yield r'simulation_config';
    yield serializers.serialize(
      object.simulationConfig,
      specifiedType: const FullType(ActiveLearningEngineeringSimulationConfig),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningEngineeringSimulationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningEngineeringSimulationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'campaign_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningEngineeringCampaignConfig),
          ) as ActiveLearningEngineeringCampaignConfig;
          result.campaignConfig.replace(valueDes);
          break;
        case r'simulation_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningEngineeringSimulationConfig),
          ) as ActiveLearningEngineeringSimulationConfig;
          result.simulationConfig.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningEngineeringSimulationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningEngineeringSimulationRequestBuilder();
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

