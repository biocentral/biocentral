//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'mcd_lower_bound.g.dart';

/// Monte-Carlo-Dropout lower bound(s)
@BuiltValue()
abstract class McdLowerBound implements Built<McdLowerBound, McdLowerBoundBuilder> {
  /// Any Of [BuiltList<num>], [num]
  AnyOf get anyOf;

  McdLowerBound._();

  factory McdLowerBound([void updates(McdLowerBoundBuilder b)]) = _$McdLowerBound;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(McdLowerBoundBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<McdLowerBound> get serializer => _$McdLowerBoundSerializer();
}

class _$McdLowerBoundSerializer implements PrimitiveSerializer<McdLowerBound> {
  @override
  final Iterable<Type> types = const [McdLowerBound, _$McdLowerBound];

  @override
  final String wireName = r'McdLowerBound';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    McdLowerBound object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    McdLowerBound object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  McdLowerBound deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = McdLowerBoundBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(BuiltList, [FullType(num)]), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}
