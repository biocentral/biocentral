// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_projection_config_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetProjectionConfigResponse extends GetProjectionConfigResponse {
  @override
  final BuiltMap<String, BuiltList<JsonObject?>> projectionConfig;

  factory _$GetProjectionConfigResponse(
          [void Function(GetProjectionConfigResponseBuilder)? updates]) =>
      (GetProjectionConfigResponseBuilder()..update(updates))._build();

  _$GetProjectionConfigResponse._({required this.projectionConfig}) : super._();
  @override
  GetProjectionConfigResponse rebuild(
          void Function(GetProjectionConfigResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetProjectionConfigResponseBuilder toBuilder() =>
      GetProjectionConfigResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetProjectionConfigResponse &&
        projectionConfig == other.projectionConfig;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, projectionConfig.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetProjectionConfigResponse')
          ..add('projectionConfig', projectionConfig))
        .toString();
  }
}

class GetProjectionConfigResponseBuilder
    implements
        Builder<GetProjectionConfigResponse,
            GetProjectionConfigResponseBuilder> {
  _$GetProjectionConfigResponse? _$v;

  MapBuilder<String, BuiltList<JsonObject?>>? _projectionConfig;
  MapBuilder<String, BuiltList<JsonObject?>> get projectionConfig =>
      _$this._projectionConfig ??= MapBuilder<String, BuiltList<JsonObject?>>();
  set projectionConfig(
          MapBuilder<String, BuiltList<JsonObject?>>? projectionConfig) =>
      _$this._projectionConfig = projectionConfig;

  GetProjectionConfigResponseBuilder() {
    GetProjectionConfigResponse._defaults(this);
  }

  GetProjectionConfigResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _projectionConfig = $v.projectionConfig.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetProjectionConfigResponse other) {
    _$v = other as _$GetProjectionConfigResponse;
  }

  @override
  void update(void Function(GetProjectionConfigResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetProjectionConfigResponse build() => _build();

  _$GetProjectionConfigResponse _build() {
    _$GetProjectionConfigResponse _$result;
    try {
      _$result = _$v ??
          _$GetProjectionConfigResponse._(
            projectionConfig: projectionConfig.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'projectionConfig';
        projectionConfig.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetProjectionConfigResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
