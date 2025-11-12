// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biocentral_server_custom_models_endpoint_models_error_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BiocentralServerCustomModelsEndpointModelsErrorResponse
    extends BiocentralServerCustomModelsEndpointModelsErrorResponse {
  @override
  final String error;
  @override
  final String? detail;

  factory _$BiocentralServerCustomModelsEndpointModelsErrorResponse(
          [void Function(
                  BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder)?
              updates]) =>
      (BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder()
            ..update(updates))
          ._build();

  _$BiocentralServerCustomModelsEndpointModelsErrorResponse._(
      {required this.error, this.detail})
      : super._();
  @override
  BiocentralServerCustomModelsEndpointModelsErrorResponse rebuild(
          void Function(
                  BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder toBuilder() =>
      BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BiocentralServerCustomModelsEndpointModelsErrorResponse &&
        error == other.error &&
        detail == other.detail;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, detail.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'BiocentralServerCustomModelsEndpointModelsErrorResponse')
          ..add('error', error)
          ..add('detail', detail))
        .toString();
  }
}

class BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder
    implements
        Builder<BiocentralServerCustomModelsEndpointModelsErrorResponse,
            BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder> {
  _$BiocentralServerCustomModelsEndpointModelsErrorResponse? _$v;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  String? _detail;
  String? get detail => _$this._detail;
  set detail(String? detail) => _$this._detail = detail;

  BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder() {
    BiocentralServerCustomModelsEndpointModelsErrorResponse._defaults(this);
  }

  BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _detail = $v.detail;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BiocentralServerCustomModelsEndpointModelsErrorResponse other) {
    _$v = other as _$BiocentralServerCustomModelsEndpointModelsErrorResponse;
  }

  @override
  void update(
      void Function(
              BiocentralServerCustomModelsEndpointModelsErrorResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  BiocentralServerCustomModelsEndpointModelsErrorResponse build() => _build();

  _$BiocentralServerCustomModelsEndpointModelsErrorResponse _build() {
    final _$result = _$v ??
        _$BiocentralServerCustomModelsEndpointModelsErrorResponse._(
          error: BuiltValueNullFieldError.checkNotNull(
              error,
              r'BiocentralServerCustomModelsEndpointModelsErrorResponse',
              'error'),
          detail: detail,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
