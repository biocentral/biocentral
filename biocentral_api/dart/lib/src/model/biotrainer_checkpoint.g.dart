// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biotrainer_checkpoint.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BiotrainerCheckpoint extends BiotrainerCheckpoint {
  @override
  final String name;
  @override
  final Uint8List checkpoint;

  factory _$BiotrainerCheckpoint(
          [void Function(BiotrainerCheckpointBuilder)? updates]) =>
      (BiotrainerCheckpointBuilder()..update(updates))._build();

  _$BiotrainerCheckpoint._({required this.name, required this.checkpoint})
      : super._();
  @override
  BiotrainerCheckpoint rebuild(
          void Function(BiotrainerCheckpointBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BiotrainerCheckpointBuilder toBuilder() =>
      BiotrainerCheckpointBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BiotrainerCheckpoint &&
        name == other.name &&
        checkpoint == other.checkpoint;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, checkpoint.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BiotrainerCheckpoint')
          ..add('name', name)
          ..add('checkpoint', checkpoint))
        .toString();
  }
}

class BiotrainerCheckpointBuilder
    implements Builder<BiotrainerCheckpoint, BiotrainerCheckpointBuilder> {
  _$BiotrainerCheckpoint? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  Uint8List? _checkpoint;
  Uint8List? get checkpoint => _$this._checkpoint;
  set checkpoint(Uint8List? checkpoint) => _$this._checkpoint = checkpoint;

  BiotrainerCheckpointBuilder() {
    BiotrainerCheckpoint._defaults(this);
  }

  BiotrainerCheckpointBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _checkpoint = $v.checkpoint;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BiotrainerCheckpoint other) {
    _$v = other as _$BiotrainerCheckpoint;
  }

  @override
  void update(void Function(BiotrainerCheckpointBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BiotrainerCheckpoint build() => _build();

  _$BiotrainerCheckpoint _build() {
    final _$result = _$v ??
        _$BiotrainerCheckpoint._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'BiotrainerCheckpoint', 'name'),
          checkpoint: BuiltValueNullFieldError.checkNotNull(
              checkpoint, r'BiotrainerCheckpoint', 'checkpoint'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
