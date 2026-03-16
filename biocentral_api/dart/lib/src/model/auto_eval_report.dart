//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/zero_shot_framework_report.dart';
import 'package:biocentral_api/src/model/supervised_framework_report.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auto_eval_report.g.dart';

/// AutoEvalReport
///
/// Properties:
/// * [embedderName] - Name of the embedder
/// * [trainingDate] - Date of training
/// * [supervisedResults] - Supervised autoeval results
/// * [zeroshotResults] - Zero-Shot autoeval results
@BuiltValue()
abstract class AutoEvalReport implements Built<AutoEvalReport, AutoEvalReportBuilder> {
  /// Name of the embedder
  @BuiltValueField(wireName: r'embedder_name')
  String get embedderName;

  /// Date of training
  @BuiltValueField(wireName: r'training_date')
  String get trainingDate;

  /// Supervised autoeval results
  @BuiltValueField(wireName: r'supervised_results')
  BuiltMap<String, SupervisedFrameworkReport> get supervisedResults;

  /// Zero-Shot autoeval results
  @BuiltValueField(wireName: r'zeroshot_results')
  BuiltMap<String, ZeroShotFrameworkReport> get zeroshotResults;

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
    yield r'supervised_results';
    yield serializers.serialize(
      object.supervisedResults,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(SupervisedFrameworkReport)]),
    );
    yield r'zeroshot_results';
    yield serializers.serialize(
      object.zeroshotResults,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(ZeroShotFrameworkReport)]),
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
        case r'supervised_results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(SupervisedFrameworkReport)]),
          ) as BuiltMap<String, SupervisedFrameworkReport>;
          result.supervisedResults.replace(valueDes);
          break;
        case r'zeroshot_results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(ZeroShotFrameworkReport)]),
          ) as BuiltMap<String, ZeroShotFrameworkReport>;
          result.zeroshotResults.replace(valueDes);
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

