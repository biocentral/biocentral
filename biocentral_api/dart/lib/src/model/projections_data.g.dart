// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projections_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProjectionsData extends ProjectionsData {
  @override
  final BuiltList<String> projectionName;
  @override
  final BuiltList<String> identifier;
  @override
  final BuiltList<num> x;
  @override
  final BuiltList<num> y;
  @override
  final BuiltList<num?> z;

  factory _$ProjectionsData([void Function(ProjectionsDataBuilder)? updates]) =>
      (ProjectionsDataBuilder()..update(updates))._build();

  _$ProjectionsData._(
      {required this.projectionName,
      required this.identifier,
      required this.x,
      required this.y,
      required this.z})
      : super._();
  @override
  ProjectionsData rebuild(void Function(ProjectionsDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectionsDataBuilder toBuilder() => ProjectionsDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProjectionsData &&
        projectionName == other.projectionName &&
        identifier == other.identifier &&
        x == other.x &&
        y == other.y &&
        z == other.z;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, projectionName.hashCode);
    _$hash = $jc(_$hash, identifier.hashCode);
    _$hash = $jc(_$hash, x.hashCode);
    _$hash = $jc(_$hash, y.hashCode);
    _$hash = $jc(_$hash, z.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProjectionsData')
          ..add('projectionName', projectionName)
          ..add('identifier', identifier)
          ..add('x', x)
          ..add('y', y)
          ..add('z', z))
        .toString();
  }
}

class ProjectionsDataBuilder
    implements Builder<ProjectionsData, ProjectionsDataBuilder> {
  _$ProjectionsData? _$v;

  ListBuilder<String>? _projectionName;
  ListBuilder<String> get projectionName =>
      _$this._projectionName ??= ListBuilder<String>();
  set projectionName(ListBuilder<String>? projectionName) =>
      _$this._projectionName = projectionName;

  ListBuilder<String>? _identifier;
  ListBuilder<String> get identifier =>
      _$this._identifier ??= ListBuilder<String>();
  set identifier(ListBuilder<String>? identifier) =>
      _$this._identifier = identifier;

  ListBuilder<num>? _x;
  ListBuilder<num> get x => _$this._x ??= ListBuilder<num>();
  set x(ListBuilder<num>? x) => _$this._x = x;

  ListBuilder<num>? _y;
  ListBuilder<num> get y => _$this._y ??= ListBuilder<num>();
  set y(ListBuilder<num>? y) => _$this._y = y;

  ListBuilder<num?>? _z;
  ListBuilder<num?> get z => _$this._z ??= ListBuilder<num?>();
  set z(ListBuilder<num?>? z) => _$this._z = z;

  ProjectionsDataBuilder() {
    ProjectionsData._defaults(this);
  }

  ProjectionsDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _projectionName = $v.projectionName.toBuilder();
      _identifier = $v.identifier.toBuilder();
      _x = $v.x.toBuilder();
      _y = $v.y.toBuilder();
      _z = $v.z.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProjectionsData other) {
    _$v = other as _$ProjectionsData;
  }

  @override
  void update(void Function(ProjectionsDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProjectionsData build() => _build();

  _$ProjectionsData _build() {
    _$ProjectionsData _$result;
    try {
      _$result = _$v ??
          _$ProjectionsData._(
            projectionName: projectionName.build(),
            identifier: identifier.build(),
            x: x.build(),
            y: y.build(),
            z: z.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'projectionName';
        projectionName.build();
        _$failedField = 'identifier';
        identifier.build();
        _$failedField = 'x';
        x.build();
        _$failedField = 'y';
        y.build();
        _$failedField = 'z';
        z.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProjectionsData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
