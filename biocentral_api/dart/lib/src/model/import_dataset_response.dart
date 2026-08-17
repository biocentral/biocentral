//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'import_dataset_response.g.dart';

/// ImportDatasetResponse
///
/// Properties:
/// * [importedDataset] 
@BuiltValue()
abstract class ImportDatasetResponse implements Built<ImportDatasetResponse, ImportDatasetResponseBuilder> {
  @BuiltValueField(wireName: r'imported_dataset')
  BuiltMap<String, JsonObject?> get importedDataset;

  ImportDatasetResponse._();

  factory ImportDatasetResponse([void updates(ImportDatasetResponseBuilder b)]) = _$ImportDatasetResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImportDatasetResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImportDatasetResponse> get serializer => _$ImportDatasetResponseSerializer();
}

class _$ImportDatasetResponseSerializer implements PrimitiveSerializer<ImportDatasetResponse> {
  @override
  final Iterable<Type> types = const [ImportDatasetResponse, _$ImportDatasetResponse];

  @override
  final String wireName = r'ImportDatasetResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImportDatasetResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'imported_dataset';
    yield serializers.serialize(
      object.importedDataset,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ImportDatasetResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ImportDatasetResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'imported_dataset':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.importedDataset.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ImportDatasetResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImportDatasetResponseBuilder();
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

