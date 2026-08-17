//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:biocentral_api/src/model/biotrainer_inference_result.dart';
import 'package:biocentral_api/src/model/bootstrapped_metric.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'test_result.g.dart';

/// Test results after training. 
///
/// Properties:
/// * [inferenceResult] - Plain test inference result
/// * [bootstrappedMetrics] - Bootstrapped test metrics
/// * [baselines] - Bootstrapped baselines by method name
/// * [sanityCheckWarnings] - Warnings from sanity checks
@BuiltValue()
abstract class TestResult implements Built<TestResult, TestResultBuilder> {
  /// Plain test inference result
  @BuiltValueField(wireName: r'inference_result')
  BiotrainerInferenceResult? get inferenceResult;

  /// Bootstrapped test metrics
  @BuiltValueField(wireName: r'bootstrapped_metrics')
  BuiltList<BootstrappedMetric>? get bootstrappedMetrics;

  /// Bootstrapped baselines by method name
  @BuiltValueField(wireName: r'baselines')
  BuiltMap<String, BuiltList<BootstrappedMetric>>? get baselines;

  /// Warnings from sanity checks
  @BuiltValueField(wireName: r'sanity_check_warnings')
  BuiltList<String>? get sanityCheckWarnings;

  TestResult._();

  factory TestResult([void updates(TestResultBuilder b)]) = _$TestResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TestResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TestResult> get serializer => _$TestResultSerializer();
}

class _$TestResultSerializer implements PrimitiveSerializer<TestResult> {
  @override
  final Iterable<Type> types = const [TestResult, _$TestResult];

  @override
  final String wireName = r'TestResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TestResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.inferenceResult != null) {
      yield r'inference_result';
      yield serializers.serialize(
        object.inferenceResult,
        specifiedType: const FullType.nullable(BiotrainerInferenceResult),
      );
    }
    if (object.bootstrappedMetrics != null) {
      yield r'bootstrapped_metrics';
      yield serializers.serialize(
        object.bootstrappedMetrics,
        specifiedType: const FullType.nullable(BuiltList, [FullType(BootstrappedMetric)]),
      );
    }
    if (object.baselines != null) {
      yield r'baselines';
      yield serializers.serialize(
        object.baselines,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(BuiltList, [FullType(BootstrappedMetric)])]),
      );
    }
    if (object.sanityCheckWarnings != null) {
      yield r'sanity_check_warnings';
      yield serializers.serialize(
        object.sanityCheckWarnings,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TestResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TestResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'inference_result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BiotrainerInferenceResult),
          ) as BiotrainerInferenceResult?;
          if (valueDes == null) continue;
          result.inferenceResult.replace(valueDes);
          break;
        case r'bootstrapped_metrics':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(BootstrappedMetric)]),
          ) as BuiltList<BootstrappedMetric>?;
          if (valueDes == null) continue;
          result.bootstrappedMetrics.replace(valueDes);
          break;
        case r'baselines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType(BuiltList, [FullType(BootstrappedMetric)])]),
          ) as BuiltMap<String, BuiltList<BootstrappedMetric>>?;
          if (valueDes == null) continue;
          result.baselines.replace(valueDes);
          break;
        case r'sanity_check_warnings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.sanityCheckWarnings.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TestResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TestResultBuilder();
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

