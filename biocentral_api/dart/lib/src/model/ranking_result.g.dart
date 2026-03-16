// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RankingResult extends RankingResult {
  @override
  final MetricEstimate scc;
  @override
  final MetricEstimate ndcg;

  factory _$RankingResult([void Function(RankingResultBuilder)? updates]) =>
      (RankingResultBuilder()..update(updates))._build();

  _$RankingResult._({required this.scc, required this.ndcg}) : super._();
  @override
  RankingResult rebuild(void Function(RankingResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RankingResultBuilder toBuilder() => RankingResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RankingResult && scc == other.scc && ndcg == other.ndcg;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, scc.hashCode);
    _$hash = $jc(_$hash, ndcg.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RankingResult')
          ..add('scc', scc)
          ..add('ndcg', ndcg))
        .toString();
  }
}

class RankingResultBuilder
    implements Builder<RankingResult, RankingResultBuilder> {
  _$RankingResult? _$v;

  MetricEstimateBuilder? _scc;
  MetricEstimateBuilder get scc => _$this._scc ??= MetricEstimateBuilder();
  set scc(MetricEstimateBuilder? scc) => _$this._scc = scc;

  MetricEstimateBuilder? _ndcg;
  MetricEstimateBuilder get ndcg => _$this._ndcg ??= MetricEstimateBuilder();
  set ndcg(MetricEstimateBuilder? ndcg) => _$this._ndcg = ndcg;

  RankingResultBuilder() {
    RankingResult._defaults(this);
  }

  RankingResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _scc = $v.scc.toBuilder();
      _ndcg = $v.ndcg.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RankingResult other) {
    _$v = other as _$RankingResult;
  }

  @override
  void update(void Function(RankingResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RankingResult build() => _build();

  _$RankingResult _build() {
    _$RankingResult _$result;
    try {
      _$result = _$v ??
          _$RankingResult._(
            scc: scc.build(),
            ndcg: ndcg.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'scc';
        scc.build();
        _$failedField = 'ndcg';
        ndcg.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RankingResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
