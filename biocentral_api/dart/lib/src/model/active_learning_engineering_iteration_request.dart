//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/active_learning_engineering_campaign_config.dart';
import 'package:biocentral_api/src/model/active_learning_engineering_iteration_config.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_engineering_iteration_request.g.dart';

/// Request model for an active learning engineering iteration
///
/// Properties:
/// * [campaignConfig] - Engineering campaign configuration
/// * [iterationConfig] - Engineering iteration configuration
@BuiltValue()
abstract class ActiveLearningEngineeringIterationRequest implements Built<ActiveLearningEngineeringIterationRequest, ActiveLearningEngineeringIterationRequestBuilder> {
  /// Engineering campaign configuration
  @BuiltValueField(wireName: r'campaign_config')
  ActiveLearningEngineeringCampaignConfig get campaignConfig;

  /// Engineering iteration configuration
  @BuiltValueField(wireName: r'iteration_config')
  ActiveLearningEngineeringIterationConfig get iterationConfig;

  ActiveLearningEngineeringIterationRequest._();

  factory ActiveLearningEngineeringIterationRequest([void updates(ActiveLearningEngineeringIterationRequestBuilder b)]) = _$ActiveLearningEngineeringIterationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningEngineeringIterationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningEngineeringIterationRequest> get serializer => _$ActiveLearningEngineeringIterationRequestSerializer();
}

class _$ActiveLearningEngineeringIterationRequestSerializer implements PrimitiveSerializer<ActiveLearningEngineeringIterationRequest> {
  @override
  final Iterable<Type> types = const [ActiveLearningEngineeringIterationRequest, _$ActiveLearningEngineeringIterationRequest];

  @override
  final String wireName = r'ActiveLearningEngineeringIterationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningEngineeringIterationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'campaign_config';
    yield serializers.serialize(
      object.campaignConfig,
      specifiedType: const FullType(ActiveLearningEngineeringCampaignConfig),
    );
    yield r'iteration_config';
    yield serializers.serialize(
      object.iterationConfig,
      specifiedType: const FullType(ActiveLearningEngineeringIterationConfig),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningEngineeringIterationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningEngineeringIterationRequestBuilder result,
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
        case r'iteration_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningEngineeringIterationConfig),
          ) as ActiveLearningEngineeringIterationConfig;
          result.iterationConfig.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActiveLearningEngineeringIterationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningEngineeringIterationRequestBuilder();
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
