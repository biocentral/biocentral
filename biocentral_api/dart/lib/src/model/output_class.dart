//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'output_class.g.dart';

/// OutputClass
///
/// Properties:
/// * [shortcut] - Shortcut of the label
/// * [label] - Label of the class
/// * [description] - Description of the class
@BuiltValue()
abstract class OutputClass implements Built<OutputClass, OutputClassBuilder> {
  /// Shortcut of the label
  @BuiltValueField(wireName: r'shortcut')
  String get shortcut;

  /// Label of the class
  @BuiltValueField(wireName: r'label')
  String get label;

  /// Description of the class
  @BuiltValueField(wireName: r'description')
  String get description;

  OutputClass._();

  factory OutputClass([void updates(OutputClassBuilder b)]) = _$OutputClass;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OutputClassBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OutputClass> get serializer => _$OutputClassSerializer();
}

class _$OutputClassSerializer implements PrimitiveSerializer<OutputClass> {
  @override
  final Iterable<Type> types = const [OutputClass, _$OutputClass];

  @override
  final String wireName = r'OutputClass';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OutputClass object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'shortcut';
    yield serializers.serialize(
      object.shortcut,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OutputClass object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OutputClassBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'shortcut':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.shortcut = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OutputClass deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OutputClassBuilder();
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

