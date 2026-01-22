//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:biocentral_api/src/model/taxonomy_item.dart';
// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'taxonomy_response.g.dart';

/// TaxonomyResponse
///
/// Properties:
/// * [taxonomy] - List of taxonomy lookup results
@BuiltValue()
abstract class TaxonomyResponse implements Built<TaxonomyResponse, TaxonomyResponseBuilder> {
  /// List of taxonomy lookup results
  @BuiltValueField(wireName: r'taxonomy')
  BuiltList<TaxonomyItem> get taxonomy;

  TaxonomyResponse._();

  factory TaxonomyResponse([void updates(TaxonomyResponseBuilder b)]) = _$TaxonomyResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxonomyResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxonomyResponse> get serializer => _$TaxonomyResponseSerializer();
}

class _$TaxonomyResponseSerializer implements PrimitiveSerializer<TaxonomyResponse> {
  @override
  final Iterable<Type> types = const [TaxonomyResponse, _$TaxonomyResponse];

  @override
  final String wireName = r'TaxonomyResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxonomyResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'taxonomy';
    yield serializers.serialize(
      object.taxonomy,
      specifiedType: const FullType(BuiltList, [FullType(TaxonomyItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TaxonomyResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TaxonomyResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'taxonomy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TaxonomyItem)]),
          ) as BuiltList<TaxonomyItem>;
          result.taxonomy.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TaxonomyResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxonomyResponseBuilder();
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

