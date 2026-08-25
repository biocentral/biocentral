//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'protein_annotations.g.dart';

/// ProteinAnnotations
///
/// Properties:
/// * [proteinId] 
@BuiltValue()
abstract class ProteinAnnotations implements Built<ProteinAnnotations, ProteinAnnotationsBuilder> {
  @BuiltValueField(wireName: r'protein_id')
  BuiltList<String> get proteinId;

  ProteinAnnotations._();

  factory ProteinAnnotations([void updates(ProteinAnnotationsBuilder b)]) = _$ProteinAnnotations;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProteinAnnotationsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProteinAnnotations> get serializer => _$ProteinAnnotationsSerializer();
}

class _$ProteinAnnotationsSerializer implements PrimitiveSerializer<ProteinAnnotations> {
  @override
  final Iterable<Type> types = const [ProteinAnnotations, _$ProteinAnnotations];

  @override
  final String wireName = r'ProteinAnnotations';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProteinAnnotations object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'protein_id';
    yield serializers.serialize(
      object.proteinId,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProteinAnnotations object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProteinAnnotationsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'protein_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.proteinId.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProteinAnnotations deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProteinAnnotationsBuilder();
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

