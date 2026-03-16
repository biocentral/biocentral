//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supervised_framework_report.g.dart';

/// SupervisedFrameworkReport
///
/// Properties:
/// * [minSeqLen] 
/// * [maxSeqLen] 
/// * [results] - Supervised autoeval results
@BuiltValue()
abstract class SupervisedFrameworkReport implements Built<SupervisedFrameworkReport, SupervisedFrameworkReportBuilder> {
  @BuiltValueField(wireName: r'min_seq_len')
  int? get minSeqLen;

  @BuiltValueField(wireName: r'max_seq_len')
  int? get maxSeqLen;

  /// Supervised autoeval results
  @BuiltValueField(wireName: r'results')
  BuiltMap<String, BuiltMap<String, JsonObject?>> get results;

  SupervisedFrameworkReport._();

  factory SupervisedFrameworkReport([void updates(SupervisedFrameworkReportBuilder b)]) = _$SupervisedFrameworkReport;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupervisedFrameworkReportBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupervisedFrameworkReport> get serializer => _$SupervisedFrameworkReportSerializer();
}

class _$SupervisedFrameworkReportSerializer implements PrimitiveSerializer<SupervisedFrameworkReport> {
  @override
  final Iterable<Type> types = const [SupervisedFrameworkReport, _$SupervisedFrameworkReport];

  @override
  final String wireName = r'SupervisedFrameworkReport';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupervisedFrameworkReport object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.minSeqLen != null) {
      yield r'min_seq_len';
      yield serializers.serialize(
        object.minSeqLen,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.maxSeqLen != null) {
      yield r'max_seq_len';
      yield serializers.serialize(
        object.maxSeqLen,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'results';
    yield serializers.serialize(
      object.results,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupervisedFrameworkReport object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupervisedFrameworkReportBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'min_seq_len':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.minSeqLen = valueDes;
          break;
        case r'max_seq_len':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.maxSeqLen = valueDes;
          break;
        case r'results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
          ) as BuiltMap<String, BuiltMap<String, JsonObject?>>;
          result.results.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupervisedFrameworkReport deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupervisedFrameworkReportBuilder();
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

