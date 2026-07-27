// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biotrainer_model_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BiotrainerModelUpdate extends BiotrainerModelUpdate {
  @override
  final BiotrainerModelResult currentModelResult;
  @override
  final BuiltList<JsonObject?>? trainingIteration;

  factory _$BiotrainerModelUpdate(
          [void Function(BiotrainerModelUpdateBuilder)? updates]) =>
      (BiotrainerModelUpdateBuilder()..update(updates))._build();

  _$BiotrainerModelUpdate._(
      {required this.currentModelResult, this.trainingIteration})
      : super._();
  @override
  BiotrainerModelUpdate rebuild(
          void Function(BiotrainerModelUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BiotrainerModelUpdateBuilder toBuilder() =>
      BiotrainerModelUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BiotrainerModelUpdate &&
        currentModelResult == other.currentModelResult &&
        trainingIteration == other.trainingIteration;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currentModelResult.hashCode);
    _$hash = $jc(_$hash, trainingIteration.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BiotrainerModelUpdate')
          ..add('currentModelResult', currentModelResult)
          ..add('trainingIteration', trainingIteration))
        .toString();
  }
}

class BiotrainerModelUpdateBuilder
    implements Builder<BiotrainerModelUpdate, BiotrainerModelUpdateBuilder> {
  _$BiotrainerModelUpdate? _$v;

  BiotrainerModelResultBuilder? _currentModelResult;
  BiotrainerModelResultBuilder get currentModelResult =>
      _$this._currentModelResult ??= BiotrainerModelResultBuilder();
  set currentModelResult(BiotrainerModelResultBuilder? currentModelResult) =>
      _$this._currentModelResult = currentModelResult;

  ListBuilder<JsonObject?>? _trainingIteration;
  ListBuilder<JsonObject?> get trainingIteration =>
      _$this._trainingIteration ??= ListBuilder<JsonObject?>();
  set trainingIteration(ListBuilder<JsonObject?>? trainingIteration) =>
      _$this._trainingIteration = trainingIteration;

  BiotrainerModelUpdateBuilder() {
    BiotrainerModelUpdate._defaults(this);
  }

  BiotrainerModelUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _currentModelResult = $v.currentModelResult.toBuilder();
      _trainingIteration = $v.trainingIteration?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BiotrainerModelUpdate other) {
    _$v = other as _$BiotrainerModelUpdate;
  }

  @override
  void update(void Function(BiotrainerModelUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BiotrainerModelUpdate build() => _build();

  _$BiotrainerModelUpdate _build() {
    _$BiotrainerModelUpdate _$result;
    try {
      _$result = _$v ??
          _$BiotrainerModelUpdate._(
            currentModelResult: currentModelResult.build(),
            trainingIteration: _trainingIteration?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'currentModelResult';
        currentModelResult.build();
        _$failedField = 'trainingIteration';
        _trainingIteration?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BiotrainerModelUpdate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
