// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supervised_framework_report.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupervisedFrameworkReport extends SupervisedFrameworkReport {
  @override
  final int? minSeqLen;
  @override
  final int? maxSeqLen;
  @override
  final BuiltMap<String, BuiltMap<String, JsonObject?>> results;

  factory _$SupervisedFrameworkReport(
          [void Function(SupervisedFrameworkReportBuilder)? updates]) =>
      (SupervisedFrameworkReportBuilder()..update(updates))._build();

  _$SupervisedFrameworkReport._(
      {this.minSeqLen, this.maxSeqLen, required this.results})
      : super._();
  @override
  SupervisedFrameworkReport rebuild(
          void Function(SupervisedFrameworkReportBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupervisedFrameworkReportBuilder toBuilder() =>
      SupervisedFrameworkReportBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupervisedFrameworkReport &&
        minSeqLen == other.minSeqLen &&
        maxSeqLen == other.maxSeqLen &&
        results == other.results;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, minSeqLen.hashCode);
    _$hash = $jc(_$hash, maxSeqLen.hashCode);
    _$hash = $jc(_$hash, results.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SupervisedFrameworkReport')
          ..add('minSeqLen', minSeqLen)
          ..add('maxSeqLen', maxSeqLen)
          ..add('results', results))
        .toString();
  }
}

class SupervisedFrameworkReportBuilder
    implements
        Builder<SupervisedFrameworkReport, SupervisedFrameworkReportBuilder> {
  _$SupervisedFrameworkReport? _$v;

  int? _minSeqLen;
  int? get minSeqLen => _$this._minSeqLen;
  set minSeqLen(int? minSeqLen) => _$this._minSeqLen = minSeqLen;

  int? _maxSeqLen;
  int? get maxSeqLen => _$this._maxSeqLen;
  set maxSeqLen(int? maxSeqLen) => _$this._maxSeqLen = maxSeqLen;

  MapBuilder<String, BuiltMap<String, JsonObject?>>? _results;
  MapBuilder<String, BuiltMap<String, JsonObject?>> get results =>
      _$this._results ??= MapBuilder<String, BuiltMap<String, JsonObject?>>();
  set results(MapBuilder<String, BuiltMap<String, JsonObject?>>? results) =>
      _$this._results = results;

  SupervisedFrameworkReportBuilder() {
    SupervisedFrameworkReport._defaults(this);
  }

  SupervisedFrameworkReportBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _minSeqLen = $v.minSeqLen;
      _maxSeqLen = $v.maxSeqLen;
      _results = $v.results.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupervisedFrameworkReport other) {
    _$v = other as _$SupervisedFrameworkReport;
  }

  @override
  void update(void Function(SupervisedFrameworkReportBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupervisedFrameworkReport build() => _build();

  _$SupervisedFrameworkReport _build() {
    _$SupervisedFrameworkReport _$result;
    try {
      _$result = _$v ??
          _$SupervisedFrameworkReport._(
            minSeqLen: minSeqLen,
            maxSeqLen: maxSeqLen,
            results: results.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'results';
        results.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupervisedFrameworkReport', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
