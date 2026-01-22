//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:biocentral_api/src/model/active_learning_campaign_config.dart';
// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/active_learning_iteration_config.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_iteration_request.g.dart';

/// Request model for an active learning iteration
///
/// Properties:
/// * [campaignConfig] - Campaign configuration
/// * [iterationConfig] - Iteration configuration
@BuiltValue()
abstract class ActiveLearningIterationRequest implements Built<ActiveLearningIterationRequest, ActiveLearningIterationRequestBuilder> {
  /// Campaign configuration
  @BuiltValueField(wireName: r'campaign_config')
  ActiveLearningCampaignConfig get campaignConfig;

  /// Iteration configuration
  @BuiltValueField(wireName: r'iteration_config')
  ActiveLearningIterationConfig get iterationConfig;

  ActiveLearningIterationRequest._();

  factory ActiveLearningIterationRequest([void updates(ActiveLearningIterationRequestBuilder b)]) = _$ActiveLearningIterationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningIterationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningIterationRequest> get serializer => _$ActiveLearningIterationRequestSerializer();
}

class _$ActiveLearningIterationRequestSerializer implements PrimitiveSerializer<ActiveLearningIterationRequest> {
  @override
  final Iterable<Type> types = const [ActiveLearningIterationRequest, _$ActiveLearningIterationRequest];

  @override
  final String wireName = r'ActiveLearningIterationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningIterationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'campaign_config';
    yield serializers.serialize(
      object.campaignConfig,
      specifiedType: const FullType(ActiveLearningCampaignConfig),
    );
    yield r'iteration_config';
    yield serializers.serialize(
      object.iterationConfig,
      specifiedType: const FullType(ActiveLearningIterationConfig),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningIterationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningIterationRequestBuilder result,
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
        case r'iteration_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningIterationConfig),
          ) as ActiveLearningIterationConfig;
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
  ActiveLearningIterationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningIterationRequestBuilder();
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

