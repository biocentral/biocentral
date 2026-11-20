//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/biotrainer_model_result.dart';
import 'package:biocentral_api/src/model/biotrainer_checkpoint.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'biocentral_model_result.g.dart';

/// BiocentralModelResult
///
/// Properties:
/// * [modelResult] - Biotrainer Model Result containing config, training and test results and metadata
/// * [loggingFile] - Logging output during model training
/// * [checkpoints] - List of bytes containing the checkpoint(s) of the model (name -> checkpoint)
/// * [onnxCheckpoint] - Bytes containing the ONNX-converted checkpoint(s) of the model (if available, name -> checkpoint)
@BuiltValue()
abstract class BiocentralModelResult implements Built<BiocentralModelResult, BiocentralModelResultBuilder> {
  /// Biotrainer Model Result containing config, training and test results and metadata
  @BuiltValueField(wireName: r'model_result')
  BiotrainerModelResult get modelResult;

  /// Logging output during model training
  @BuiltValueField(wireName: r'logging_file')
  String get loggingFile;

  /// List of bytes containing the checkpoint(s) of the model (name -> checkpoint)
  @BuiltValueField(wireName: r'checkpoints')
  BuiltList<BiotrainerCheckpoint> get checkpoints;

  /// Bytes containing the ONNX-converted checkpoint(s) of the model (if available, name -> checkpoint)
  @BuiltValueField(wireName: r'onnx_checkpoint')
  BuiltList<BiotrainerCheckpoint>? get onnxCheckpoint;

  BiocentralModelResult._();

  factory BiocentralModelResult([void updates(BiocentralModelResultBuilder b)]) = _$BiocentralModelResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BiocentralModelResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BiocentralModelResult> get serializer => _$BiocentralModelResultSerializer();
}

class _$BiocentralModelResultSerializer implements PrimitiveSerializer<BiocentralModelResult> {
  @override
  final Iterable<Type> types = const [BiocentralModelResult, _$BiocentralModelResult];

  @override
  final String wireName = r'BiocentralModelResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BiocentralModelResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'model_result';
    yield serializers.serialize(
      object.modelResult,
      specifiedType: const FullType(BiotrainerModelResult),
    );
    yield r'logging_file';
    yield serializers.serialize(
      object.loggingFile,
      specifiedType: const FullType(String),
    );
    yield r'checkpoints';
    yield serializers.serialize(
      object.checkpoints,
      specifiedType: const FullType(BuiltList, [FullType(BiotrainerCheckpoint)]),
    );
    if (object.onnxCheckpoint != null) {
      yield r'onnx_checkpoint';
      yield serializers.serialize(
        object.onnxCheckpoint,
        specifiedType: const FullType.nullable(BuiltList, [FullType(BiotrainerCheckpoint)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BiocentralModelResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BiocentralModelResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'model_result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BiotrainerModelResult),
          ) as BiotrainerModelResult;
          result.modelResult.replace(valueDes);
          break;
        case r'logging_file':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.loggingFile = valueDes;
          break;
        case r'checkpoints':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BiotrainerCheckpoint)]),
          ) as BuiltList<BiotrainerCheckpoint>;
          result.checkpoints.replace(valueDes);
          break;
        case r'onnx_checkpoint':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(BiotrainerCheckpoint)]),
          ) as BuiltList<BiotrainerCheckpoint>?;
          if (valueDes == null) continue;
          result.onnxCheckpoint.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BiocentralModelResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BiocentralModelResultBuilder();
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

