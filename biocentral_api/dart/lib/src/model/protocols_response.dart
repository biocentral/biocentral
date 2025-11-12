//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'protocols_response.g.dart';

/// Response model for available protocols
///
/// Properties:
/// * [protocols] - List of available protocol names
@BuiltValue()
abstract class ProtocolsResponse implements Built<ProtocolsResponse, ProtocolsResponseBuilder> {
  /// List of available protocol names
  @BuiltValueField(wireName: r'protocols')
  BuiltList<String> get protocols;

  ProtocolsResponse._();

  factory ProtocolsResponse([void updates(ProtocolsResponseBuilder b)]) = _$ProtocolsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProtocolsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProtocolsResponse> get serializer => _$ProtocolsResponseSerializer();
}

class _$ProtocolsResponseSerializer implements PrimitiveSerializer<ProtocolsResponse> {
  @override
  final Iterable<Type> types = const [ProtocolsResponse, _$ProtocolsResponse];

  @override
  final String wireName = r'ProtocolsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProtocolsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'protocols';
    yield serializers.serialize(
      object.protocols,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProtocolsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProtocolsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'protocols':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.protocols.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProtocolsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProtocolsResponseBuilder();
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

