//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'prediction_request.g.dart';

/// PredictionRequest
///
/// Properties:
/// * [modelNames] - List of model names to use for prediction
/// * [sequenceInput] - Dictionary mapping sequence IDs to protein sequences
@BuiltValue()
abstract class PredictionRequest implements Built<PredictionRequest, PredictionRequestBuilder> {
  /// List of model names to use for prediction
  @BuiltValueField(wireName: r'model_names')
  BuiltList<String> get modelNames;

  /// Dictionary mapping sequence IDs to protein sequences
  @BuiltValueField(wireName: r'sequence_input')
  BuiltMap<String, String> get sequenceInput;

  PredictionRequest._();

  factory PredictionRequest([void updates(PredictionRequestBuilder b)]) = _$PredictionRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PredictionRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PredictionRequest> get serializer => _$PredictionRequestSerializer();
}

class _$PredictionRequestSerializer implements PrimitiveSerializer<PredictionRequest> {
  @override
  final Iterable<Type> types = const [PredictionRequest, _$PredictionRequest];

  @override
  final String wireName = r'PredictionRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PredictionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'model_names';
    yield serializers.serialize(
      object.modelNames,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'sequence_input';
    yield serializers.serialize(
      object.sequenceInput,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PredictionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PredictionRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'model_names':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.modelNames.replace(valueDes);
          break;
        case r'sequence_input':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.sequenceInput.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PredictionRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PredictionRequestBuilder();
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

