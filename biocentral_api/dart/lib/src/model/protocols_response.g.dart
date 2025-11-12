// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocols_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProtocolsResponse extends ProtocolsResponse {
  @override
  final BuiltList<String> protocols;

  factory _$ProtocolsResponse(
          [void Function(ProtocolsResponseBuilder)? updates]) =>
      (ProtocolsResponseBuilder()..update(updates))._build();

  _$ProtocolsResponse._({required this.protocols}) : super._();
  @override
  ProtocolsResponse rebuild(void Function(ProtocolsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProtocolsResponseBuilder toBuilder() =>
      ProtocolsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProtocolsResponse && protocols == other.protocols;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, protocols.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProtocolsResponse')
          ..add('protocols', protocols))
        .toString();
  }
}

class ProtocolsResponseBuilder
    implements Builder<ProtocolsResponse, ProtocolsResponseBuilder> {
  _$ProtocolsResponse? _$v;

  ListBuilder<String>? _protocols;
  ListBuilder<String> get protocols =>
      _$this._protocols ??= ListBuilder<String>();
  set protocols(ListBuilder<String>? protocols) =>
      _$this._protocols = protocols;

  ProtocolsResponseBuilder() {
    ProtocolsResponse._defaults(this);
  }

  ProtocolsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _protocols = $v.protocols.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProtocolsResponse other) {
    _$v = other as _$ProtocolsResponse;
  }

  @override
  void update(void Function(ProtocolsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProtocolsResponse build() => _build();

  _$ProtocolsResponse _build() {
    _$ProtocolsResponse _$result;
    try {
      _$result = _$v ??
          _$ProtocolsResponse._(
            protocols: protocols.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'protocols';
        protocols.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProtocolsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
