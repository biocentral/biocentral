// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plm_eval_task_information.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PLMEvalTaskInformation extends PLMEvalTaskInformation {
  @override
  final String name;
  @override
  final String description;

  factory _$PLMEvalTaskInformation(
          [void Function(PLMEvalTaskInformationBuilder)? updates]) =>
      (PLMEvalTaskInformationBuilder()..update(updates))._build();

  _$PLMEvalTaskInformation._({required this.name, required this.description})
      : super._();
  @override
  PLMEvalTaskInformation rebuild(
          void Function(PLMEvalTaskInformationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PLMEvalTaskInformationBuilder toBuilder() =>
      PLMEvalTaskInformationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PLMEvalTaskInformation &&
        name == other.name &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PLMEvalTaskInformation')
          ..add('name', name)
          ..add('description', description))
        .toString();
  }
}

class PLMEvalTaskInformationBuilder
    implements Builder<PLMEvalTaskInformation, PLMEvalTaskInformationBuilder> {
  _$PLMEvalTaskInformation? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  PLMEvalTaskInformationBuilder() {
    PLMEvalTaskInformation._defaults(this);
  }

  PLMEvalTaskInformationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PLMEvalTaskInformation other) {
    _$v = other as _$PLMEvalTaskInformation;
  }

  @override
  void update(void Function(PLMEvalTaskInformationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PLMEvalTaskInformation build() => _build();

  _$PLMEvalTaskInformation _build() {
    final _$result = _$v ??
        _$PLMEvalTaskInformation._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PLMEvalTaskInformation', 'name'),
          description: BuiltValueNullFieldError.checkNotNull(
              description, r'PLMEvalTaskInformation', 'description'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
