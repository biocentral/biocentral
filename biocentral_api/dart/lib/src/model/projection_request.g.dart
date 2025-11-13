// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projection_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProjectionRequest extends ProjectionRequest {
  @override
  final BuiltMap<String, String> sequenceData;
  @override
  final String method;
  @override
  final BuiltMap<String, JsonObject?> config;
  @override
  final String embedderName;

  factory _$ProjectionRequest(
          [void Function(ProjectionRequestBuilder)? updates]) =>
      (ProjectionRequestBuilder()..update(updates))._build();

  _$ProjectionRequest._(
      {required this.sequenceData,
      required this.method,
      required this.config,
      required this.embedderName})
      : super._();
  @override
  ProjectionRequest rebuild(void Function(ProjectionRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectionRequestBuilder toBuilder() =>
      ProjectionRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProjectionRequest &&
        sequenceData == other.sequenceData &&
        method == other.method &&
        config == other.config &&
        embedderName == other.embedderName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sequenceData.hashCode);
    _$hash = $jc(_$hash, method.hashCode);
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jc(_$hash, embedderName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProjectionRequest')
          ..add('sequenceData', sequenceData)
          ..add('method', method)
          ..add('config', config)
          ..add('embedderName', embedderName))
        .toString();
  }
}

class ProjectionRequestBuilder
    implements Builder<ProjectionRequest, ProjectionRequestBuilder> {
  _$ProjectionRequest? _$v;

  MapBuilder<String, String>? _sequenceData;
  MapBuilder<String, String> get sequenceData =>
      _$this._sequenceData ??= MapBuilder<String, String>();
  set sequenceData(MapBuilder<String, String>? sequenceData) =>
      _$this._sequenceData = sequenceData;

  String? _method;
  String? get method => _$this._method;
  set method(String? method) => _$this._method = method;

  MapBuilder<String, JsonObject?>? _config;
  MapBuilder<String, JsonObject?> get config =>
      _$this._config ??= MapBuilder<String, JsonObject?>();
  set config(MapBuilder<String, JsonObject?>? config) =>
      _$this._config = config;

  String? _embedderName;
  String? get embedderName => _$this._embedderName;
  set embedderName(String? embedderName) => _$this._embedderName = embedderName;

  ProjectionRequestBuilder() {
    ProjectionRequest._defaults(this);
  }

  ProjectionRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sequenceData = $v.sequenceData.toBuilder();
      _method = $v.method;
      _config = $v.config.toBuilder();
      _embedderName = $v.embedderName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProjectionRequest other) {
    _$v = other as _$ProjectionRequest;
  }

  @override
  void update(void Function(ProjectionRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProjectionRequest build() => _build();

  _$ProjectionRequest _build() {
    _$ProjectionRequest _$result;
    try {
      _$result = _$v ??
          _$ProjectionRequest._(
            sequenceData: sequenceData.build(),
            method: BuiltValueNullFieldError.checkNotNull(
                method, r'ProjectionRequest', 'method'),
            config: config.build(),
            embedderName: BuiltValueNullFieldError.checkNotNull(
                embedderName, r'ProjectionRequest', 'embedderName'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sequenceData';
        sequenceData.build();

        _$failedField = 'config';
        config.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProjectionRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
