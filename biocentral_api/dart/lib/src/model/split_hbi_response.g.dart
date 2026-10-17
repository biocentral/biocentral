// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_hbi_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SplitHBIResponse extends SplitHBIResponse {
  @override
  final BuiltList<BootstrappedMetric> metrics;
  @override
  final int numQueries;
  @override
  final int hitsFound;
  @override
  final int evaluatedQueries;

  factory _$SplitHBIResponse(
          [void Function(SplitHBIResponseBuilder)? updates]) =>
      (SplitHBIResponseBuilder()..update(updates))._build();

  _$SplitHBIResponse._(
      {required this.metrics,
      required this.numQueries,
      required this.hitsFound,
      required this.evaluatedQueries})
      : super._();
  @override
  SplitHBIResponse rebuild(void Function(SplitHBIResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SplitHBIResponseBuilder toBuilder() =>
      SplitHBIResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SplitHBIResponse &&
        metrics == other.metrics &&
        numQueries == other.numQueries &&
        hitsFound == other.hitsFound &&
        evaluatedQueries == other.evaluatedQueries;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, metrics.hashCode);
    _$hash = $jc(_$hash, numQueries.hashCode);
    _$hash = $jc(_$hash, hitsFound.hashCode);
    _$hash = $jc(_$hash, evaluatedQueries.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SplitHBIResponse')
          ..add('metrics', metrics)
          ..add('numQueries', numQueries)
          ..add('hitsFound', hitsFound)
          ..add('evaluatedQueries', evaluatedQueries))
        .toString();
  }
}

class SplitHBIResponseBuilder
    implements Builder<SplitHBIResponse, SplitHBIResponseBuilder> {
  _$SplitHBIResponse? _$v;

  ListBuilder<BootstrappedMetric>? _metrics;
  ListBuilder<BootstrappedMetric> get metrics =>
      _$this._metrics ??= ListBuilder<BootstrappedMetric>();
  set metrics(ListBuilder<BootstrappedMetric>? metrics) =>
      _$this._metrics = metrics;

  int? _numQueries;
  int? get numQueries => _$this._numQueries;
  set numQueries(int? numQueries) => _$this._numQueries = numQueries;

  int? _hitsFound;
  int? get hitsFound => _$this._hitsFound;
  set hitsFound(int? hitsFound) => _$this._hitsFound = hitsFound;

  int? _evaluatedQueries;
  int? get evaluatedQueries => _$this._evaluatedQueries;
  set evaluatedQueries(int? evaluatedQueries) =>
      _$this._evaluatedQueries = evaluatedQueries;

  SplitHBIResponseBuilder() {
    SplitHBIResponse._defaults(this);
  }

  SplitHBIResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _metrics = $v.metrics.toBuilder();
      _numQueries = $v.numQueries;
      _hitsFound = $v.hitsFound;
      _evaluatedQueries = $v.evaluatedQueries;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SplitHBIResponse other) {
    _$v = other as _$SplitHBIResponse;
  }

  @override
  void update(void Function(SplitHBIResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SplitHBIResponse build() => _build();

  _$SplitHBIResponse _build() {
    _$SplitHBIResponse _$result;
    try {
      _$result = _$v ??
          _$SplitHBIResponse._(
            metrics: metrics.build(),
            numQueries: BuiltValueNullFieldError.checkNotNull(
                numQueries, r'SplitHBIResponse', 'numQueries'),
            hitsFound: BuiltValueNullFieldError.checkNotNull(
                hitsFound, r'SplitHBIResponse', 'hitsFound'),
            evaluatedQueries: BuiltValueNullFieldError.checkNotNull(
                evaluatedQueries, r'SplitHBIResponse', 'evaluatedQueries'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metrics';
        metrics.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SplitHBIResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
