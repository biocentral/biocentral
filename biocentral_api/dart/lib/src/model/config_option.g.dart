// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_option.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfigOption extends ConfigOption {
  @override
  final String key;
  @override
  final JsonObject? value;

  factory _$ConfigOption([void Function(ConfigOptionBuilder)? updates]) =>
      (ConfigOptionBuilder()..update(updates))._build();

  _$ConfigOption._({required this.key, this.value}) : super._();
  @override
  ConfigOption rebuild(void Function(ConfigOptionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfigOptionBuilder toBuilder() => ConfigOptionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfigOption && key == other.key && value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfigOption')
          ..add('key', key)
          ..add('value', value))
        .toString();
  }
}

class ConfigOptionBuilder
    implements Builder<ConfigOption, ConfigOptionBuilder> {
  _$ConfigOption? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  JsonObject? _value;
  JsonObject? get value => _$this._value;
  set value(JsonObject? value) => _$this._value = value;

  ConfigOptionBuilder() {
    ConfigOption._defaults(this);
  }

  ConfigOptionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfigOption other) {
    _$v = other as _$ConfigOption;
  }

  @override
  void update(void Function(ConfigOptionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfigOption build() => _build();

  _$ConfigOption _build() {
    final _$result = _$v ??
        _$ConfigOption._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'ConfigOption', 'key'),
          value: value,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
