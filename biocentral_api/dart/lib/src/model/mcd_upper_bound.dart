//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'mcd_upper_bound.g.dart';

/// Monte-Carlo-Dropout upper bound(s)
@BuiltValue()
abstract class McdUpperBound implements Built<McdUpperBound, McdUpperBoundBuilder> {
  /// Any Of [BuiltList<num>], [num]
  AnyOf get anyOf;

  McdUpperBound._();

  factory McdUpperBound([void updates(McdUpperBoundBuilder b)]) = _$McdUpperBound;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(McdUpperBoundBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<McdUpperBound> get serializer => _$McdUpperBoundSerializer();
}

class _$McdUpperBoundSerializer implements PrimitiveSerializer<McdUpperBound> {
  @override
  final Iterable<Type> types = const [McdUpperBound, _$McdUpperBound];

  @override
  final String wireName = r'McdUpperBound';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    McdUpperBound object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    McdUpperBound object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  McdUpperBound deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = McdUpperBoundBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(BuiltList, [FullType(num)]), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}
