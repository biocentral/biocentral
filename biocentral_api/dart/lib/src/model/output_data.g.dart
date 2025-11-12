// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OutputData extends OutputData {
  @override
  final BuiltMap<String, JsonObject?>? config;
  @override
  final BuiltMap<String, JsonObject?>? derivedValues;
  @override
  final BuiltMap<String, JsonObject?>? splitSpecificValues;
  @override
  final BuiltList<JsonObject?>? trainingIteration;
  @override
  final BuiltMap<String, JsonObject?>? testResults;
  @override
  final BuiltMap<String, JsonObject?>? predictions;

  factory _$OutputData([void Function(OutputDataBuilder)? updates]) =>
      (OutputDataBuilder()..update(updates))._build();

  _$OutputData._(
      {this.config,
      this.derivedValues,
      this.splitSpecificValues,
      this.trainingIteration,
      this.testResults,
      this.predictions})
      : super._();
  @override
  OutputData rebuild(void Function(OutputDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OutputDataBuilder toBuilder() => OutputDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OutputData &&
        config == other.config &&
        derivedValues == other.derivedValues &&
        splitSpecificValues == other.splitSpecificValues &&
        trainingIteration == other.trainingIteration &&
        testResults == other.testResults &&
        predictions == other.predictions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jc(_$hash, derivedValues.hashCode);
    _$hash = $jc(_$hash, splitSpecificValues.hashCode);
    _$hash = $jc(_$hash, trainingIteration.hashCode);
    _$hash = $jc(_$hash, testResults.hashCode);
    _$hash = $jc(_$hash, predictions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OutputData')
          ..add('config', config)
          ..add('derivedValues', derivedValues)
          ..add('splitSpecificValues', splitSpecificValues)
          ..add('trainingIteration', trainingIteration)
          ..add('testResults', testResults)
          ..add('predictions', predictions))
        .toString();
  }
}

class OutputDataBuilder implements Builder<OutputData, OutputDataBuilder> {
  _$OutputData? _$v;

  MapBuilder<String, JsonObject?>? _config;
  MapBuilder<String, JsonObject?> get config =>
      _$this._config ??= MapBuilder<String, JsonObject?>();
  set config(MapBuilder<String, JsonObject?>? config) =>
      _$this._config = config;

  MapBuilder<String, JsonObject?>? _derivedValues;
  MapBuilder<String, JsonObject?> get derivedValues =>
      _$this._derivedValues ??= MapBuilder<String, JsonObject?>();
  set derivedValues(MapBuilder<String, JsonObject?>? derivedValues) =>
      _$this._derivedValues = derivedValues;

  MapBuilder<String, JsonObject?>? _splitSpecificValues;
  MapBuilder<String, JsonObject?> get splitSpecificValues =>
      _$this._splitSpecificValues ??= MapBuilder<String, JsonObject?>();
  set splitSpecificValues(
          MapBuilder<String, JsonObject?>? splitSpecificValues) =>
      _$this._splitSpecificValues = splitSpecificValues;

  ListBuilder<JsonObject?>? _trainingIteration;
  ListBuilder<JsonObject?> get trainingIteration =>
      _$this._trainingIteration ??= ListBuilder<JsonObject?>();
  set trainingIteration(ListBuilder<JsonObject?>? trainingIteration) =>
      _$this._trainingIteration = trainingIteration;

  MapBuilder<String, JsonObject?>? _testResults;
  MapBuilder<String, JsonObject?> get testResults =>
      _$this._testResults ??= MapBuilder<String, JsonObject?>();
  set testResults(MapBuilder<String, JsonObject?>? testResults) =>
      _$this._testResults = testResults;

  MapBuilder<String, JsonObject?>? _predictions;
  MapBuilder<String, JsonObject?> get predictions =>
      _$this._predictions ??= MapBuilder<String, JsonObject?>();
  set predictions(MapBuilder<String, JsonObject?>? predictions) =>
      _$this._predictions = predictions;

  OutputDataBuilder() {
    OutputData._defaults(this);
  }

  OutputDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _config = $v.config?.toBuilder();
      _derivedValues = $v.derivedValues?.toBuilder();
      _splitSpecificValues = $v.splitSpecificValues?.toBuilder();
      _trainingIteration = $v.trainingIteration?.toBuilder();
      _testResults = $v.testResults?.toBuilder();
      _predictions = $v.predictions?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OutputData other) {
    _$v = other as _$OutputData;
  }

  @override
  void update(void Function(OutputDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OutputData build() => _build();

  _$OutputData _build() {
    _$OutputData _$result;
    try {
      _$result = _$v ??
          _$OutputData._(
            config: _config?.build(),
            derivedValues: _derivedValues?.build(),
            splitSpecificValues: _splitSpecificValues?.build(),
            trainingIteration: _trainingIteration?.build(),
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
        _$failedField = 'splitSpecificValues';
        _splitSpecificValues?.build();
        _$failedField = 'trainingIteration';
        _trainingIteration?.build();
        _$failedField = 'testResults';
        _testResults?.build();
        _$failedField = 'predictions';
        _predictions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OutputData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
