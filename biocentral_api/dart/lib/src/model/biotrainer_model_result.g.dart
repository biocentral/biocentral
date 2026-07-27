// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biotrainer_model_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BiotrainerModelResult extends BiotrainerModelResult {
  @override
  final BuiltMap<String, JsonObject?>? config;
  @override
  final DerivedValues? derivedValues;
  @override
  final BuiltMap<String, TrainingResult>? trainingResults;
  @override
  final BuiltMap<String, TestResult>? testResults;
  @override
  final BuiltList<BiotrainerPrediction>? predictions;

  factory _$BiotrainerModelResult(
          [void Function(BiotrainerModelResultBuilder)? updates]) =>
      (BiotrainerModelResultBuilder()..update(updates))._build();

  _$BiotrainerModelResult._(
      {this.config,
      this.derivedValues,
      this.trainingResults,
      this.testResults,
      this.predictions})
      : super._();
  @override
  BiotrainerModelResult rebuild(
          void Function(BiotrainerModelResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BiotrainerModelResultBuilder toBuilder() =>
      BiotrainerModelResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BiotrainerModelResult &&
        config == other.config &&
        derivedValues == other.derivedValues &&
        trainingResults == other.trainingResults &&
        testResults == other.testResults &&
        predictions == other.predictions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jc(_$hash, derivedValues.hashCode);
    _$hash = $jc(_$hash, trainingResults.hashCode);
    _$hash = $jc(_$hash, testResults.hashCode);
    _$hash = $jc(_$hash, predictions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BiotrainerModelResult')
          ..add('config', config)
          ..add('derivedValues', derivedValues)
          ..add('trainingResults', trainingResults)
          ..add('testResults', testResults)
          ..add('predictions', predictions))
        .toString();
  }
}

class BiotrainerModelResultBuilder
    implements Builder<BiotrainerModelResult, BiotrainerModelResultBuilder> {
  _$BiotrainerModelResult? _$v;

  MapBuilder<String, JsonObject?>? _config;
  MapBuilder<String, JsonObject?> get config =>
      _$this._config ??= MapBuilder<String, JsonObject?>();
  set config(MapBuilder<String, JsonObject?>? config) =>
      _$this._config = config;

  DerivedValuesBuilder? _derivedValues;
  DerivedValuesBuilder get derivedValues =>
      _$this._derivedValues ??= DerivedValuesBuilder();
  set derivedValues(DerivedValuesBuilder? derivedValues) =>
      _$this._derivedValues = derivedValues;

  MapBuilder<String, TrainingResult>? _trainingResults;
  MapBuilder<String, TrainingResult> get trainingResults =>
      _$this._trainingResults ??= MapBuilder<String, TrainingResult>();
  set trainingResults(MapBuilder<String, TrainingResult>? trainingResults) =>
      _$this._trainingResults = trainingResults;

  MapBuilder<String, TestResult>? _testResults;
  MapBuilder<String, TestResult> get testResults =>
      _$this._testResults ??= MapBuilder<String, TestResult>();
  set testResults(MapBuilder<String, TestResult>? testResults) =>
      _$this._testResults = testResults;

  ListBuilder<BiotrainerPrediction>? _predictions;
  ListBuilder<BiotrainerPrediction> get predictions =>
      _$this._predictions ??= ListBuilder<BiotrainerPrediction>();
  set predictions(ListBuilder<BiotrainerPrediction>? predictions) =>
      _$this._predictions = predictions;

  BiotrainerModelResultBuilder() {
    BiotrainerModelResult._defaults(this);
  }

  BiotrainerModelResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _config = $v.config?.toBuilder();
      _derivedValues = $v.derivedValues?.toBuilder();
      _trainingResults = $v.trainingResults?.toBuilder();
      _testResults = $v.testResults?.toBuilder();
      _predictions = $v.predictions?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BiotrainerModelResult other) {
    _$v = other as _$BiotrainerModelResult;
  }

  @override
  void update(void Function(BiotrainerModelResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BiotrainerModelResult build() => _build();

  _$BiotrainerModelResult _build() {
    _$BiotrainerModelResult _$result;
    try {
      _$result = _$v ??
          _$BiotrainerModelResult._(
            config: _config?.build(),
            derivedValues: _derivedValues?.build(),
            trainingResults: _trainingResults?.build(),
            testResults: _testResults?.build(),
            predictions: _predictions?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'config';
        _config?.build();
        _$failedField = 'derivedValues';
        _derivedValues?.build();
        _$failedField = 'trainingResults';
        _trainingResults?.build();
        _$failedField = 'testResults';
        _testResults?.build();
        _$failedField = 'predictions';
        _predictions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BiotrainerModelResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
