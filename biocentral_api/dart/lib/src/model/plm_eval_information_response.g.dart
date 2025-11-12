// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plm_eval_information_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PLMEvalInformationResponse extends PLMEvalInformationResponse {
  @override
  final PLMEvalInformation info;

  factory _$PLMEvalInformationResponse(
          [void Function(PLMEvalInformationResponseBuilder)? updates]) =>
      (PLMEvalInformationResponseBuilder()..update(updates))._build();

  _$PLMEvalInformationResponse._({required this.info}) : super._();
  @override
  PLMEvalInformationResponse rebuild(
          void Function(PLMEvalInformationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PLMEvalInformationResponseBuilder toBuilder() =>
      PLMEvalInformationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PLMEvalInformationResponse && info == other.info;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, info.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PLMEvalInformationResponse')
          ..add('info', info))
        .toString();
  }
}

class PLMEvalInformationResponseBuilder
    implements
        Builder<PLMEvalInformationResponse, PLMEvalInformationResponseBuilder> {
  _$PLMEvalInformationResponse? _$v;

  PLMEvalInformationBuilder? _info;
  PLMEvalInformationBuilder get info =>
      _$this._info ??= PLMEvalInformationBuilder();
  set info(PLMEvalInformationBuilder? info) => _$this._info = info;

  PLMEvalInformationResponseBuilder() {
    PLMEvalInformationResponse._defaults(this);
  }

  PLMEvalInformationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _info = $v.info.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PLMEvalInformationResponse other) {
    _$v = other as _$PLMEvalInformationResponse;
  }

  @override
  void update(void Function(PLMEvalInformationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PLMEvalInformationResponse build() => _build();

  _$PLMEvalInformationResponse _build() {
    _$PLMEvalInformationResponse _$result;
    try {
      _$result = _$v ??
          _$PLMEvalInformationResponse._(
            info: info.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'info';
        info.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PLMEvalInformationResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
