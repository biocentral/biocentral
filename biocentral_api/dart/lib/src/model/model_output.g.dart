// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ModelOutput extends ModelOutput {
  @override
  final String name;
  @override
  final String description;
  @override
  final OutputType outputType;
  @override
  final String valueType;
  @override
  final BuiltList<OutputClass>? classes;
  @override
  final BuiltList<JsonObject?>? valueRange;
  @override
  final String? unit;

  factory _$ModelOutput([void Function(ModelOutputBuilder)? updates]) =>
      (ModelOutputBuilder()..update(updates))._build();

  _$ModelOutput._(
      {required this.name,
      required this.description,
      required this.outputType,
      required this.valueType,
      this.classes,
      this.valueRange,
      this.unit})
      : super._();
  @override
  ModelOutput rebuild(void Function(ModelOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ModelOutputBuilder toBuilder() => ModelOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModelOutput &&
        name == other.name &&
        description == other.description &&
        outputType == other.outputType &&
        valueType == other.valueType &&
        classes == other.classes &&
        valueRange == other.valueRange &&
        unit == other.unit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, outputType.hashCode);
    _$hash = $jc(_$hash, valueType.hashCode);
    _$hash = $jc(_$hash, classes.hashCode);
    _$hash = $jc(_$hash, valueRange.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ModelOutput')
          ..add('name', name)
          ..add('description', description)
          ..add('outputType', outputType)
          ..add('valueType', valueType)
          ..add('classes', classes)
          ..add('valueRange', valueRange)
          ..add('unit', unit))
        .toString();
  }
}

class ModelOutputBuilder implements Builder<ModelOutput, ModelOutputBuilder> {
  _$ModelOutput? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  OutputType? _outputType;
  OutputType? get outputType => _$this._outputType;
  set outputType(OutputType? outputType) => _$this._outputType = outputType;

  String? _valueType;
  String? get valueType => _$this._valueType;
  set valueType(String? valueType) => _$this._valueType = valueType;

  ListBuilder<OutputClass>? _classes;
  ListBuilder<OutputClass> get classes =>
      _$this._classes ??= ListBuilder<OutputClass>();
  set classes(ListBuilder<OutputClass>? classes) => _$this._classes = classes;

  ListBuilder<JsonObject?>? _valueRange;
  ListBuilder<JsonObject?> get valueRange =>
      _$this._valueRange ??= ListBuilder<JsonObject?>();
  set valueRange(ListBuilder<JsonObject?>? valueRange) =>
      _$this._valueRange = valueRange;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  ModelOutputBuilder() {
    ModelOutput._defaults(this);
  }

  ModelOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _outputType = $v.outputType;
      _valueType = $v.valueType;
      _classes = $v.classes?.toBuilder();
      _valueRange = $v.valueRange?.toBuilder();
      _unit = $v.unit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModelOutput other) {
    _$v = other as _$ModelOutput;
  }

  @override
  void update(void Function(ModelOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModelOutput build() => _build();

  _$ModelOutput _build() {
    _$ModelOutput _$result;
    try {
      _$result = _$v ??
          _$ModelOutput._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ModelOutput', 'name'),
            description: BuiltValueNullFieldError.checkNotNull(
                description, r'ModelOutput', 'description'),
            outputType: BuiltValueNullFieldError.checkNotNull(
                outputType, r'ModelOutput', 'outputType'),
            valueType: BuiltValueNullFieldError.checkNotNull(
                valueType, r'ModelOutput', 'valueType'),
            classes: _classes?.build(),
            valueRange: _valueRange?.build(),
            unit: unit,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'classes';
        _classes?.build();
        _$failedField = 'valueRange';
        _valueRange?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ModelOutput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
