// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biocentral_server_server_management_shared_endpoint_models_error_models_error_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse
    extends BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse {
  @override
  final String error;
  @override
  final String errorType;
  @override
  final String? details;
  @override
  final int? errorCode;

  factory _$BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse(
          [void Function(
                  BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder)?
              updates]) =>
      (BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder()
            ..update(updates))
          ._build();

  _$BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse._(
      {required this.error,
      required this.errorType,
      this.details,
      this.errorCode})
      : super._();
  @override
  BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse
      rebuild(
              void Function(
                      BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder
      toBuilder() =>
          BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse &&
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
    return (newBuiltValueToStringHelper(
            r'BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse')
          ..add('error', error)
          ..add('errorType', errorType)
          ..add('details', details)
          ..add('errorCode', errorCode))
        .toString();
  }
}

class BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder
    implements
        Builder<
            BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse,
            BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder> {
  _$BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse?
      _$v;

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

  BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder() {
    BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse
        ._defaults(this);
  }

  BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder
      get _$this {
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
  void replace(
      BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse
          other) {
    _$v = other
        as _$BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse;
  }

  @override
  void update(
      void Function(
              BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse
      build() => _build();

  _$BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse
      _build() {
    final _$result = _$v ??
        _$BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse
            ._(
          error: BuiltValueNullFieldError.checkNotNull(
              error,
              r'BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse',
              'error'),
          errorType: BuiltValueNullFieldError.checkNotNull(
              errorType,
              r'BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse',
              'errorType'),
          details: details,
          errorCode: errorCode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
