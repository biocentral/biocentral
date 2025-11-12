//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'import_dataset_request.g.dart';

/// ImportDatasetRequest
///
/// Properties:
/// * [format] 
/// * [dataset] 
@BuiltValue()
abstract class ImportDatasetRequest implements Built<ImportDatasetRequest, ImportDatasetRequestBuilder> {
  @BuiltValueField(wireName: r'format')
  String get format;

  @BuiltValueField(wireName: r'dataset')
  String get dataset;

  ImportDatasetRequest._();

  factory ImportDatasetRequest([void updates(ImportDatasetRequestBuilder b)]) = _$ImportDatasetRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImportDatasetRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImportDatasetRequest> get serializer => _$ImportDatasetRequestSerializer();
}

class _$ImportDatasetRequestSerializer implements PrimitiveSerializer<ImportDatasetRequest> {
  @override
  final Iterable<Type> types = const [ImportDatasetRequest, _$ImportDatasetRequest];

  @override
  final String wireName = r'ImportDatasetRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImportDatasetRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'format';
    yield serializers.serialize(
      object.format,
      specifiedType: const FullType(String),
    );
    yield r'dataset';
    yield serializers.serialize(
      object.dataset,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ImportDatasetRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ImportDatasetRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.format = valueDes;
          break;
        case r'dataset':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dataset = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ImportDatasetRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImportDatasetRequestBuilder();
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

