//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'start_inference_request.g.dart';

/// Request model for starting inference
///
/// Properties:
/// * [modelHash] - Hash identifier for the trained model to use for inference
/// * [sequenceData] - Sequence data for inference (seq_id -> sequence)
@BuiltValue()
abstract class StartInferenceRequest implements Built<StartInferenceRequest, StartInferenceRequestBuilder> {
  /// Hash identifier for the trained model to use for inference
  @BuiltValueField(wireName: r'model_hash')
  String get modelHash;

  /// Sequence data for inference (seq_id -> sequence)
  @BuiltValueField(wireName: r'sequence_data')
  BuiltMap<String, String> get sequenceData;

  StartInferenceRequest._();

  factory StartInferenceRequest([void updates(StartInferenceRequestBuilder b)]) = _$StartInferenceRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StartInferenceRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StartInferenceRequest> get serializer => _$StartInferenceRequestSerializer();
}

class _$StartInferenceRequestSerializer implements PrimitiveSerializer<StartInferenceRequest> {
  @override
  final Iterable<Type> types = const [StartInferenceRequest, _$StartInferenceRequest];

  @override
  final String wireName = r'StartInferenceRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StartInferenceRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'model_hash';
    yield serializers.serialize(
      object.modelHash,
      specifiedType: const FullType(String),
    );
    yield r'sequence_data';
    yield serializers.serialize(
      object.sequenceData,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StartInferenceRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StartInferenceRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'model_hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.modelHash = valueDes;
          break;
        case r'sequence_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.sequenceData.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StartInferenceRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StartInferenceRequestBuilder();
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

