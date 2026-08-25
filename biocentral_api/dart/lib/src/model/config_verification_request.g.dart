// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_verification_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfigVerificationRequest extends ConfigVerificationRequest {
  @override
  final BuiltMap<String, JsonObject?> configDict;

  factory _$ConfigVerificationRequest(
          [void Function(ConfigVerificationRequestBuilder)? updates]) =>
      (ConfigVerificationRequestBuilder()..update(updates))._build();

  _$ConfigVerificationRequest._({required this.configDict}) : super._();
  @override
  ConfigVerificationRequest rebuild(
          void Function(ConfigVerificationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfigVerificationRequestBuilder toBuilder() =>
      ConfigVerificationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfigVerificationRequest && configDict == other.configDict;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, configDict.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfigVerificationRequest')
          ..add('configDict', configDict))
        .toString();
  }
}

class ConfigVerificationRequestBuilder
    implements
        Builder<ConfigVerificationRequest, ConfigVerificationRequestBuilder> {
  _$ConfigVerificationRequest? _$v;

  MapBuilder<String, JsonObject?>? _configDict;
  MapBuilder<String, JsonObject?> get configDict =>
      _$this._configDict ??= MapBuilder<String, JsonObject?>();
  set configDict(MapBuilder<String, JsonObject?>? configDict) =>
      _$this._configDict = configDict;

  ConfigVerificationRequestBuilder() {
    ConfigVerificationRequest._defaults(this);
  }

  ConfigVerificationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _configDict = $v.configDict.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfigVerificationRequest other) {
    _$v = other as _$ConfigVerificationRequest;
  }

  @override
  void update(void Function(ConfigVerificationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfigVerificationRequest build() => _build();

  _$ConfigVerificationRequest _build() {
    _$ConfigVerificationRequest _$result;
    try {
      _$result = _$v ??
          _$ConfigVerificationRequest._(
            configDict: configDict.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'configDict';
        configDict.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ConfigVerificationRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
