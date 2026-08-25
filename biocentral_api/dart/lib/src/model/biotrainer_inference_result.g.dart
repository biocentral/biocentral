// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biotrainer_inference_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BiotrainerInferenceResult extends BiotrainerInferenceResult {
  @override
  final BuiltList<BiotrainerPrediction> predictions;
  @override
  final BuiltMap<String, num>? metrics;

  factory _$BiotrainerInferenceResult(
          [void Function(BiotrainerInferenceResultBuilder)? updates]) =>
      (BiotrainerInferenceResultBuilder()..update(updates))._build();

  _$BiotrainerInferenceResult._({required this.predictions, this.metrics})
      : super._();
  @override
  BiotrainerInferenceResult rebuild(
          void Function(BiotrainerInferenceResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BiotrainerInferenceResultBuilder toBuilder() =>
      BiotrainerInferenceResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BiotrainerInferenceResult &&
        predictions == other.predictions &&
        metrics == other.metrics;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, predictions.hashCode);
    _$hash = $jc(_$hash, metrics.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BiotrainerInferenceResult')
          ..add('predictions', predictions)
          ..add('metrics', metrics))
        .toString();
  }
}

class BiotrainerInferenceResultBuilder
    implements
        Builder<BiotrainerInferenceResult, BiotrainerInferenceResultBuilder> {
  _$BiotrainerInferenceResult? _$v;

  ListBuilder<BiotrainerPrediction>? _predictions;
  ListBuilder<BiotrainerPrediction> get predictions =>
      _$this._predictions ??= ListBuilder<BiotrainerPrediction>();
  set predictions(ListBuilder<BiotrainerPrediction>? predictions) =>
      _$this._predictions = predictions;

  MapBuilder<String, num>? _metrics;
  MapBuilder<String, num> get metrics =>
      _$this._metrics ??= MapBuilder<String, num>();
  set metrics(MapBuilder<String, num>? metrics) => _$this._metrics = metrics;

  BiotrainerInferenceResultBuilder() {
    BiotrainerInferenceResult._defaults(this);
  }

  BiotrainerInferenceResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _predictions = $v.predictions.toBuilder();
      _metrics = $v.metrics?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BiotrainerInferenceResult other) {
    _$v = other as _$BiotrainerInferenceResult;
  }

  @override
  void update(void Function(BiotrainerInferenceResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BiotrainerInferenceResult build() => _build();

  _$BiotrainerInferenceResult _build() {
    _$BiotrainerInferenceResult _$result;
    try {
      _$result = _$v ??
          _$BiotrainerInferenceResult._(
            predictions: predictions.build(),
            metrics: _metrics?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'predictions';
        predictions.build();
        _$failedField = 'metrics';
        _metrics?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BiotrainerInferenceResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
