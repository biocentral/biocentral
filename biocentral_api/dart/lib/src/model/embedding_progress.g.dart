// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedding_progress.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EmbeddingProgress extends EmbeddingProgress {
  @override
  final int current;
  @override
  final int total;

  factory _$EmbeddingProgress(
          [void Function(EmbeddingProgressBuilder)? updates]) =>
      (EmbeddingProgressBuilder()..update(updates))._build();

  _$EmbeddingProgress._({required this.current, required this.total})
      : super._();
  @override
  EmbeddingProgress rebuild(void Function(EmbeddingProgressBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EmbeddingProgressBuilder toBuilder() =>
      EmbeddingProgressBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EmbeddingProgress &&
        current == other.current &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, current.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EmbeddingProgress')
          ..add('current', current)
          ..add('total', total))
        .toString();
  }
}

class EmbeddingProgressBuilder
    implements Builder<EmbeddingProgress, EmbeddingProgressBuilder> {
  _$EmbeddingProgress? _$v;

  int? _current;
  int? get current => _$this._current;
  set current(int? current) => _$this._current = current;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  EmbeddingProgressBuilder() {
    EmbeddingProgress._defaults(this);
  }

  EmbeddingProgressBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EmbeddingProgress other) {
    _$v = other as _$EmbeddingProgress;
  }

  @override
  void update(void Function(EmbeddingProgressBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EmbeddingProgress build() => _build();

  _$EmbeddingProgress _build() {
    final _$result = _$v ??
        _$EmbeddingProgress._(
          current: BuiltValueNullFieldError.checkNotNull(
              current, r'EmbeddingProgress', 'current'),
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'EmbeddingProgress', 'total'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
