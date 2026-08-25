// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detected_format_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DetectedFormatResponse extends DetectedFormatResponse {
  @override
  final String detectedFormat;

  factory _$DetectedFormatResponse(
          [void Function(DetectedFormatResponseBuilder)? updates]) =>
      (DetectedFormatResponseBuilder()..update(updates))._build();

  _$DetectedFormatResponse._({required this.detectedFormat}) : super._();
  @override
  DetectedFormatResponse rebuild(
          void Function(DetectedFormatResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DetectedFormatResponseBuilder toBuilder() =>
      DetectedFormatResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DetectedFormatResponse &&
        detectedFormat == other.detectedFormat;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, detectedFormat.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DetectedFormatResponse')
          ..add('detectedFormat', detectedFormat))
        .toString();
  }
}

class DetectedFormatResponseBuilder
    implements Builder<DetectedFormatResponse, DetectedFormatResponseBuilder> {
  _$DetectedFormatResponse? _$v;

  String? _detectedFormat;
  String? get detectedFormat => _$this._detectedFormat;
  set detectedFormat(String? detectedFormat) =>
      _$this._detectedFormat = detectedFormat;

  DetectedFormatResponseBuilder() {
    DetectedFormatResponse._defaults(this);
  }

  DetectedFormatResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _detectedFormat = $v.detectedFormat;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DetectedFormatResponse other) {
    _$v = other as _$DetectedFormatResponse;
  }

  @override
  void update(void Function(DetectedFormatResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DetectedFormatResponse build() => _build();

  _$DetectedFormatResponse _build() {
    final _$result = _$v ??
        _$DetectedFormatResponse._(
          detectedFormat: BuiltValueNullFieldError.checkNotNull(
              detectedFormat, r'DetectedFormatResponse', 'detectedFormat'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
