// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projection_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProjectionResult extends ProjectionResult {
  @override
  final ProteinAnnotations proteinAnnotations;
  @override
  final ProjectionsMetadata projectionsMetadata;
  @override
  final ProjectionsData projectionsData;

  factory _$ProjectionResult(
          [void Function(ProjectionResultBuilder)? updates]) =>
      (ProjectionResultBuilder()..update(updates))._build();

  _$ProjectionResult._(
      {required this.proteinAnnotations,
      required this.projectionsMetadata,
      required this.projectionsData})
      : super._();
  @override
  ProjectionResult rebuild(void Function(ProjectionResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectionResultBuilder toBuilder() =>
      ProjectionResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProjectionResult &&
        proteinAnnotations == other.proteinAnnotations &&
        projectionsMetadata == other.projectionsMetadata &&
        projectionsData == other.projectionsData;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, proteinAnnotations.hashCode);
    _$hash = $jc(_$hash, projectionsMetadata.hashCode);
    _$hash = $jc(_$hash, projectionsData.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProjectionResult')
          ..add('proteinAnnotations', proteinAnnotations)
          ..add('projectionsMetadata', projectionsMetadata)
          ..add('projectionsData', projectionsData))
        .toString();
  }
}

class ProjectionResultBuilder
    implements Builder<ProjectionResult, ProjectionResultBuilder> {
  _$ProjectionResult? _$v;

  ProteinAnnotationsBuilder? _proteinAnnotations;
  ProteinAnnotationsBuilder get proteinAnnotations =>
      _$this._proteinAnnotations ??= ProteinAnnotationsBuilder();
  set proteinAnnotations(ProteinAnnotationsBuilder? proteinAnnotations) =>
      _$this._proteinAnnotations = proteinAnnotations;

  ProjectionsMetadataBuilder? _projectionsMetadata;
  ProjectionsMetadataBuilder get projectionsMetadata =>
      _$this._projectionsMetadata ??= ProjectionsMetadataBuilder();
  set projectionsMetadata(ProjectionsMetadataBuilder? projectionsMetadata) =>
      _$this._projectionsMetadata = projectionsMetadata;

  ProjectionsDataBuilder? _projectionsData;
  ProjectionsDataBuilder get projectionsData =>
      _$this._projectionsData ??= ProjectionsDataBuilder();
  set projectionsData(ProjectionsDataBuilder? projectionsData) =>
      _$this._projectionsData = projectionsData;

  ProjectionResultBuilder() {
    ProjectionResult._defaults(this);
  }

  ProjectionResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _proteinAnnotations = $v.proteinAnnotations.toBuilder();
      _projectionsMetadata = $v.projectionsMetadata.toBuilder();
      _projectionsData = $v.projectionsData.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProjectionResult other) {
    _$v = other as _$ProjectionResult;
  }

  @override
  void update(void Function(ProjectionResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProjectionResult build() => _build();

  _$ProjectionResult _build() {
    _$ProjectionResult _$result;
    try {
      _$result = _$v ??
          _$ProjectionResult._(
            proteinAnnotations: proteinAnnotations.build(),
            projectionsMetadata: projectionsMetadata.build(),
            projectionsData: projectionsData.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'proteinAnnotations';
        proteinAnnotations.build();
        _$failedField = 'projectionsMetadata';
        projectionsMetadata.build();
        _$failedField = 'projectionsData';
        projectionsData.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProjectionResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
