// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_verification_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfigVerificationResponse extends ConfigVerificationResponse {
  @override
  final String? error;

  factory _$ConfigVerificationResponse(
          [void Function(ConfigVerificationResponseBuilder)? updates]) =>
      (ConfigVerificationResponseBuilder()..update(updates))._build();

  _$ConfigVerificationResponse._({this.error}) : super._();
  @override
  ConfigVerificationResponse rebuild(
          void Function(ConfigVerificationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfigVerificationResponseBuilder toBuilder() =>
      ConfigVerificationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfigVerificationResponse && error == other.error;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfigVerificationResponse')
          ..add('error', error))
        .toString();
  }
}

class ConfigVerificationResponseBuilder
    implements
        Builder<ConfigVerificationResponse, ConfigVerificationResponseBuilder> {
  _$ConfigVerificationResponse? _$v;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  ConfigVerificationResponseBuilder() {
    ConfigVerificationResponse._defaults(this);
  }

  ConfigVerificationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfigVerificationResponse other) {
    _$v = other as _$ConfigVerificationResponse;
  }

  @override
  void update(void Function(ConfigVerificationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfigVerificationResponse build() => _build();

  _$ConfigVerificationResponse _build() {
    final _$result = _$v ??
        _$ConfigVerificationResponse._(
          error: error,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
