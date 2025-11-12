// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_options_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfigOptionsResponse extends ConfigOptionsResponse {
  @override
  final BuiltList<ConfigOption> options;

  factory _$ConfigOptionsResponse(
          [void Function(ConfigOptionsResponseBuilder)? updates]) =>
      (ConfigOptionsResponseBuilder()..update(updates))._build();

  _$ConfigOptionsResponse._({required this.options}) : super._();
  @override
  ConfigOptionsResponse rebuild(
          void Function(ConfigOptionsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfigOptionsResponseBuilder toBuilder() =>
      ConfigOptionsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfigOptionsResponse && options == other.options;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, options.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfigOptionsResponse')
          ..add('options', options))
        .toString();
  }
}

class ConfigOptionsResponseBuilder
    implements Builder<ConfigOptionsResponse, ConfigOptionsResponseBuilder> {
  _$ConfigOptionsResponse? _$v;

  ListBuilder<ConfigOption>? _options;
  ListBuilder<ConfigOption> get options =>
      _$this._options ??= ListBuilder<ConfigOption>();
  set options(ListBuilder<ConfigOption>? options) => _$this._options = options;

  ConfigOptionsResponseBuilder() {
    ConfigOptionsResponse._defaults(this);
  }

  ConfigOptionsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _options = $v.options.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfigOptionsResponse other) {
    _$v = other as _$ConfigOptionsResponse;
  }

  @override
  void update(void Function(ConfigOptionsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfigOptionsResponse build() => _build();

  _$ConfigOptionsResponse _build() {
    _$ConfigOptionsResponse _$result;
    try {
      _$result = _$v ??
          _$ConfigOptionsResponse._(
            options: options.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'options';
        options.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ConfigOptionsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
