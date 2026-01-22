//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:biocentral_api/src/model/sequence_training_data.dart';
// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';

part 'start_training_request.g.dart';

/// StartTrainingRequest
///
/// Properties:
/// * [configDict] - Biotrainer configuration
/// * [trainingData] - List of sequence training data
@BuiltValue()
abstract class StartTrainingRequest implements Built<StartTrainingRequest, StartTrainingRequestBuilder> {
  /// Biotrainer configuration
  @BuiltValueField(wireName: r'config_dict')
  BuiltMap<String, JsonObject?> get configDict;

  /// List of sequence training data
  @BuiltValueField(wireName: r'training_data')
  BuiltList<SequenceTrainingData> get trainingData;

  StartTrainingRequest._();

  factory StartTrainingRequest([void updates(StartTrainingRequestBuilder b)]) = _$StartTrainingRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StartTrainingRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StartTrainingRequest> get serializer => _$StartTrainingRequestSerializer();
}

class _$StartTrainingRequestSerializer implements PrimitiveSerializer<StartTrainingRequest> {
  @override
  final Iterable<Type> types = const [StartTrainingRequest, _$StartTrainingRequest];

  @override
  final String wireName = r'StartTrainingRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StartTrainingRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'config_dict';
    yield serializers.serialize(
      object.configDict,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'training_data';
    yield serializers.serialize(
      object.trainingData,
      specifiedType: const FullType(BuiltList, [FullType(SequenceTrainingData)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StartTrainingRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StartTrainingRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'config_dict':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.configDict.replace(valueDes);
          break;
        case r'training_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SequenceTrainingData)]),
          ) as BuiltList<SequenceTrainingData>;
          result.trainingData.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StartTrainingRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StartTrainingRequestBuilder();
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

