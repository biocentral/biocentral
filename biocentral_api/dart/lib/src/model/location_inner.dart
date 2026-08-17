//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'location_inner.g.dart';

/// LocationInner
@BuiltValue()
abstract class LocationInner implements Built<LocationInner, LocationInnerBuilder> {
  /// Any Of [String], [int]
  AnyOf get anyOf;

  LocationInner._();

  factory LocationInner([void updates(LocationInnerBuilder b)]) = _$LocationInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LocationInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LocationInner> get serializer => _$LocationInnerSerializer();
}

class _$LocationInnerSerializer implements PrimitiveSerializer<LocationInner> {
  @override
  final Iterable<Type> types = const [LocationInner, _$LocationInner];

  @override
  final String wireName = r'LocationInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LocationInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    LocationInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  LocationInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LocationInnerBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(String), FullType(int), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

