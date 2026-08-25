// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'not_found_error_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotFoundErrorResponse extends NotFoundErrorResponse {
  @override
  final String error;
  @override
  final String? errorType;
  @override
  final String? details;
  @override
  final int? errorCode;

  factory _$NotFoundErrorResponse(
          [void Function(NotFoundErrorResponseBuilder)? updates]) =>
      (NotFoundErrorResponseBuilder()..update(updates))._build();

  _$NotFoundErrorResponse._(
      {required this.error, this.errorType, this.details, this.errorCode})
      : super._();
  @override
  NotFoundErrorResponse rebuild(
          void Function(NotFoundErrorResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotFoundErrorResponseBuilder toBuilder() =>
      NotFoundErrorResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotFoundErrorResponse &&
        error == other.error &&
        errorType == other.errorType &&
        details == other.details &&
        errorCode == other.errorCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, errorType.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jc(_$hash, errorCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotFoundErrorResponse')
          ..add('error', error)
          ..add('errorType', errorType)
          ..add('details', details)
          ..add('errorCode', errorCode))
        .toString();
  }
}

class NotFoundErrorResponseBuilder
    implements Builder<NotFoundErrorResponse, NotFoundErrorResponseBuilder> {
  _$NotFoundErrorResponse? _$v;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  String? _errorType;
  String? get errorType => _$this._errorType;
  set errorType(String? errorType) => _$this._errorType = errorType;

  String? _details;
  String? get details => _$this._details;
  set details(String? details) => _$this._details = details;

  int? _errorCode;
  int? get errorCode => _$this._errorCode;
  set errorCode(int? errorCode) => _$this._errorCode = errorCode;

  NotFoundErrorResponseBuilder() {
    NotFoundErrorResponse._defaults(this);
  }

  NotFoundErrorResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _errorType = $v.errorType;
      _details = $v.details;
      _errorCode = $v.errorCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotFoundErrorResponse other) {
    _$v = other as _$NotFoundErrorResponse;
  }

  @override
  void update(void Function(NotFoundErrorResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotFoundErrorResponse build() => _build();

  _$NotFoundErrorResponse _build() {
    final _$result = _$v ??
        _$NotFoundErrorResponse._(
          error: BuiltValueNullFieldError.checkNotNull(
              error, r'NotFoundErrorResponse', 'error'),
          errorType: errorType,
          details: details,
          errorCode: errorCode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
