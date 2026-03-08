//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auto_eval_report.g.dart';

/// AutoEvalReport
///
/// Properties:
/// * [embedderName] - Name of the embedder
/// * [trainingDate] - Date of training
/// * [minSeqLen] - Minimum sequence length used during evaluation
/// * [maxSeqLen] - Maximum sequence length used during evaluation
/// * [results] - Autoeval results
@BuiltValue()
abstract class AutoEvalReport implements Built<AutoEvalReport, AutoEvalReportBuilder> {
  /// Name of the embedder
  @BuiltValueField(wireName: r'embedder_name')
  String get embedderName;

  /// Date of training
  @BuiltValueField(wireName: r'training_date')
  String get trainingDate;

  /// Minimum sequence length used during evaluation
  @BuiltValueField(wireName: r'min_seq_len')
  int get minSeqLen;

  /// Maximum sequence length used during evaluation
  @BuiltValueField(wireName: r'max_seq_len')
  int get maxSeqLen;

  /// Autoeval results
  @BuiltValueField(wireName: r'results')
  BuiltMap<String, BuiltMap<String, JsonObject?>> get results;

  AutoEvalReport._();

  factory AutoEvalReport([void updates(AutoEvalReportBuilder b)]) = _$AutoEvalReport;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AutoEvalReportBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AutoEvalReport> get serializer => _$AutoEvalReportSerializer();
}

class _$AutoEvalReportSerializer implements PrimitiveSerializer<AutoEvalReport> {
  @override
  final Iterable<Type> types = const [AutoEvalReport, _$AutoEvalReport];

  @override
  final String wireName = r'AutoEvalReport';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AutoEvalReport object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'embedder_name';
    yield serializers.serialize(
      object.embedderName,
      specifiedType: const FullType(String),
    );
    yield r'training_date';
    yield serializers.serialize(
      object.trainingDate,
      specifiedType: const FullType(String),
    );
    yield r'min_seq_len';
    yield serializers.serialize(
      object.minSeqLen,
      specifiedType: const FullType(int),
    );
    yield r'max_seq_len';
    yield serializers.serialize(
      object.maxSeqLen,
      specifiedType: const FullType(int),
    );
    yield r'results';
    yield serializers.serialize(
      object.results,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AutoEvalReport object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AutoEvalReportBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'embedder_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.embedderName = valueDes;
          break;
        case r'training_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trainingDate = valueDes;
          break;
        case r'min_seq_len':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minSeqLen = valueDes;
          break;
        case r'max_seq_len':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
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
  AutoEvalReport deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AutoEvalReportBuilder();
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

