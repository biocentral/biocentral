//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plm_eval_autoeval_request.g.dart';

/// PLMEvalAutoevalRequest
///
/// Properties:
/// * [modelId] - Huggingface model identifier
/// * [onnxFile] 
/// * [tokenizerConfig] 
@BuiltValue()
abstract class PLMEvalAutoevalRequest implements Built<PLMEvalAutoevalRequest, PLMEvalAutoevalRequestBuilder> {
  /// Huggingface model identifier
  @BuiltValueField(wireName: r'model_id')
  String get modelId;

  @BuiltValueField(wireName: r'onnx_file')
  String? get onnxFile;

  @BuiltValueField(wireName: r'tokenizer_config')
  String? get tokenizerConfig;

  PLMEvalAutoevalRequest._();

  factory PLMEvalAutoevalRequest([void updates(PLMEvalAutoevalRequestBuilder b)]) = _$PLMEvalAutoevalRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PLMEvalAutoevalRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PLMEvalAutoevalRequest> get serializer => _$PLMEvalAutoevalRequestSerializer();
}

class _$PLMEvalAutoevalRequestSerializer implements PrimitiveSerializer<PLMEvalAutoevalRequest> {
  @override
  final Iterable<Type> types = const [PLMEvalAutoevalRequest, _$PLMEvalAutoevalRequest];

  @override
  final String wireName = r'PLMEvalAutoevalRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PLMEvalAutoevalRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'model_id';
    yield serializers.serialize(
      object.modelId,
      specifiedType: const FullType(String),
    );
    yield r'onnx_file';
    yield object.onnxFile == null ? null : serializers.serialize(
      object.onnxFile,
      specifiedType: const FullType.nullable(String),
    );
    yield r'tokenizer_config';
    yield object.tokenizerConfig == null ? null : serializers.serialize(
      object.tokenizerConfig,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PLMEvalAutoevalRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PLMEvalAutoevalRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'model_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.modelId = valueDes;
          break;
        case r'onnx_file':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.onnxFile = valueDes;
          break;
        case r'tokenizer_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tokenizerConfig = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PLMEvalAutoevalRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PLMEvalAutoevalRequestBuilder();
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

