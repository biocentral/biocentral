//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'mcd_mean.g.dart';

/// Monte-Carlo-Dropout mean(s)
@BuiltValue()
abstract class McdMean implements Built<McdMean, McdMeanBuilder> {
  /// Any Of [BuiltList<num>], [num]
  AnyOf get anyOf;

  McdMean._();

  factory McdMean([void updates(McdMeanBuilder b)]) = _$McdMean;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(McdMeanBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<McdMean> get serializer => _$McdMeanSerializer();
}

class _$McdMeanSerializer implements PrimitiveSerializer<McdMean> {
  @override
  final Iterable<Type> types = const [McdMean, _$McdMean];

  @override
  final String wireName = r'McdMean';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    McdMean object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    McdMean object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  McdMean deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = McdMeanBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(BuiltList, [FullType(num)]), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

