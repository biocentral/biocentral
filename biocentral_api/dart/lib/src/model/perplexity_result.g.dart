// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perplexity_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PerplexityResult extends PerplexityResult {
  @override
  final ZeroShotMethod method;
  @override
  final BuiltMap<String, num> seq2perplexity;

  factory _$PerplexityResult(
          [void Function(PerplexityResultBuilder)? updates]) =>
      (PerplexityResultBuilder()..update(updates))._build();

  _$PerplexityResult._({required this.method, required this.seq2perplexity})
      : super._();
  @override
  PerplexityResult rebuild(void Function(PerplexityResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PerplexityResultBuilder toBuilder() =>
      PerplexityResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PerplexityResult &&
        method == other.method &&
        seq2perplexity == other.seq2perplexity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, method.hashCode);
    _$hash = $jc(_$hash, seq2perplexity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PerplexityResult')
          ..add('method', method)
          ..add('seq2perplexity', seq2perplexity))
        .toString();
  }
}

class PerplexityResultBuilder
    implements Builder<PerplexityResult, PerplexityResultBuilder> {
  _$PerplexityResult? _$v;

  ZeroShotMethod? _method;
  ZeroShotMethod? get method => _$this._method;
  set method(ZeroShotMethod? method) => _$this._method = method;

  MapBuilder<String, num>? _seq2perplexity;
  MapBuilder<String, num> get seq2perplexity =>
      _$this._seq2perplexity ??= MapBuilder<String, num>();
  set seq2perplexity(MapBuilder<String, num>? seq2perplexity) =>
      _$this._seq2perplexity = seq2perplexity;

  PerplexityResultBuilder() {
    PerplexityResult._defaults(this);
  }

  PerplexityResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _method = $v.method;
      _seq2perplexity = $v.seq2perplexity.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PerplexityResult other) {
    _$v = other as _$PerplexityResult;
  }

  @override
  void update(void Function(PerplexityResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PerplexityResult build() => _build();

  _$PerplexityResult _build() {
    _$PerplexityResult _$result;
    try {
      _$result = _$v ??
          _$PerplexityResult._(
            method: BuiltValueNullFieldError.checkNotNull(
                method, r'PerplexityResult', 'method'),
            seq2perplexity: seq2perplexity.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'seq2perplexity';
        seq2perplexity.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PerplexityResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
