//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'output_data.g.dart';

/// OutputData
///
/// Properties:
/// * [config] 
/// * [derivedValues] 
/// * [splitSpecificValues] 
/// * [trainingIteration] 
/// * [testResults] 
/// * [predictions] 
@BuiltValue()
abstract class OutputData implements Built<OutputData, OutputDataBuilder> {
  @BuiltValueField(wireName: r'config')
  BuiltMap<String, JsonObject?>? get config;

  @BuiltValueField(wireName: r'derived_values')
  BuiltMap<String, JsonObject?>? get derivedValues;

  @BuiltValueField(wireName: r'split_specific_values')
  BuiltMap<String, JsonObject?>? get splitSpecificValues;

  @BuiltValueField(wireName: r'training_iteration')
  BuiltList<JsonObject?>? get trainingIteration;

  @BuiltValueField(wireName: r'test_results')
  BuiltMap<String, JsonObject?>? get testResults;

  @BuiltValueField(wireName: r'predictions')
  BuiltMap<String, JsonObject?>? get predictions;

  OutputData._();

  factory OutputData([void updates(OutputDataBuilder b)]) = _$OutputData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OutputDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OutputData> get serializer => _$OutputDataSerializer();
}

class _$OutputDataSerializer implements PrimitiveSerializer<OutputData> {
  @override
  final Iterable<Type> types = const [OutputData, _$OutputData];

  @override
  final String wireName = r'OutputData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OutputData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.config != null) {
      yield r'config';
      yield serializers.serialize(
        object.config,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.derivedValues != null) {
      yield r'derived_values';
      yield serializers.serialize(
        object.derivedValues,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.splitSpecificValues != null) {
      yield r'split_specific_values';
      yield serializers.serialize(
        object.splitSpecificValues,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.trainingIteration != null) {
      yield r'training_iteration';
      yield serializers.serialize(
        object.trainingIteration,
        specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
      );
    }
    if (object.testResults != null) {
      yield r'test_results';
      yield serializers.serialize(
        object.testResults,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.predictions != null) {
      yield r'predictions';
      yield serializers.serialize(
        object.predictions,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OutputData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OutputDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.config.replace(valueDes);
          break;
        case r'derived_values':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.derivedValues.replace(valueDes);
          break;
        case r'split_specific_values':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.splitSpecificValues.replace(valueDes);
          break;
        case r'training_iteration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>?;
          if (valueDes == null) continue;
          result.trainingIteration.replace(valueDes);
          break;
        case r'test_results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.testResults.replace(valueDes);
          break;
        case r'predictions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.predictions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OutputData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OutputDataBuilder();
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

