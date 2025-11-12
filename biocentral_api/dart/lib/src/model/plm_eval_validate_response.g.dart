// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plm_eval_validate_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PLMEvalValidateResponse extends PLMEvalValidateResponse {
  @override
  final bool valid;
  @override
  final String? error;

  factory _$PLMEvalValidateResponse(
          [void Function(PLMEvalValidateResponseBuilder)? updates]) =>
      (PLMEvalValidateResponseBuilder()..update(updates))._build();

  _$PLMEvalValidateResponse._({required this.valid, this.error}) : super._();
  @override
  PLMEvalValidateResponse rebuild(
          void Function(PLMEvalValidateResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PLMEvalValidateResponseBuilder toBuilder() =>
      PLMEvalValidateResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PLMEvalValidateResponse &&
        valid == other.valid &&
        error == other.error;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, valid.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PLMEvalValidateResponse')
          ..add('valid', valid)
          ..add('error', error))
        .toString();
  }
}

class PLMEvalValidateResponseBuilder
    implements
        Builder<PLMEvalValidateResponse, PLMEvalValidateResponseBuilder> {
  _$PLMEvalValidateResponse? _$v;

  bool? _valid;
  bool? get valid => _$this._valid;
  set valid(bool? valid) => _$this._valid = valid;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  PLMEvalValidateResponseBuilder() {
    PLMEvalValidateResponse._defaults(this);
  }

  PLMEvalValidateResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _valid = $v.valid;
      _error = $v.error;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PLMEvalValidateResponse other) {
    _$v = other as _$PLMEvalValidateResponse;
  }

  @override
  void update(void Function(PLMEvalValidateResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PLMEvalValidateResponse build() => _build();

  _$PLMEvalValidateResponse _build() {
    final _$result = _$v ??
        _$PLMEvalValidateResponse._(
          valid: BuiltValueNullFieldError.checkNotNull(
              valid, r'PLMEvalValidateResponse', 'valid'),
          error: error,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
