// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_class.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OutputClass extends OutputClass {
  @override
  final String shortcut;
  @override
  final String label;
  @override
  final String description;

  factory _$OutputClass([void Function(OutputClassBuilder)? updates]) =>
      (OutputClassBuilder()..update(updates))._build();

  _$OutputClass._(
      {required this.shortcut, required this.label, required this.description})
      : super._();
  @override
  OutputClass rebuild(void Function(OutputClassBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OutputClassBuilder toBuilder() => OutputClassBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OutputClass &&
        shortcut == other.shortcut &&
        label == other.label &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, shortcut.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OutputClass')
          ..add('shortcut', shortcut)
          ..add('label', label)
          ..add('description', description))
        .toString();
  }
}

class OutputClassBuilder implements Builder<OutputClass, OutputClassBuilder> {
  _$OutputClass? _$v;

  String? _shortcut;
  String? get shortcut => _$this._shortcut;
  set shortcut(String? shortcut) => _$this._shortcut = shortcut;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  OutputClassBuilder() {
    OutputClass._defaults(this);
  }

  OutputClassBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _shortcut = $v.shortcut;
      _label = $v.label;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OutputClass other) {
    _$v = other as _$OutputClass;
  }

  @override
  void update(void Function(OutputClassBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OutputClass build() => _build();

  _$OutputClass _build() {
    final _$result = _$v ??
        _$OutputClass._(
          shortcut: BuiltValueNullFieldError.checkNotNull(
              shortcut, r'OutputClass', 'shortcut'),
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'OutputClass', 'label'),
          description: BuiltValueNullFieldError.checkNotNull(
              description, r'OutputClass', 'description'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
