//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/active_learning_screening_campaign_config.dart';
import 'package:biocentral_api/src/model/active_learning_screening_simulation_config.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_screening_simulation_request.g.dart';

/// Request model for an active learning screening simulation
///
/// Properties:
/// * [campaignConfig] - Campaign configuration
/// * [simulationConfig] - Simulation configuration
@BuiltValue()
abstract class ActiveLearningScreeningSimulationRequest implements Built<ActiveLearningScreeningSimulationRequest, ActiveLearningScreeningSimulationRequestBuilder> {
  /// Campaign configuration
  @BuiltValueField(wireName: r'campaign_config')
  ActiveLearningScreeningCampaignConfig get campaignConfig;

  /// Simulation configuration
  @BuiltValueField(wireName: r'simulation_config')
  ActiveLearningScreeningSimulationConfig get simulationConfig;

  ActiveLearningScreeningSimulationRequest._();

  factory ActiveLearningScreeningSimulationRequest([void updates(ActiveLearningScreeningSimulationRequestBuilder b)]) = _$ActiveLearningScreeningSimulationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningScreeningSimulationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningScreeningSimulationRequest> get serializer => _$ActiveLearningScreeningSimulationRequestSerializer();
}

class _$ActiveLearningScreeningSimulationRequestSerializer implements PrimitiveSerializer<ActiveLearningScreeningSimulationRequest> {
  @override
  final Iterable<Type> types = const [ActiveLearningScreeningSimulationRequest, _$ActiveLearningScreeningSimulationRequest];

  @override
  final String wireName = r'ActiveLearningScreeningSimulationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningScreeningSimulationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'campaign_config';
    yield serializers.serialize(
      object.campaignConfig,
      specifiedType: const FullType(ActiveLearningScreeningCampaignConfig),
    );
    yield r'simulation_config';
    yield serializers.serialize(
      object.simulationConfig,
      specifiedType: const FullType(ActiveLearningScreeningSimulationConfig),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningScreeningSimulationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningScreeningSimulationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'campaign_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningScreeningCampaignConfig),
          ) as ActiveLearningScreeningCampaignConfig;
          result.campaignConfig.replace(valueDes);
          break;
        case r'simulation_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningScreeningSimulationConfig),
          ) as ActiveLearningScreeningSimulationConfig;
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
  ActiveLearningScreeningSimulationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningScreeningSimulationRequestBuilder();
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

