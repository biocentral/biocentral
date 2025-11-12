//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/plm_eval_information.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plm_eval_information_response.g.dart';

/// PLMEvalInformationResponse
///
/// Properties:
/// * [info] - Information about the PLM evaluation process
@BuiltValue()
abstract class PLMEvalInformationResponse implements Built<PLMEvalInformationResponse, PLMEvalInformationResponseBuilder> {
  /// Information about the PLM evaluation process
  @BuiltValueField(wireName: r'info')
  PLMEvalInformation get info;

  PLMEvalInformationResponse._();

  factory PLMEvalInformationResponse([void updates(PLMEvalInformationResponseBuilder b)]) = _$PLMEvalInformationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PLMEvalInformationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PLMEvalInformationResponse> get serializer => _$PLMEvalInformationResponseSerializer();
}

class _$PLMEvalInformationResponseSerializer implements PrimitiveSerializer<PLMEvalInformationResponse> {
  @override
  final Iterable<Type> types = const [PLMEvalInformationResponse, _$PLMEvalInformationResponse];

  @override
  final String wireName = r'PLMEvalInformationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PLMEvalInformationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'info';
    yield serializers.serialize(
      object.info,
      specifiedType: const FullType(PLMEvalInformation),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PLMEvalInformationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PLMEvalInformationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'info':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PLMEvalInformation),
          ) as PLMEvalInformation;
          result.info.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PLMEvalInformationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PLMEvalInformationResponseBuilder();
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

