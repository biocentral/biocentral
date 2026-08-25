// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ppi_test_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PPITestResult extends PPITestResult {
  @override
  final String success;
  @override
  final String information;
  @override
  final String testMetrics;
  @override
  final String testStatistic;
  @override
  final String pValue;
  @override
  final num? significanceLevel;

  factory _$PPITestResult([void Function(PPITestResultBuilder)? updates]) =>
      (PPITestResultBuilder()..update(updates))._build();

  _$PPITestResult._(
      {required this.success,
      required this.information,
      required this.testMetrics,
      required this.testStatistic,
      required this.pValue,
      this.significanceLevel})
      : super._();
  @override
  PPITestResult rebuild(void Function(PPITestResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PPITestResultBuilder toBuilder() => PPITestResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PPITestResult &&
        success == other.success &&
        information == other.information &&
        testMetrics == other.testMetrics &&
        testStatistic == other.testStatistic &&
        pValue == other.pValue &&
        significanceLevel == other.significanceLevel;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jc(_$hash, information.hashCode);
    _$hash = $jc(_$hash, testMetrics.hashCode);
    _$hash = $jc(_$hash, testStatistic.hashCode);
    _$hash = $jc(_$hash, pValue.hashCode);
    _$hash = $jc(_$hash, significanceLevel.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PPITestResult')
          ..add('success', success)
          ..add('information', information)
          ..add('testMetrics', testMetrics)
          ..add('testStatistic', testStatistic)
          ..add('pValue', pValue)
          ..add('significanceLevel', significanceLevel))
        .toString();
  }
}

class PPITestResultBuilder
    implements Builder<PPITestResult, PPITestResultBuilder> {
  _$PPITestResult? _$v;

  String? _success;
  String? get success => _$this._success;
  set success(String? success) => _$this._success = success;

  String? _information;
  String? get information => _$this._information;
  set information(String? information) => _$this._information = information;

  String? _testMetrics;
  String? get testMetrics => _$this._testMetrics;
  set testMetrics(String? testMetrics) => _$this._testMetrics = testMetrics;

  String? _testStatistic;
  String? get testStatistic => _$this._testStatistic;
  set testStatistic(String? testStatistic) =>
      _$this._testStatistic = testStatistic;

  String? _pValue;
  String? get pValue => _$this._pValue;
  set pValue(String? pValue) => _$this._pValue = pValue;

  num? _significanceLevel;
  num? get significanceLevel => _$this._significanceLevel;
  set significanceLevel(num? significanceLevel) =>
      _$this._significanceLevel = significanceLevel;

  PPITestResultBuilder() {
    PPITestResult._defaults(this);
  }

  PPITestResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _success = $v.success;
      _information = $v.information;
      _testMetrics = $v.testMetrics;
      _testStatistic = $v.testStatistic;
      _pValue = $v.pValue;
      _significanceLevel = $v.significanceLevel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PPITestResult other) {
    _$v = other as _$PPITestResult;
  }

  @override
  void update(void Function(PPITestResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PPITestResult build() => _build();

  _$PPITestResult _build() {
    final _$result = _$v ??
        _$PPITestResult._(
          success: BuiltValueNullFieldError.checkNotNull(
              success, r'PPITestResult', 'success'),
          information: BuiltValueNullFieldError.checkNotNull(
              information, r'PPITestResult', 'information'),
          testMetrics: BuiltValueNullFieldError.checkNotNull(
              testMetrics, r'PPITestResult', 'testMetrics'),
          testStatistic: BuiltValueNullFieldError.checkNotNull(
              testStatistic, r'PPITestResult', 'testStatistic'),
          pValue: BuiltValueNullFieldError.checkNotNull(
              pValue, r'PPITestResult', 'pValue'),
          significanceLevel: significanceLevel,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
