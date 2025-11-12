// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TestResult extends TestResult {
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

  factory _$TestResult([void Function(TestResultBuilder)? updates]) =>
      (TestResultBuilder()..update(updates))._build();

  _$TestResult._(
      {required this.success,
      required this.information,
      required this.testMetrics,
      required this.testStatistic,
      required this.pValue,
      this.significanceLevel})
      : super._();
  @override
  TestResult rebuild(void Function(TestResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TestResultBuilder toBuilder() => TestResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TestResult &&
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
    return (newBuiltValueToStringHelper(r'TestResult')
          ..add('success', success)
          ..add('information', information)
          ..add('testMetrics', testMetrics)
          ..add('testStatistic', testStatistic)
          ..add('pValue', pValue)
          ..add('significanceLevel', significanceLevel))
        .toString();
  }
}

class TestResultBuilder implements Builder<TestResult, TestResultBuilder> {
  _$TestResult? _$v;

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

  TestResultBuilder() {
    TestResult._defaults(this);
  }

  TestResultBuilder get _$this {
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
  void replace(TestResult other) {
    _$v = other as _$TestResult;
  }

  @override
  void update(void Function(TestResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TestResult build() => _build();

  _$TestResult _build() {
    final _$result = _$v ??
        _$TestResult._(
          success: BuiltValueNullFieldError.checkNotNull(
              success, r'TestResult', 'success'),
          information: BuiltValueNullFieldError.checkNotNull(
              information, r'TestResult', 'information'),
          testMetrics: BuiltValueNullFieldError.checkNotNull(
              testMetrics, r'TestResult', 'testMetrics'),
          testStatistic: BuiltValueNullFieldError.checkNotNull(
              testStatistic, r'TestResult', 'testStatistic'),
          pValue: BuiltValueNullFieldError.checkNotNull(
              pValue, r'TestResult', 'pValue'),
          significanceLevel: significanceLevel,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
