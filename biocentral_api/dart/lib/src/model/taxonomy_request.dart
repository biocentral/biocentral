//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'taxonomy_request.g.dart';

/// TaxonomyRequest
///
/// Properties:
/// * [taxonomyIds] - List of taxonomy ids
@BuiltValue()
abstract class TaxonomyRequest implements Built<TaxonomyRequest, TaxonomyRequestBuilder> {
  /// List of taxonomy ids
  @BuiltValueField(wireName: r'taxonomy_ids')
  BuiltList<int> get taxonomyIds;

  TaxonomyRequest._();

  factory TaxonomyRequest([void updates(TaxonomyRequestBuilder b)]) = _$TaxonomyRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxonomyRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxonomyRequest> get serializer => _$TaxonomyRequestSerializer();
}

class _$TaxonomyRequestSerializer implements PrimitiveSerializer<TaxonomyRequest> {
  @override
  final Iterable<Type> types = const [TaxonomyRequest, _$TaxonomyRequest];

  @override
  final String wireName = r'TaxonomyRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxonomyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'taxonomy_ids';
    yield serializers.serialize(
      object.taxonomyIds,
      specifiedType: const FullType(BuiltList, [FullType(int)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TaxonomyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TaxonomyRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'taxonomy_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(int)]),
          ) as BuiltList<int>;
          result.taxonomyIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TaxonomyRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxonomyRequestBuilder();
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

