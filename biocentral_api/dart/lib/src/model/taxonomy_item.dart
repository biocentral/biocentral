//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'taxonomy_item.g.dart';

/// TaxonomyItem
///
/// Properties:
/// * [taxonomyId] 
/// * [name] 
/// * [family] 
@BuiltValue()
abstract class TaxonomyItem implements Built<TaxonomyItem, TaxonomyItemBuilder> {
  @BuiltValueField(wireName: r'taxonomy_id')
  int get taxonomyId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'family')
  String get family;

  TaxonomyItem._();

  factory TaxonomyItem([void updates(TaxonomyItemBuilder b)]) = _$TaxonomyItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxonomyItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxonomyItem> get serializer => _$TaxonomyItemSerializer();
}

class _$TaxonomyItemSerializer implements PrimitiveSerializer<TaxonomyItem> {
  @override
  final Iterable<Type> types = const [TaxonomyItem, _$TaxonomyItem];

  @override
  final String wireName = r'TaxonomyItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxonomyItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'taxonomy_id';
    yield serializers.serialize(
      object.taxonomyId,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'family';
    yield serializers.serialize(
      object.family,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TaxonomyItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TaxonomyItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'taxonomy_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.taxonomyId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'family':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.family = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TaxonomyItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxonomyItemBuilder();
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

