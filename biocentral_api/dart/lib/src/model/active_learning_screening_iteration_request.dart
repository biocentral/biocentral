//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/active_learning_screening_campaign_config.dart';
import 'package:biocentral_api/src/model/active_learning_screening_iteration_config.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_screening_iteration_request.g.dart';

/// Request model for an active learning screening iteration
///
/// Properties:
/// * [campaignConfig] - Campaign configuration
/// * [iterationConfig] - Iteration configuration
@BuiltValue()
abstract class ActiveLearningScreeningIterationRequest implements Built<ActiveLearningScreeningIterationRequest, ActiveLearningScreeningIterationRequestBuilder> {
  /// Campaign configuration
  @BuiltValueField(wireName: r'campaign_config')
  ActiveLearningScreeningCampaignConfig get campaignConfig;

  /// Iteration configuration
  @BuiltValueField(wireName: r'iteration_config')
  ActiveLearningScreeningIterationConfig get iterationConfig;

  ActiveLearningScreeningIterationRequest._();

  factory ActiveLearningScreeningIterationRequest([void updates(ActiveLearningScreeningIterationRequestBuilder b)]) = _$ActiveLearningScreeningIterationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActiveLearningScreeningIterationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActiveLearningScreeningIterationRequest> get serializer => _$ActiveLearningScreeningIterationRequestSerializer();
}

class _$ActiveLearningScreeningIterationRequestSerializer implements PrimitiveSerializer<ActiveLearningScreeningIterationRequest> {
  @override
  final Iterable<Type> types = const [ActiveLearningScreeningIterationRequest, _$ActiveLearningScreeningIterationRequest];

  @override
  final String wireName = r'ActiveLearningScreeningIterationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActiveLearningScreeningIterationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'campaign_config';
    yield serializers.serialize(
      object.campaignConfig,
      specifiedType: const FullType(ActiveLearningScreeningCampaignConfig),
    );
    yield r'iteration_config';
    yield serializers.serialize(
      object.iterationConfig,
      specifiedType: const FullType(ActiveLearningScreeningIterationConfig),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActiveLearningScreeningIterationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActiveLearningScreeningIterationRequestBuilder result,
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
        case r'iteration_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ActiveLearningScreeningIterationConfig),
          ) as ActiveLearningScreeningIterationConfig;
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
  ActiveLearningScreeningIterationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActiveLearningScreeningIterationRequestBuilder();
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

