// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plm_eval_validate_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PLMEvalValidateRequest extends PLMEvalValidateRequest {
  @override
  final String modelId;

  factory _$PLMEvalValidateRequest(
          [void Function(PLMEvalValidateRequestBuilder)? updates]) =>
      (PLMEvalValidateRequestBuilder()..update(updates))._build();

  _$PLMEvalValidateRequest._({required this.modelId}) : super._();
  @override
  PLMEvalValidateRequest rebuild(
          void Function(PLMEvalValidateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PLMEvalValidateRequestBuilder toBuilder() =>
      PLMEvalValidateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PLMEvalValidateRequest && modelId == other.modelId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, modelId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PLMEvalValidateRequest')
          ..add('modelId', modelId))
        .toString();
  }
}

class PLMEvalValidateRequestBuilder
    implements Builder<PLMEvalValidateRequest, PLMEvalValidateRequestBuilder> {
  _$PLMEvalValidateRequest? _$v;

  String? _modelId;
  String? get modelId => _$this._modelId;
  set modelId(String? modelId) => _$this._modelId = modelId;

  PLMEvalValidateRequestBuilder() {
    PLMEvalValidateRequest._defaults(this);
  }

  PLMEvalValidateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _modelId = $v.modelId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PLMEvalValidateRequest other) {
    _$v = other as _$PLMEvalValidateRequest;
  }

  @override
  void update(void Function(PLMEvalValidateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PLMEvalValidateRequest build() => _build();

  _$PLMEvalValidateRequest _build() {
    final _$result = _$v ??
        _$PLMEvalValidateRequest._(
          modelId: BuiltValueNullFieldError.checkNotNull(
              modelId, r'PLMEvalValidateRequest', 'modelId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
