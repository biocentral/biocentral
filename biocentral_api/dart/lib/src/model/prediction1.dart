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

part 'prediction1.g.dart';

/// Predicted value
@BuiltValue()
abstract class Prediction1 implements Built<Prediction1, Prediction1Builder> {
  /// Any Of [BuiltList<JsonObject>], [String], [num]
  AnyOf get anyOf;

  Prediction1._();

  factory Prediction1([void updates(Prediction1Builder b)]) = _$Prediction1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Prediction1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Prediction1> get serializer => _$Prediction1Serializer();
}

class _$Prediction1Serializer implements PrimitiveSerializer<Prediction1> {
  @override
  final Iterable<Type> types = const [Prediction1, _$Prediction1];

  @override
  final String wireName = r'Prediction1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Prediction1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    Prediction1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  Prediction1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Prediction1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(String), FullType(num), FullType(BuiltList, [FullType.nullable(JsonObject)]), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}
