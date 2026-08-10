//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'mcd_std.g.dart';

/// Monte-Carlo-Dropout standard deviation(s)
@BuiltValue()
abstract class McdStd implements Built<McdStd, McdStdBuilder> {
  /// Any Of [BuiltList<num>], [num]
  AnyOf get anyOf;

  McdStd._();

  factory McdStd([void updates(McdStdBuilder b)]) = _$McdStd;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(McdStdBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<McdStd> get serializer => _$McdStdSerializer();
}

class _$McdStdSerializer implements PrimitiveSerializer<McdStd> {
  @override
  final Iterable<Type> types = const [McdStd, _$McdStd];

  @override
  final String wireName = r'McdStd';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    McdStd object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    McdStd object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  McdStd deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = McdStdBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(BuiltList, [FullType(num)]), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}
