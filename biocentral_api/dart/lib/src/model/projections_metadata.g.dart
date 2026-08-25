// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projections_metadata.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProjectionsMetadata extends ProjectionsMetadata {
  @override
  final BuiltList<String> projectionName;
  @override
  final BuiltList<int> dimensions;
  @override
  final BuiltList<String> infoJson;

  factory _$ProjectionsMetadata(
          [void Function(ProjectionsMetadataBuilder)? updates]) =>
      (ProjectionsMetadataBuilder()..update(updates))._build();

  _$ProjectionsMetadata._(
      {required this.projectionName,
      required this.dimensions,
      required this.infoJson})
      : super._();
  @override
  ProjectionsMetadata rebuild(
          void Function(ProjectionsMetadataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectionsMetadataBuilder toBuilder() =>
      ProjectionsMetadataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProjectionsMetadata &&
        projectionName == other.projectionName &&
        dimensions == other.dimensions &&
        infoJson == other.infoJson;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, projectionName.hashCode);
    _$hash = $jc(_$hash, dimensions.hashCode);
    _$hash = $jc(_$hash, infoJson.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProjectionsMetadata')
          ..add('projectionName', projectionName)
          ..add('dimensions', dimensions)
          ..add('infoJson', infoJson))
        .toString();
  }
}

class ProjectionsMetadataBuilder
    implements Builder<ProjectionsMetadata, ProjectionsMetadataBuilder> {
  _$ProjectionsMetadata? _$v;

  ListBuilder<String>? _projectionName;
  ListBuilder<String> get projectionName =>
      _$this._projectionName ??= ListBuilder<String>();
  set projectionName(ListBuilder<String>? projectionName) =>
      _$this._projectionName = projectionName;

  ListBuilder<int>? _dimensions;
  ListBuilder<int> get dimensions => _$this._dimensions ??= ListBuilder<int>();
  set dimensions(ListBuilder<int>? dimensions) =>
      _$this._dimensions = dimensions;

  ListBuilder<String>? _infoJson;
  ListBuilder<String> get infoJson =>
      _$this._infoJson ??= ListBuilder<String>();
  set infoJson(ListBuilder<String>? infoJson) => _$this._infoJson = infoJson;

  ProjectionsMetadataBuilder() {
    ProjectionsMetadata._defaults(this);
  }

  ProjectionsMetadataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _projectionName = $v.projectionName.toBuilder();
      _dimensions = $v.dimensions.toBuilder();
      _infoJson = $v.infoJson.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProjectionsMetadata other) {
    _$v = other as _$ProjectionsMetadata;
  }

  @override
  void update(void Function(ProjectionsMetadataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProjectionsMetadata build() => _build();

  _$ProjectionsMetadata _build() {
    _$ProjectionsMetadata _$result;
    try {
      _$result = _$v ??
          _$ProjectionsMetadata._(
            projectionName: projectionName.build(),
            dimensions: dimensions.build(),
            infoJson: infoJson.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'projectionName';
        projectionName.build();
        _$failedField = 'dimensions';
        dimensions.build();
        _$failedField = 'infoJson';
        infoJson.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProjectionsMetadata', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
