//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:biocentral_api/src/model/biocentral_prediction_model.dart';
import 'package:biocentral_api/src/model/model_output.dart';
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/protocol.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model_metadata.g.dart';

/// ModelMetadata
///
/// Properties:
/// * [name] - Model name
/// * [protocol] - Protocol of model predictions
/// * [description] - Model description
/// * [authors] - Authors of the model
/// * [modelLink] - Link to the model's repository
/// * [citation] - Citation of the model
/// * [licence] - Licence of the model
/// * [outputs] - List of descriptions of model outputs
/// * [modelSize] - Size of the model in MB
/// * [embedder] - Name of the embedder used for the model
/// * [trainingDataLink] 
@BuiltValue()
abstract class ModelMetadata implements Built<ModelMetadata, ModelMetadataBuilder> {
  /// Model name
  @BuiltValueField(wireName: r'name')
  BiocentralPredictionModel get name;
  // enum nameEnum {  BindEmbed,  ProtT5Conservation,  Seth,  LightAttentionSubcellularLocalization,  LightAttentionMembrane,  TMbed,  ProtT5SecondaryStructure,  ExoTox,  VespaG,  };

  /// Protocol of model predictions
  @BuiltValueField(wireName: r'protocol')
  Protocol get protocol;
  // enum protocolEnum {  [0],  [1],  [2],  [3],  [4],  5,  };

  /// Model description
  @BuiltValueField(wireName: r'description')
  String get description;

  /// Authors of the model
  @BuiltValueField(wireName: r'authors')
  String get authors;

  /// Link to the model's repository
  @BuiltValueField(wireName: r'model_link')
  String get modelLink;

  /// Citation of the model
  @BuiltValueField(wireName: r'citation')
  String get citation;

  /// Licence of the model
  @BuiltValueField(wireName: r'licence')
  String get licence;

  /// List of descriptions of model outputs
  @BuiltValueField(wireName: r'outputs')
  BuiltList<ModelOutput> get outputs;

  /// Size of the model in MB
  @BuiltValueField(wireName: r'model_size')
  String get modelSize;

  /// Name of the embedder used for the model
  @BuiltValueField(wireName: r'embedder')
  String get embedder;

  @BuiltValueField(wireName: r'training_data_link')
  String? get trainingDataLink;

  ModelMetadata._();

  factory ModelMetadata([void updates(ModelMetadataBuilder b)]) = _$ModelMetadata;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModelMetadataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModelMetadata> get serializer => _$ModelMetadataSerializer();
}

class _$ModelMetadataSerializer implements PrimitiveSerializer<ModelMetadata> {
  @override
  final Iterable<Type> types = const [ModelMetadata, _$ModelMetadata];

  @override
  final String wireName = r'ModelMetadata';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModelMetadata object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(BiocentralPredictionModel),
    );
    yield r'protocol';
    yield serializers.serialize(
      object.protocol,
      specifiedType: const FullType(Protocol),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
    yield r'authors';
    yield serializers.serialize(
      object.authors,
      specifiedType: const FullType(String),
    );
    yield r'model_link';
    yield serializers.serialize(
      object.modelLink,
      specifiedType: const FullType(String),
    );
    yield r'citation';
    yield serializers.serialize(
      object.citation,
      specifiedType: const FullType(String),
    );
    yield r'licence';
    yield serializers.serialize(
      object.licence,
      specifiedType: const FullType(String),
    );
    yield r'outputs';
    yield serializers.serialize(
      object.outputs,
      specifiedType: const FullType(BuiltList, [FullType(ModelOutput)]),
    );
    yield r'model_size';
    yield serializers.serialize(
      object.modelSize,
      specifiedType: const FullType(String),
    );
    yield r'embedder';
    yield serializers.serialize(
      object.embedder,
      specifiedType: const FullType(String),
    );
    if (object.trainingDataLink != null) {
      yield r'training_data_link';
      yield serializers.serialize(
        object.trainingDataLink,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ModelMetadata object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModelMetadataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BiocentralPredictionModel),
          ) as BiocentralPredictionModel;
          result.name = valueDes;
          break;
        case r'protocol':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Protocol),
          ) as Protocol;
          result.protocol = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'authors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authors = valueDes;
          break;
        case r'model_link':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.modelLink = valueDes;
          break;
        case r'citation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.citation = valueDes;
          break;
        case r'licence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.licence = valueDes;
          break;
        case r'outputs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ModelOutput)]),
          ) as BuiltList<ModelOutput>;
          result.outputs.replace(valueDes);
          break;
        case r'model_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.modelSize = valueDes;
          break;
        case r'embedder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.embedder = valueDes;
          break;
        case r'training_data_link':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.trainingDataLink = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ModelMetadata deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModelMetadataBuilder();
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

