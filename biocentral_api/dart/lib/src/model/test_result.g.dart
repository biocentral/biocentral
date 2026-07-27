// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TestResult extends TestResult {
  @override
  final BiotrainerInferenceResult? inferenceResult;
  @override
  final BuiltList<BootstrappedMetric>? bootstrappedMetrics;
  @override
  final BuiltMap<String, BuiltList<BootstrappedMetric>>? baselines;
  @override
  final BuiltList<String>? sanityCheckWarnings;

  factory _$TestResult([void Function(TestResultBuilder)? updates]) =>
      (TestResultBuilder()..update(updates))._build();

  _$TestResult._(
      {this.inferenceResult,
      this.bootstrappedMetrics,
      this.baselines,
      this.sanityCheckWarnings})
      : super._();
  @override
  TestResult rebuild(void Function(TestResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TestResultBuilder toBuilder() => TestResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TestResult &&
        inferenceResult == other.inferenceResult &&
        bootstrappedMetrics == other.bootstrappedMetrics &&
        baselines == other.baselines &&
        sanityCheckWarnings == other.sanityCheckWarnings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, inferenceResult.hashCode);
    _$hash = $jc(_$hash, bootstrappedMetrics.hashCode);
    _$hash = $jc(_$hash, baselines.hashCode);
    _$hash = $jc(_$hash, sanityCheckWarnings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TestResult')
          ..add('inferenceResult', inferenceResult)
          ..add('bootstrappedMetrics', bootstrappedMetrics)
          ..add('baselines', baselines)
          ..add('sanityCheckWarnings', sanityCheckWarnings))
        .toString();
  }
}

class TestResultBuilder implements Builder<TestResult, TestResultBuilder> {
  _$TestResult? _$v;

  BiotrainerInferenceResultBuilder? _inferenceResult;
  BiotrainerInferenceResultBuilder get inferenceResult =>
      _$this._inferenceResult ??= BiotrainerInferenceResultBuilder();
  set inferenceResult(BiotrainerInferenceResultBuilder? inferenceResult) =>
      _$this._inferenceResult = inferenceResult;

  ListBuilder<BootstrappedMetric>? _bootstrappedMetrics;
  ListBuilder<BootstrappedMetric> get bootstrappedMetrics =>
      _$this._bootstrappedMetrics ??= ListBuilder<BootstrappedMetric>();
  set bootstrappedMetrics(
          ListBuilder<BootstrappedMetric>? bootstrappedMetrics) =>
      _$this._bootstrappedMetrics = bootstrappedMetrics;

  MapBuilder<String, BuiltList<BootstrappedMetric>>? _baselines;
  MapBuilder<String, BuiltList<BootstrappedMetric>> get baselines =>
      _$this._baselines ??= MapBuilder<String, BuiltList<BootstrappedMetric>>();
  set baselines(MapBuilder<String, BuiltList<BootstrappedMetric>>? baselines) =>
      _$this._baselines = baselines;

  ListBuilder<String>? _sanityCheckWarnings;
  ListBuilder<String> get sanityCheckWarnings =>
      _$this._sanityCheckWarnings ??= ListBuilder<String>();
  set sanityCheckWarnings(ListBuilder<String>? sanityCheckWarnings) =>
      _$this._sanityCheckWarnings = sanityCheckWarnings;

  TestResultBuilder() {
    TestResult._defaults(this);
  }

  TestResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _inferenceResult = $v.inferenceResult?.toBuilder();
      _bootstrappedMetrics = $v.bootstrappedMetrics?.toBuilder();
      _baselines = $v.baselines?.toBuilder();
      _sanityCheckWarnings = $v.sanityCheckWarnings?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TestResult other) {
    _$v = other as _$TestResult;
  }

  @override
  void update(void Function(TestResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TestResult build() => _build();

  _$TestResult _build() {
    _$TestResult _$result;
    try {
      _$result = _$v ??
          _$TestResult._(
            inferenceResult: _inferenceResult?.build(),
            bootstrappedMetrics: _bootstrappedMetrics?.build(),
            baselines: _baselines?.build(),
            sanityCheckWarnings: _sanityCheckWarnings?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'inferenceResult';
        _inferenceResult?.build();
        _$failedField = 'bootstrappedMetrics';
        _bootstrappedMetrics?.build();
        _$failedField = 'baselines';
        _baselines?.build();
        _$failedField = 'sanityCheckWarnings';
        _sanityCheckWarnings?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TestResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
