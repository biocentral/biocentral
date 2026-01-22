//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:biocentral_api/src/model/active_learning_campaign_config.dart';
// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/active_learning_simulation_config.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_simulation_request.g.dart';

/// Request model for an active learning simulation
///
/// Properties:
/// * [campaignConfig] - Campaign configuration
/// * [simulationConfig] - Simulation configuration
@BuiltValue()
abstract class ActiveLearningSimulationRequest implements Built<ActiveLearningSimulationRequest, ActiveLearningSimulationRequestBuilder> {
  /// Campaign configuration
  @BuiltValueField(wireName: r'campaign_config')
  ActiveLearningCampaignConfig get campaignConfig;

  /// Simulation configuration
  @BuiltValueField(wireName: r'simulation_config')
  ActiveLearningSimulationConfig get simulationConfig;

  ActiveLearningSimulationRequest._();

  factory ActiveLearningSimulationRequest([void updates(ActiveLearningSimulationRequestBuilder b)]) = _$ActiveLearningSimulationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningSimulationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningSimulationRequest> get serializer => _$ActiveLearningSimulationRequestSerializer();
}

class _$ActiveLearningSimulationRequestSerializer implements PrimitiveSerializer<ActiveLearningSimulationRequest> {
  @override
  final Iterable<Type> types = const [ActiveLearningSimulationRequest, _$ActiveLearningSimulationRequest];

  @override
  final String wireName = r'ActiveLearningSimulationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningSimulationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'campaign_config';
    yield serializers.serialize(
      object.campaignConfig,
      specifiedType: const FullType(ActiveLearningCampaignConfig),
    );
    yield r'simulation_config';
    yield serializers.serialize(
      object.simulationConfig,
      specifiedType: const FullType(ActiveLearningSimulationConfig),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningSimulationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningSimulationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'campaign_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningCampaignConfig),
          ) as ActiveLearningCampaignConfig;
          result.campaignConfig.replace(valueDes);
          break;
        case r'simulation_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningSimulationConfig),
          ) as ActiveLearningSimulationConfig;
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
  ActiveLearningSimulationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningSimulationRequestBuilder();
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

