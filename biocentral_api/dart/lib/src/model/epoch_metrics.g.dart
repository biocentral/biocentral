// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epoch_metrics.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EpochMetrics extends EpochMetrics {
  @override
  final int epoch;
  @override
  final BuiltMap<String, JsonObject?> training;
  @override
  final BuiltMap<String, JsonObject?> validation;

  factory _$EpochMetrics([void Function(EpochMetricsBuilder)? updates]) =>
      (EpochMetricsBuilder()..update(updates))._build();

  _$EpochMetrics._(
      {required this.epoch, required this.training, required this.validation})
      : super._();
  @override
  EpochMetrics rebuild(void Function(EpochMetricsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EpochMetricsBuilder toBuilder() => EpochMetricsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EpochMetrics &&
        epoch == other.epoch &&
        training == other.training &&
        validation == other.validation;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, epoch.hashCode);
    _$hash = $jc(_$hash, training.hashCode);
    _$hash = $jc(_$hash, validation.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EpochMetrics')
          ..add('epoch', epoch)
          ..add('training', training)
          ..add('validation', validation))
        .toString();
  }
}

class EpochMetricsBuilder
    implements Builder<EpochMetrics, EpochMetricsBuilder> {
  _$EpochMetrics? _$v;

  int? _epoch;
  int? get epoch => _$this._epoch;
  set epoch(int? epoch) => _$this._epoch = epoch;

  MapBuilder<String, JsonObject?>? _training;
  MapBuilder<String, JsonObject?> get training =>
      _$this._training ??= MapBuilder<String, JsonObject?>();
  set training(MapBuilder<String, JsonObject?>? training) =>
      _$this._training = training;

  MapBuilder<String, JsonObject?>? _validation;
  MapBuilder<String, JsonObject?> get validation =>
      _$this._validation ??= MapBuilder<String, JsonObject?>();
  set validation(MapBuilder<String, JsonObject?>? validation) =>
      _$this._validation = validation;

  EpochMetricsBuilder() {
    EpochMetrics._defaults(this);
  }

  EpochMetricsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _epoch = $v.epoch;
      _training = $v.training.toBuilder();
      _validation = $v.validation.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EpochMetrics other) {
    _$v = other as _$EpochMetrics;
  }

  @override
  void update(void Function(EpochMetricsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EpochMetrics build() => _build();

  _$EpochMetrics _build() {
    _$EpochMetrics _$result;
    try {
      _$result = _$v ??
          _$EpochMetrics._(
            epoch: BuiltValueNullFieldError.checkNotNull(
                epoch, r'EpochMetrics', 'epoch'),
            training: training.build(),
            validation: validation.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'training';
        training.build();
        _$failedField = 'validation';
        validation.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EpochMetrics', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
