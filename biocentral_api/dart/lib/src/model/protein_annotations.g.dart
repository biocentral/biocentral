// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protein_annotations.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProteinAnnotations extends ProteinAnnotations {
  @override
  final BuiltList<String> proteinId;

  factory _$ProteinAnnotations(
          [void Function(ProteinAnnotationsBuilder)? updates]) =>
      (ProteinAnnotationsBuilder()..update(updates))._build();

  _$ProteinAnnotations._({required this.proteinId}) : super._();
  @override
  ProteinAnnotations rebuild(
          void Function(ProteinAnnotationsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProteinAnnotationsBuilder toBuilder() =>
      ProteinAnnotationsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProteinAnnotations && proteinId == other.proteinId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, proteinId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProteinAnnotations')
          ..add('proteinId', proteinId))
        .toString();
  }
}

class ProteinAnnotationsBuilder
    implements Builder<ProteinAnnotations, ProteinAnnotationsBuilder> {
  _$ProteinAnnotations? _$v;

  ListBuilder<String>? _proteinId;
  ListBuilder<String> get proteinId =>
      _$this._proteinId ??= ListBuilder<String>();
  set proteinId(ListBuilder<String>? proteinId) =>
      _$this._proteinId = proteinId;

  ProteinAnnotationsBuilder() {
    ProteinAnnotations._defaults(this);
  }

  ProteinAnnotationsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _proteinId = $v.proteinId.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProteinAnnotations other) {
    _$v = other as _$ProteinAnnotations;
  }

  @override
  void update(void Function(ProteinAnnotationsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProteinAnnotations build() => _build();

  _$ProteinAnnotations _build() {
    _$ProteinAnnotations _$result;
    try {
      _$result = _$v ??
          _$ProteinAnnotations._(
            proteinId: proteinId.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'proteinId';
        proteinId.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProteinAnnotations', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
