// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_detect_format_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AutoDetectFormatRequest extends AutoDetectFormatRequest {
  @override
  final String header;

  factory _$AutoDetectFormatRequest(
          [void Function(AutoDetectFormatRequestBuilder)? updates]) =>
      (AutoDetectFormatRequestBuilder()..update(updates))._build();

  _$AutoDetectFormatRequest._({required this.header}) : super._();
  @override
  AutoDetectFormatRequest rebuild(
          void Function(AutoDetectFormatRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AutoDetectFormatRequestBuilder toBuilder() =>
      AutoDetectFormatRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AutoDetectFormatRequest && header == other.header;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, header.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AutoDetectFormatRequest')
          ..add('header', header))
        .toString();
  }
}

class AutoDetectFormatRequestBuilder
    implements
        Builder<AutoDetectFormatRequest, AutoDetectFormatRequestBuilder> {
  _$AutoDetectFormatRequest? _$v;

  String? _header;
  String? get header => _$this._header;
  set header(String? header) => _$this._header = header;

  AutoDetectFormatRequestBuilder() {
    AutoDetectFormatRequest._defaults(this);
  }

  AutoDetectFormatRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _header = $v.header;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AutoDetectFormatRequest other) {
    _$v = other as _$AutoDetectFormatRequest;
  }

  @override
  void update(void Function(AutoDetectFormatRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AutoDetectFormatRequest build() => _build();

  _$AutoDetectFormatRequest _build() {
    final _$result = _$v ??
        _$AutoDetectFormatRequest._(
          header: BuiltValueNullFieldError.checkNotNull(
              header, r'AutoDetectFormatRequest', 'header'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
