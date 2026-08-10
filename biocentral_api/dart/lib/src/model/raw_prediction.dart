//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'raw_prediction.g.dart';

/// Raw prediction of the model
@BuiltValue()
abstract class RawPrediction implements Built<RawPrediction, RawPredictionBuilder> {
  /// Any Of [BuiltList<JsonObject>], [String], [num]
  AnyOf get anyOf;

  RawPrediction._();

  factory RawPrediction([void updates(RawPredictionBuilder b)]) = _$RawPrediction;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RawPredictionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RawPrediction> get serializer => _$RawPredictionSerializer();
}

class _$RawPredictionSerializer implements PrimitiveSerializer<RawPrediction> {
  @override
  final Iterable<Type> types = const [RawPrediction, _$RawPrediction];

  @override
  final String wireName = r'RawPrediction';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RawPrediction object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    RawPrediction object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  RawPrediction deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RawPredictionBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(String), FullType(num), FullType(BuiltList, [FullType.nullable(JsonObject)]), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}
