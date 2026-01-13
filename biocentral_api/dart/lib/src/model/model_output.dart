//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/output_type.dart';
import 'package:biocentral_api/src/model/output_class.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model_output.g.dart';

/// ModelOutput
///
/// Properties:
/// * [name] - Name of the output
/// * [description] - Description of the output
/// * [outputType] - Type of output
/// * [valueType] - Type of output values
/// * [classes] 
/// * [valueRange] 
/// * [unit] 
@BuiltValue()
abstract class ModelOutput implements Built<ModelOutput, ModelOutputBuilder> {
  /// Name of the output
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Description of the output
  @BuiltValueField(wireName: r'description')
  String get description;

  /// Type of output
  @BuiltValueField(wireName: r'output_type')
  OutputType get outputType;
  // enum outputTypeEnum {  per_residue,  per_sequence,  mutation,  };

  /// Type of output values
  @BuiltValueField(wireName: r'value_type')
  String get valueType;

  @BuiltValueField(wireName: r'classes')
  BuiltList<OutputClass>? get classes;

  @BuiltValueField(wireName: r'value_range')
  BuiltList<JsonObject?>? get valueRange;

  @BuiltValueField(wireName: r'unit')
  String? get unit;

  ModelOutput._();

  factory ModelOutput([void updates(ModelOutputBuilder b)]) = _$ModelOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModelOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModelOutput> get serializer => _$ModelOutputSerializer();
}

class _$ModelOutputSerializer implements PrimitiveSerializer<ModelOutput> {
  @override
  final Iterable<Type> types = const [ModelOutput, _$ModelOutput];

  @override
  final String wireName = r'ModelOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModelOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
    yield r'output_type';
    yield serializers.serialize(
      object.outputType,
      specifiedType: const FullType(OutputType),
    );
    yield r'value_type';
    yield serializers.serialize(
      object.valueType,
      specifiedType: const FullType(String),
    );
    if (object.classes != null) {
      yield r'classes';
      yield serializers.serialize(
        object.classes,
        specifiedType: const FullType.nullable(BuiltList, [FullType(OutputClass)]),
      );
    }
    if (object.valueRange != null) {
      yield r'value_range';
      yield serializers.serialize(
        object.valueRange,
        specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
      );
    }
    if (object.unit != null) {
      yield r'unit';
      yield serializers.serialize(
        object.unit,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ModelOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModelOutputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'output_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OutputType),
          ) as OutputType;
          result.outputType = valueDes;
          break;
        case r'value_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.valueType = valueDes;
          break;
        case r'classes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(OutputClass)]),
          ) as BuiltList<OutputClass>?;
          if (valueDes == null) continue;
          result.classes.replace(valueDes);
          break;
        case r'value_range':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType.nullable(JsonObject)]),
          ) as BuiltList<JsonObject?>?;
          if (valueDes == null) continue;
          result.valueRange.replace(valueDes);
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ModelOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModelOutputBuilder();
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

